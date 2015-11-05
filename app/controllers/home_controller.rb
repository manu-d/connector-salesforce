class HomeController < ApplicationController
  def index
    @organizations_data = []
    
    if current_user
      # Process each Organization the current user belongs to
      current_user.organizations.each do |organization|
        organization_data = {uid: organization.uid, name: organization.name}
        organization_data[:last_synchronization ] = Synchronization.where(organization_id: organization.id).order(updated_at: :desc).first

        # Fetch SalesForce Accounts
        if organization.oauth_token
          client = Restforce.new :oauth_token => organization.oauth_token,
            refresh_token: organization.refresh_token,
            instance_url: organization.instance_url,
            client_id: ENV['salesforce_client_id'],
            client_secret: ENV['salesforce_client_secret']

          organization_data[:salesforce_organizations] = client.query('select Id, Name from Account ORDER BY Name')
        end

        # Fetch Connec! Organizations
        client = Maestrano::Connec::Client.new(organization.uid)
        response = client.get('/organizations')
        organization_data[:connec_organizations] = JSON.parse(response.body)['organizations']

        @organizations_data << organization_data
      end
    end
  end

  def synchronize
    SynchronizationJob.new.sync(params[:uid])

    redirect_to home_index_path
  end
end
