class AdminController < ApplicationController

  def index
    if is_admin
      @organization = current_organization
    end
  end

  def synchronize
    return redirect_to admin_path unless is_admin

    SynchronizationJob.new.sync(params[:uid])

    redirect_to admin_path
  end

  private
    def is_admin
      current_user && current_organization && is_admin?(current_user, current_organization)
    end
end
