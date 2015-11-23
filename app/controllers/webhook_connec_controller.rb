class WebhookConnecController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def receive
    # TODO not working
    # tenant_key = params['tenant_key']
    # unless Maestrano.with(tenant_key).authenticate(http_basic['login'],http_basic['password'])
    #   return render json: "Unauthorized, code: '401'", status: :unauthorized
    # end

    params['notification'].each do |entity_name, entities|
      entity_name = entity_name.singularize

      begin
        entity_class = "Entities::#{entity_name.titleize.split.join}".constantize.new

        entities.each do |entity|
          if organization = Organization.find_by_uid(entity['group_id']) && organization.oauth_uid

            if organization.synchronized_entities[entity_name.to_sym]
              entity_class.set_mapper_organization(organization.id)
              external_client = External.get_client(organization)

              Rails.logger.info "Received entity #{entity_name} from Connec! notification for #{entity['group_id']}. Entity=#{entity}. Pushing it"
              mapped_entity = entity_class.map_to_external_with_idmap(entity, organization)
              entity_class.push_entity_to_external(external_client, mapped_entity)
              entity_class.unset_mapper_organization
            end

          else
            Rails.logger.warn "Received notification from Connec! for unknown group or group without oauth: #{entity['group_id']}"
          end
        end

      rescue NameError => e
        Rails.logger.warn "Received unknown entity type from Connec! notification: #{entity_name}"
      end
    end

    render json: {success: true}
  end

end