class ApplicationController < ActionController::Base
  include SessionHelper

  protect_from_forgery with: :exception

  private
    def current_user
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
      @current_user ||= User.find_by_uid(session[:uid]) if session[:uid]
    end
    helper_method :current_user
end
