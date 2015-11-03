class SessionsController < ApplicationController
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