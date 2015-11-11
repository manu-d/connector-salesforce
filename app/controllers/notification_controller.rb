class NotificationController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def handle
    Rails.logger.debug "Received notification from Connec!: #{params}"
    params['notification'].each do |entity_name, entities|
      entity_name = entity_name.singularize
      entity_name = entity_name.slice(0).capitalize + entity_name.slice(1..-1)

      begin
        Rails.logger.debug "Trying entity_class: #{entity_name}"
        entity_class = "Entities::#{entity_name}".constantize.new
        entities.each do |entity|
          if organization = Organization.find_by_uid(entity['group_id'])
            entity_class.set_mapper_organization(organization.id)
            external_client = Restforce.new :oauth_token => organization.oauth_token,
              refresh_token: organization.refresh_token,
              instance_url: organization.instance_url,
              client_id: ENV['salesforce_client_id'],
              client_secret: ENV['salesforce_client_secret']

            Rails.logger.info "Received entity #{entity_name} from Connec! notification for #{entity['group_id']}. Entity=#{entity}. Pushing it"
            mapped_entity = entity_class.map_to_external(entity)
            entity_class.push_entity_to_external(external_client, mapped_entity, organization)
            entity_class.unset_mapper_organization
          else
            Rails.logger.warn "Received notification from Connec! for unknown group: #{entity['group_id']}"
          end
        end
      rescue NameError => e
        Rails.logger.warn "Received unknown entity type from Connec! notification: #{entity_name}"
        Rails.logger.debug "Rescued NameError: #{e}"
      end
    end

    render json: "Ok", status: :ok
  end

end
