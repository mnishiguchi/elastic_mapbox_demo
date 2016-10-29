class PropertiesController < ApplicationController

  def index
    search           = PropertiesSearch.new(search_params)
    @properties      = search.search
    @formatted_query = search.formatted_query
    @json            = Property.json_for_map(@properties)
    @center_lng_lat  = Property.center_lng_lat(@properties) || search.query_lng_lat
    @search_filters  = search_params.slice(
                          :rent_min,
                          :rent_max,
                          :bedroom_count,
                          :bathroom_count
                        )
  end

  # # GET /properties/autocomplete?q=washington
  # def autocomplete
  #   render json: Property.search(params[:q],
  #                   limit: 10,
  #                   load: false,
  #                   misspellings: { below: 5 }
  #                 ).map(&:city_state).uniq
  # end

  def show
    @property = Property.find(params[:id])
  end

  private def search_params
    # TODO: make a whitelist.
    params.permit!
  end
end
