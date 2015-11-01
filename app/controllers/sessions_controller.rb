class SessionsController < ApplicationController
  # Link a user to SalesForce OAuth account
  def create_omniauth
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_url
  end

  # Unlink user from SalesForce
  def destroy_omniauth
    current_user.oauth_uid = nil
    current_user.oauth_token = nil
    current_user.refresh_token = nil
    current_user.save
    
    redirect_to root_url
  end

  # Logout
  def destroy
    session.delete(:user_id)
    session.delete(:uid)
    @current_user = nil

    redirect_to root_url
  end
end