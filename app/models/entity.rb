class Entity

  @@external_name = "SalesForce"

  def get_connec_entities(client, last_synchronization, opts={})
    Rails.logger.info "Fetching Connec! #{self.connec_entity_name.pluralize}"

    entities = []

    # Fetch first page
    if last_synchronization.blank? || opts[:full_sync]
      response = client.get("/#{self.connec_entity_name.downcase.pluralize}")
    else
      query_param = URI.encode("$filter=updated_at gt '#{last_synchronization.updated_at.strftime('%F')}'")
      response = client.get("/#{self.connec_entity_name.downcase.pluralize}?#{query_param}")
    end

    response_hash = JSON.parse(response.body)
    if response_hash["#{self.connec_entity_name.downcase.pluralize}"]
      entities << response_hash["#{self.connec_entity_name.downcase.pluralize}"]
    else
      raise "No data received from Connec! when trying to fetch #{self.connec_entity_name.pluralize}."
    end

    # Fetch subsequent pages
    while response_hash['pagination'] && response_hash['pagination']['next']
      # ugly way to convert https://api-connec/api/v2/group_id/organizations?next_page_params to /organizations?next_page_params
      next_page = response_hash['pagination']['next'].gsub(/^(.*)\/#{self.name.downcase.pluralize}/, '/#{self.name.downcase.pluralize}')
      response = client.get(next_page)
      response_hash = JSON.parse(response.body)
      entities << response_hash["#{self.connec_entity_name.downcase.pluralize}"]
    end

    entities = entities.flatten
    Rails.logger.info "Source=Connec!, Entity=#{self.connec_entity_name}, Response=#{entities}"
    entities
  end

  #TODO Pagination
  def get_external_entities(client, last_synchronization, opts={})
    Rails.logger.info "Fetching #{@@external_name} #{self.external_entity_name.pluralize}"
    # if last_synchronization
      # Cannot get the get_updated query to work
      # client.get_updated('Account', last_synchronization.updated_at, Time.now)
      # client.query('select Id, Name from Account ORDER BY Name')
    # else
      fields = self.external_attributes.join(', ')
      entities = client.query("select Id, LastModifiedDate, #{fields} from #{self.external_entity_name} ORDER BY LastModifiedDate DESC")
      entities = entities.to_a

      unless opts[:full_sync]
        index = entities.find_index{|entity| entity.LastModifiedDate < last_synchronization.updated_at }
        entities = index ? (index >= 0 ? entities[0..index] : []) : entities
      end
      Rails.logger.info "Source=#{@@external_name}, Entity=#{self.external_entity_name}, Response=#{entities}"
    # end
    entities
  end

  def push_entities_to_external(external_client, connec_entities, organization)
    Rails.logger.info "Push Connec! #{self.connec_entity_name.pluralize} to #{@@external_name} #{self.external_entity_name.pluralize}"
    connec_entities.each do |connec_entity|
      idmap = IdMap.find_or_create_by(connec_id: connec_entity['_connec_id'], connec_entity: self.connec_entity_name.downcase, organization_id: organization.id)
      connec_entity.delete('_connec_id') #SalesForce API does not tolerate none existing fields
      # Entity does not exist in external
      if idmap.salesforce_id.blank?
        external_id = self.create_entity_to_external(external_client, connec_entity)
        idmap.update_attributes(salesforce_id: external_id, salesforce_entity: self.external_entity_name)
      else
        self.update_entity_to_external(external_client, connec_entity, idmap.salesforce_id)
      end
    end
  end

  def create_entity_to_external(client, mapped_connec_entity)
    Rails.logger.info "Create #{self.external_entity_name}: #{mapped_connec_entity} to #{@@external_name}"
    client.create!(self.external_entity_name, mapped_connec_entity)
  end

  def update_entity_to_external(client, mapped_connec_entity, external_id)
    Rails.logger.info "Update #{self.external_entity_name} (id=#{external_id}): #{mapped_connec_entity} to #{@@external_name}"
    mapped_connec_entity['ID'] = external_id
    client.update!(self.external_entity_name, mapped_connec_entity)
  end

  def push_entities_to_connec(connec_client, external_entities, organization)
    Rails.logger.info "Push #{@@external_name} #{self.external_entity_name.pluralize} to Connec! #{self.connec_entity_name.pluralize}"
    external_entities.each do |external_entity|
      idmap = IdMap.find_or_create_by(salesforce_id: external_entity['_external_id'], salesforce_entity: self.external_entity_name, organization_id: organization.id)
      # Entity does not exist in Connec!
      if idmap.connec_id.blank?
        connec_entity = self.create_entity_to_connec(connec_client, external_entity)
        idmap.update_attributes(connec_id: connec_entity['id'], connec_entity: self.connec_entity_name.downcase)
      else
        connec_entity = self.update_entity_to_connec(connec_client, external_entity, idmap.connec_id)
      end
    end
  end

  def create_entity_to_connec(client, mapped_external_entity)
    Rails.logger.info "Create #{self.connec_entity_name}: #{mapped_external_entity} to Connec!"
    response = client.post("/#{self.connec_entity_name.downcase.pluralize}", { "#{self.connec_entity_name.downcase.pluralize}": mapped_external_entity })
    JSON.parse(response.body)["#{self.connec_entity_name.downcase.pluralize}"]
  end

  def update_entity_to_connec(client, mapped_external_entity, connec_id)
    Rails.logger.info "Update #{self.connec_entity_name}: #{mapped_external_entity} to Connec!"
    response = client.put("/#{self.connec_entity_name.downcase.pluralize}/#{connec_id}", { "#{self.connec_entity_name.downcase.pluralize}": mapped_external_entity })
    JSON.parse(response.body)["#{self.connec_entity_name.downcase.pluralize}"]
  end

  def consolidate_and_map_data(connec_entities, external_entities, organization, opts={})
    external_entities.map!{|entity|
      id = entity.Id
      entity = self.map_to_connec(entity.attrs)
      idmap = IdMap.where(salesforce_id: id, salesforce_entity: self.external_entity_name, organization_id: organization.id).first

      if idmap && idmap.connec_id && connec_entity = connec_entities.detect{|entity| entity['id'] == idmap.connec_id}
        Rails.logger.info "Conflict between #{@@external_name} #{self.external_entity_name} #{entity} and Connec! #{self.connec_entity_name} #{connec_entity}. Preemption given to #{opts[:external_preemption] ? @@external_name : 'Connec!'}"
        if opts[:external_preemption]
          connec_id = connec_entity['id']
          connec_entity = entity
          connec_entity['_connec_id'] = connec_id
        else
          entity = connec_entity
        end
      end
      entity['_external_id'] = id
      entity
    }

    connec_entities.map!{|entity|
      id = entity['id'] || entity['_connec_id']
      entity = self.map_to_external(entity)
      entity['_connec_id'] = id
      entity
    }
  end

end