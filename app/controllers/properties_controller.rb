class PropertiesController < ApplicationController

  def index
    @properties = PropertiesSearch.new(
                    query:   params[:q],
                    options: search_params,
                  ).search

    @json = Property.properties_json_for_map(@properties)

    @center_lng_lat = begin
      lngs = @properties.pluck(:longitude)
      lats = @properties.pluck(:latitude)
      [
        lngs.reduce(:+) / lngs.size,
        lats.reduce(:+) / lats.size,
      ]
    end

    @search_conditions = {
      "q"              => search_params[:q],
      "rent_min"       => search_params[:rent_min],
      "rent_max"       => search_params[:rent_max],
      "bedroom_count"  => search_params[:bedroom_count],
      "bathroom_count" => search_params[:bathroom_count],
    }
  end

  # GET /properties/autocomplete?q=washington
  def autocomplete
    render json: Property.search(params[:q], {
                    fields: ["city_state^5"],
                    limit: 10,
                    load: false,
                    misspellings: { below: 5 }
                  }).map(&:city_state).uniq
  end

  def show
    @property = Property.find(params[:id])
  end

  private def search_params
    # TODO: make a whitelist.
    params.permit!
  end
end
