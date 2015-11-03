class SessionsController < ApplicationController

  def request_omniauth
    auth_params = {
      :state => params[:org_uid]
    }
    auth_params = URI.escape(auth_params.collect{|k,v| "#{k}=#{v}"}.join('&'))

    redirect_to "/auth/#{params[:provider]}?#{auth_params}", id: "sign_in"
  end

  # Link an Organization to SalesForce OAuth account
  def create_omniauth
    Organization.from_omniauth(params[:state], env["omniauth.auth"])
    redirect_to root_url
  end

  # Unlink Organization from SalesForce
  def destroy_omniauth
    organization = Organization.find(params[:organization_id])
    if organization && organization.member?(current_user)
      organization.oauth_uid = nil
      organization.oauth_token = nil
      organization.refresh_token = nil
      organization.save
    end

    redirect_to root_url
  end

  # Logout
  def destroy
    session.delete(:uid)
    @current_user = nil

    redirect_to root_url
  end
end