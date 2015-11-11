class SynchronizationJob
  ENTITIES = %w(Organization Person)
  EXTERNAL_NAME = "SalesForce"

  def sync(org_uid, opts={})
    organization = Organization.find_by_uid(org_uid)
    Rails.logger.info "Start synchronization, organization=#{organization.uid}"
    current_synchronization = Synchronization.create(organization_id: organization.id, status: 'RUNNING')

    begin
      last_synchronization = Synchronization.where(organization_id: organization.id, status: 'SUCCESS').order(updated_at: :desc).first
      connec_client = Maestrano::Connec::Client.new(organization.uid)
      external_client = Restforce.new :oauth_token => organization.oauth_token,
        refresh_token: organization.refresh_token,
        instance_url: organization.instance_url,
        client_id: ENV['salesforce_client_id'],
        client_secret: ENV['salesforce_client_secret']

      ENTITIES.each do |entity|
        entity_class = "Entities::#{entity}".constantize.new
        entity_class.set_mapper_organization(organization.id)
        connec_entities = entity_class.get_connec_entities(connec_client, last_synchronization, opts)
        external_entities = entity_class.get_external_entities(external_client, last_synchronization, opts)

        entity_class.consolidate_and_map_data(connec_entities, external_entities, organization, opts)

        entity_class.push_entities_to_connec(connec_client, external_entities, organization)
        entity_class.push_entities_to_external(external_client, connec_entities, organization)
        entity_class.unset_mapper_organization
      end

      Rails.logger.info "Finished synchronization, organization=#{organization.uid}, status=success"
      current_synchronization.update_attributes(status: 'SUCCESS')
    rescue => e
      Rails.logger.info "Finished synchronization, organization=#{organization.uid}, status=error, message=#{e.message} backtrace=#{e.backtrace.join("\n\t")}"
      current_synchronization.update_attributes(status: 'ERROR', message: e.message)
    end
  end
end