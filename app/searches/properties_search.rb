class PropertiesSearch

  private def search_model
    Property
  end

  # Returns an Searchkick::Results object which responds like an array.
  def initialize(search_params)
    @search_params = search_params
    @query         = formatted_query.presence || "*"
  end

  # A wrapper of Searchkick's search method. We configure common behavior of
  # all the searches here.
  # arg0: a query string
  # arg1: an @search_params hash
  def search
    # Invoke Searchkick's search method with our search constraints.
    search_model.search(@query, search_constraints)
  end

  # Returns formatted version of query term if it was successfully formatted,
  # else nil.
  def formatted_query
    geocoded_query.first&.formatted_address
  end

  # Returns an array of longitude and latitude of the location specified as a
  # query term.
  def query_lng_lat
    return nil if geocoded_query.empty?
    [ geocoded_query.first.longitude, geocoded_query.first.latitude ]
  end

  # Geocodes the raw query string. Returns an array of Geocoder::Result objects.
  # https://github.com/alexreisner/geocoder
  private def geocoded_query
    @geocoded_query ||= Geocoder.search(@search_params[:q])
  end

  private def search_constraints
    {
      match:        :word_start,
      misspellings: { below: 5 },
      limit: 30,
      where: where,
      order: order,
    }
  end

  private def where
    where = {}

    # # https://github.com/ankane/searchkick#geospatial-searches
    # if @search_params[:lng_lat].present?
    #   lng, lat = @search_params[:lng_lat].split(',').map(&:to_f)
    #   where[:location] = { near: { lat: lat, lon: lng }, within: "100mi" }
    # end

    if @search_params[:rent_min].present?
      where[:rent_min] = { gte: @search_params[:rent_min] }
    end

    if @search_params[:rent_max].present?
      where[:rent_max] = { lte: @search_params[:rent_max] }
    end

    if @search_params[:bedroom_count].present?
      # NOTE: @search_params[:bedroom_count] is a string
      where[:floorplan_bedroom_count] = { gte: @search_params[:bedroom_count].to_i }
    end

    if @search_params[:bathroom_count].present?
      # NOTE: @search_params[:bathroom_count] is a string
      where[:floorplan_bathroom_count] = { lte: @search_params[:bathroom_count].to_i }
    end

    ap where

    return where
  end

  private def order
    return {} unless @search_params[:sort_attribute].present?

    order = @search_params[:sort_order].presence || :asc
    { @search_params[:sort_attribute] => order }
  end
end
