class HomeController < ApplicationController
  def index
    # Fetch SalesForce Accounts
    if current_user && current_user.oauth_token
      client = Restforce.new :oauth_token => current_user.oauth_token,
        refresh_token: current_user.refresh_token,
        instance_url: current_user.instance_url,
        client_id: ENV['salesforce_client_id'],
        client_secret: ENV['salesforce_client_secret'],
        cache: Rails.cache

      @accounts = client.query('select Id, Name from Account ORDER BY Name')
    end

    # Fetch Connec! Organizations
    if current_user && !current_user.organizations.empty?
      client = Maestrano::Connec::Client.new(current_user.organizations.first.uid)
      response = client.get('/organizations')
      @organizations = JSON.parse(response.body)['organizations']
    end
  end
end
