# frozen_string_literal: true
class HomeController < ApplicationController

  def index
    @all_currencies ||= currencies
  end

  def currencies
    currencies = []
    Money::Currency.table.each do |key, hash|
      currencies << "#{hash[:name]} (#{hash[:iso_code]})" 
    end
    currencies.sort_by!(&:downcase)
  end

  def update
    return redirect_to(:back) unless is_admin

    # Update list of entities to synchronize
    current_organization.synchronized_entities.keys.each do |entity|
      current_organization.synchronized_entities[entity][:can_push_to_connec] = params[entity.to_s]["to_connec"] == "1"
      current_organization.synchronized_entities[entity][:can_push_to_external] = params[entity.to_s]["to_external"] == "1"
    end

    full_sync = params['historical-data'].present? && !current_organization.historical_data
    opts = {full_sync: full_sync}
    current_organization.sync_enabled = current_organization.synchronized_entities.values.any? { |settings| settings.values.any? { |v| v } }
    current_organization.enable_historical_data(params['historical-data'].present?)
    trigger_sync = current_organization.sync_enabled
    current_organization.save

    # Trigger sync only if the sync has been enabled
    start_synchronization(opts) if trigger_sync

    redirect_to(:back)
  end

  def synchronize
    return redirect_to(:back) unless is_admin
    Maestrano::Connector::Rails::SynchronizationJob.perform_later(current_organization.id, (params['opts'] || {}).merge(forced: true))
    flash[:info] = 'Synchronization requested'
    redirect_to(:back)
  end

  def redirect_to_external
    # If current user has a linked organization, redirect to the SalesForce instance url
    if current_organization && current_organization.instance_url
      redirect_to current_organization.instance_url
    else
      redirect_to 'https://login.salesforce.com'
    end
  end

  private

    def start_synchronization(opts)
      Maestrano::Connector::Rails::SynchronizationJob.perform_later(current_organization.id, opts)
      flash[:info] = 'Congrats, you\'re all set up! Your data are now being synced' if current_organization.sync_enabled_changed?
    end
end
