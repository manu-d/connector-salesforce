class AdminController < ApplicationController

  def index
    if is_admin
      @organization = current_organization
      @idmaps = IdMap.where(organization_id: @organization.id).order(:connec_entity)
    end
  end

  def update
    organization = Organization.find_by_id(params[:id])

    if organization && is_admin?(current_user, organization)
      organization.synchronized_entities.each do |entity, bool|
        if !!params["#{entity}"]
          organization.synchronized_entities[entity] = true
        else
          organization.synchronized_entities[entity] = false
        end
      end
      organization.save
    end

    redirect_to admin_index_path
  end

  def synchronize
    if is_admin
      SynchronizationJob.new.sync(current_organization, params['opts'])
    end

    redirect_to admin_index_path
  end

  private
    def is_admin
      current_user && current_organization && is_admin?(current_user, current_organization)
    end
end
