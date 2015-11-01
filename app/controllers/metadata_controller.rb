class MetadataController < ApplicationController
  # Return the Maestrano configuration for this application
  def index
    render json: Maestrano[params[:tenant]].to_metadata
  end
end