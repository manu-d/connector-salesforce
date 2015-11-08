class Entity

  @@external_name = "SalesForce"

  def get_connec_entities(client, last_synchronization)
    Rails.logger.info "Fetching Connec! #{self.connec_entity_name.pluralize}"

    entities = []

    # Fetch first page
    if last_synchronization.blank?
      response = client.get("/#{self.connec_entity_name.downcase.pluralize}")
      Rails.logger.debug "Connec get query: /#{self.connec_entity_name.downcase.pluralize}"
    else
      query_param = URI.encode("$filter=updated_at gt '#{last_synchronization.updated_at.strftime('%F')}'")
      response = client.get("/#{self.connec_entity_name.downcase.pluralize}?#{query_param}")
      Rails.logger.debug "Connec get query: /#{self.connec_entity_name.downcase.pluralize}?#{query_param}"
    end

    response_hash = JSON.parse(response.body)
    entities << response_hash["#{self.connec_entity_name.downcase.pluralize}"]

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
  def get_external_entities(client, last_synchronization)
    Rails.logger.info "Fetching #{@@external_name} #{self.external_entity_name.pluralize}"
    # if last_synchronization
      # Cannot get the get_updated query to work
      # client.get_updated('Account', last_synchronization.updated_at, Time.now)
      # client.query('select Id, Name from Account ORDER BY Name')
    # else
      fields = self.mapping.values.join(', ')
      entities = client.query("select Id, LastModifiedDate, #{fields} from #{self.external_entity_name} ORDER BY LastModifiedDate DESC")
      entities = entities.to_a

      index = entities.find_index{|entity| entity.LastModifiedDate < last_synchronization.updated_at }
      entities = index ? (index >= 0 ? entities[0..index] : []) : entities
      Rails.logger.info "Source=#{@@external_name}, Entity=#{self.external_entity_name}, Response=#{entities}"
    # end
    entities
  end

  def push_entities_to_external(external_client, connec_entities, organization)
    Rails.logger.info "Push Connec! #{self.connec_entity_name.pluralize} to #{@@external_name} #{self.external_entity_name.pluralize}"
    connec_entities.each do |connec_entity|
      idmap = IdMap.find_or_create_by(connec_id: connec_entity['id'], connec_entity: self.connec_entity_name.downcase, organization_id: organization.id)
      # Entity does not exist in external
      if idmap.salesforce_id.blank?
        external_id = self.create_entity_to_external(external_client, connec_entity)
        idmap.update_attributes(salesforce_id: external_id, salesforce_entity: self.external_entity_name)
      else
        self.update_entity_to_external(external_client, connec_entity, idmap.salesforce_id)
      end
    end
  end

  def create_entity_to_external(client, connec_entity)
    data = data_to_external(connec_entity)
    Rails.logger.debug "Create #{self.external_entity_name}: #{data} to #{@@external_name}"
    client.create(self.external_entity_name, data)
  end

  def update_entity_to_external(client, connec_entity, external_id)
    data = data_to_external(connec_entity)
    Rails.logger.debug "Update #{self.external_entity_name} (id=#{external_id}): #{data} to #{@@external_name}"
    data['ID'] = external_id
    client.update(self.external_entity_name, data)
  end

  def push_entities_to_connec(connec_client, external_entities, organization)
    Rails.logger.info "Push #{@@external_name} #{self.external_entity_name.pluralize} to Connec! #{self.connec_entity_name.pluralize}"
    external_entities.each do |external_entity|
      idmap = IdMap.find_or_create_by(salesforce_id: external_entity.Id, salesforce_entity: self.external_entity_name, organization_id: organization.id)
      # Entity does not exist in Connec!
      if idmap.connec_id.blank?
        connec_entity = self.create_entity_to_connec(connec_client, external_entity)
        idmap.update_attributes(connec_id: connec_entity['id'], connec_entity: self.connec_entity_name.downcase)
      else
        connec_entity = self.update_entity_to_connec(connec_client, external_entity, idmap.connec_id)
      end
    end
  end

  def create_entity_to_connec(client, external_entity)
    data = data_to_connec(external_entity)
    Rails.logger.debug "Create #{self.connec_entity_name}: #{data} to Connec!"
    response = client.post("/#{self.connec_entity_name.downcase.pluralize}", { "#{self.connec_entity_name.downcase.pluralize}": data })
    JSON.parse(response.body)["#{self.connec_entity_name.downcase.pluralize}"]
  end

  def update_entity_to_connec(client, external_entity, connec_id)
    data = data_to_connec(external_entity)
    Rails.logger.debug "Update #{self.connec_entity_name}: #{data} to Connec!"
    response = client.put("/#{self.connec_entity_name.downcase.pluralize}/#{connec_id}", { "#{self.connec_entity_name.downcase.pluralize}": data })
    JSON.parse(response.body)["#{self.connec_entity_name.downcase.pluralize}"]
  end

  private
    def data_to_external(connec_entity)
      data = {}
      self.mapping.each do |k, v|
        data[v] = connec_entity[k.to_s]
      end
      data
    end

    def data_to_connec(external_entity)
      data = {}
      self.mapping.each do |k,v|
        data[k.to_s] = external_entity.attrs[v]
      end
      data
    end

end