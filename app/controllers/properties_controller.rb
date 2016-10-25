class PropertiesController < ApplicationController

  def index
    @properties = PropertiesSearch.new(
                    query:   params[:q],
                    options: search_params,
                  ).search
    @search_conditions = {
      "q"              => search_params[:q],
      "rent_min"       => search_params[:rent_min],
      "rent_max"       => search_params[:rent_max],
      "bedroom_count"  => search_params[:bedroom_count],
      "bathroom_count" => search_params[:bathroom_count],
    }
  end

  def show
    @property = Property.find(params[:id])
  end

  def search_params
    # TODO: make a whitelist.
    params.permit!
  end
end
