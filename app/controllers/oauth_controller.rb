class OauthController < ApplicationController

  def request_omniauth
    if is_admin
      auth_params = {
        :state => current_organization.uid
      }
      auth_params = URI.escape(auth_params.collect{|k,v| "#{k}=#{v}"}.join('&'))

      redirect_to "/auth/#{params[:provider]}?#{auth_params}", id: "sign_in"
    else
      redirect_to root_url
    end
  end

  # Link an Organization to SalesForce OAuth account
  def create_omniauth
    org_uid = params[:state]
    organization = Maestrano::Connector::Rails::Organization.find_by_uid_and_tenant(org_uid, current_user.tenant)

    if organization && is_admin?(current_user, organization)
      organization.from_omniauth(env["omniauth.auth"])

      # Fetch SalesForce user details
      user_details = Maestrano::Connector::Rails::External.fetch_user(organization)
      current_user.update_attribute(:locale, user_details['locale'])
      current_user.update_attribute(:timezone, user_details['timezone'])

      # Fetch SalesForce company name
      company = Maestrano::Connector::Rails::External.fetch_company(organization)
      organization.update_attribute(:oauth_name, company['Name'])
      organization.update_attribute(:oauth_uid, company['Id'])
    end

    redirect_to root_url
  end

  # Unlink Organization from SalesForce
  def destroy_omniauth
    organization = Maestrano::Connector::Rails::Organization.find_by_id(params[:organization_id])
    if organization && is_admin?(current_user, organization)
      organization.oauth_uid = nil
      organization.oauth_token = nil
      organization.refresh_token = nil
      organization.sync_enabled = false
      organization.save
    end

    redirect_to root_url
  end
end