class Maestrano::Connector::Rails::External
  include Maestrano::Connector::Rails::Concerns::External

  def self.external_name
    'SalesForce'
  end

  def self.get_client(organization)
    Restforce.new :oauth_token => organization.oauth_token,
      refresh_token: organization.refresh_token,
      instance_url: organization.instance_url,
      client_id: ENV['salesforce_client_id'],
      client_secret: ENV['salesforce_client_secret']
  end

  def self.get_id_from_entity_hash(entity)
    entity['Id']
  end

  def self.get_last_update_date_from_entity_hash(entity)
    entity['LastModifiedDate']
  end
end