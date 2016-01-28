class Maestrano::ConnecController < Maestrano::Rails::WebHookController
  
  MODEL_MAPPING ||= {
    'organizations' => Entities::Organization,
    'people' => Entities::ContactAndLead,
    'items' => Entities::Item,
    'opportunities' => Entities::Opportunity
  }

  def notifications
    Rails.logger.info("received notification #{params}")

    begin
      params.slice('organizations', 'people', 'items').each do |resource_type, entities|
        entities.each do |entity|
          organization = Maestrano::Connector::Rails::Organization.find_by(uid: entity[:group_id], tenant: params[:tenant])
          Rails.logger.info("mapping tenant=#{params[:tenant]}, organization=#{organization}, resource_type=#{resource_type}, entity=#{entity}")

          external_client = Maestrano::Connector::Rails::External.get_client(organization)
          entity_instance = model_class(resource_type)
          connec_entities = [entity]

          entity_instance.consolidate_and_map_data(connec_entities, {}, organization, {})
          entity_instance.push_entities_to_external(external_client, connec_entities, organization)
        end
      end
    rescue => e
      Rails.logger.info("error processing notification #{e.message} - #{e.backtrace.join("\n")}")
    end

    head 200, content_type: "application/json"
  end

  def model_class(resource_type)
    MODEL_MAPPING[resource_type].new
  end
end