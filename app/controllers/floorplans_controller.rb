class FloorplansController < ApplicationController

  def index
    @floorplans = Floorplan.all
  end

  def show
    @floorplan = Floorplan.find(params[:id])
  end

  def search_params
    # TODO: make a whitelist.
    params.permit!
  end
end
