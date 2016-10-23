class FloorplansController < ApplicationController

  def index
    @floorplans = FloorplansSearch.new(
                    query:   params[:q],
                    options: search_params,
                  ).search
  end

  def show
    @floorplan = Floorplan.find(params[:id])
  end

  def search_params
    # TODO: make a whitelist.
    params.permit!
  end
end
