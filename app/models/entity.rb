class Entity

  def get_connec_entities(client, last_synchronization)
    Rails.logger.debug "Fetching Connec! #{self.class.name.pluralize}"

    entities = []

    # Fetch first page
    if last_synchronization.blank?
      response = client.get("/#{self.connec_entity_name.downcase.pluralize}")
    else
      query_param = URI.encode("$filter=updated_at >= #{last_synchronization.updated_at}")
      response = client.get("/#{self.connec_entity_name.downcase.pluralize}?#{query_param}")
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

    entities.flatten
  end

  def get_external_entities(client, last_synchronization)
    Rails.logger.debug "Fetching external #{self.external_entity_name}"
    # if last_synchronization
      # Cannot get the get_updated query to work
      # client.get_updated('Account', last_synchronization.updated_at, Time.now)
      # client.query('select Id, Name from Account ORDER BY Name')
    # else
      client.query("select Id, Name from #{self.external_entity_name} ORDER BY Name") #mapping
    # end
  end

  def push_entities_to_external(external_client, connec_entities, organization)
    connec_entities.each do |connec_entity|
      idmap = IdMap.find_or_create_by(connec_id: connec_entity['id'], connec_entity: self.connec_entity_name.downcase, organization_id: organization.id)
      # Entity does not exist in external
      if idmap.salesforce_id.blank?
        external_id = self.push_entity_to_external(external_client, connec_entity)
        idmap.update_attributes(salesforce_id: external_id, salesforce_entity: self.external_entity_name)
      end
    end
  end

  def push_entity_to_external(client, connec_entity)
    client.create(self.external_entity_name, Name: connec_entity['name'])
  end

  def push_entities_to_connec(connec_client, external_entities, organization)
    external_entities.each do |external_entity|
      idmap = IdMap.find_or_create_by(salesforce_id: external_entity.Id, salesforce_entity: self.external_entity_name, organization_id: organization.id)
      # Entity does not exist in Connec!
      if idmap.connec_id.blank?
        connec_data = self.push_entity_to_connec(connec_client, external_entity)
        idmap.update_attributes(connec_id: connec_data['id'], connec_entity: self.connec_entity_name.downcase)
      end
    end
  end

  def push_entity_to_connec(client, external_entity)
    response = client.post("/#{self.connec_entity_name.downcase.pluralize}", { "#{self.connec_entity_name.downcase.pluralize}": { name: external_entity.Name} })
    JSON.parse(response.body)["#{self.connec_entity_name.downcase.pluralize}"]
  end

end