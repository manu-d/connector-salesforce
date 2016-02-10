class HomeController < ApplicationController
  def index
    @organization = current_organization if current_user
  end
end