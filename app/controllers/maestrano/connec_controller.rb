class Maestrano::ConnecController < Maestrano::Rails::WebHookController
  def notifications
    Rails.logger.info("received notification #{params}")

    begin
      params.slice('organizations', 'people', 'items').each do |resource_type, entities|
        entities.each do |entity|
          organization = Maestrano::Connector::Rails::Organization.find_by(uid: entity[:group_id], tenant: params[:tenant])
          Rails.logger.info("mapping tenant=#{params[:tenant]}, organization=#{organization}, resource_type=#{resource_type}, entity=#{entity}")

          external_client = Maestrano::Connector::Rails::External.get_client(organization)
          entity_instance = "Entities::#{resource_type.singularize.titleize.split.join}".constantize.new
          data = entity_instance.map_to_external_with_idmap(entity, organization)
          entity_instance.push_entities_to_external(external_client, [data], organization) if data
        end
      end
    rescue => e
      Rails.logger.info("error processing notification #{e.message} - #{e.backtrace.join("\n")}")
    end

    head 200, content_type: "application/json"
  end
end