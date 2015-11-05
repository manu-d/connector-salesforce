class SynchronizationJob
  ENTITIES = %w(Orga)
  EXTERNAL_NAME = "SalesForce"

  def sync(org_uid)
    organization = Organization.find_by_uid(org_uid)
    last_synchronization = Synchronization.where(organization_id: organization.id, status: 'SUCCESS').order(updated_at: :desc).first
    connec_client = Maestrano::Connec::Client.new(organization.uid)
    external_client = Restforce.new :oauth_token => organization.oauth_token,
      refresh_token: organization.refresh_token,
      instance_url: organization.instance_url,
      client_id: ENV['salesforce_client_id'],
      client_secret: ENV['salesforce_client_secret']

    ENTITIES.each do |entity|
      entity_class = entity.constantize.new
      connec_entities = entity_class.get_connec_entities(connec_client, last_synchronization)
      external_entities = entity_class.get_external_entities(external_client, last_synchronization)

      entity_class.push_entities_to_connec(connec_client, external_entities, organization)
      entity_class.push_entities_to_external(external_client, connec_entities, organization)
    end
  end
end