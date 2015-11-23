class External

  def self.get_client(organization)
    Restforce.new :oauth_token => organization.oauth_token,
        refresh_token: organization.refresh_token,
        instance_url: organization.instance_url,
        client_id: ENV['salesforce_client_id'],
        client_secret: ENV['salesforce_client_secret']
  end

  def self.name
    'SalesForce'
  end

end