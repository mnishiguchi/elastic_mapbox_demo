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
    @results ||= search_model.search(@query, search_constraints)

    # Wrap the information as a hash and pass it to PropertiesController.
    {
      results:         @results,
      formatted_query: formatted_query,
      json_for_map:    json_for_map,
      center_lng_lat:  center_lng_lat
    }
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


  # We specify the where clause for the search if needed.
  private def where
    where = {}

    # https://github.com/ankane/searchkick#geospatial-searches
    if @search_params[:latitude].present? && @search_params[:latitude].present?
      where[:location] = {
        near: {
          lat: @search_params[:latitude],
          lon: @search_params[:longitude],
        },
        within: "10mi"
      }
    end

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


  # Precedence:
  # 1. the geographic center of all the search results.
  # 2. the location obtained based on the query term.
  # Returns an array of floating-point numbers of longitude and latitude.
  private def center_lng_lat
    search_result_lng_lat || query_lng_lat
  end


  # Returns an array of longitude and latitude that are calculated based on
  # the geographic center of the search results.
  private def search_result_lng_lat
    lat, lng = Geocoder::Calculations.geographic_center(@results)
    if [lng, lat].all? {|x| x.is_a?(Float) && !x.nan? }
      [lng, lat]
    end
  end


  # Returns an array of longitude and latitude of the location specified as a
  # query filter.
  # Precedence:
  # 1. longitude and latitude that are specified in the search_params.
  # 2. longitude and latitude are obtained by geocoding the query term.
  private def query_lng_lat
    if @search_params[:longitude].present? && @search_params[:latitude].present?
      [ @search_params[:longitude], @search_params[:latitude] ]
    elsif geocoded_query.present?
      [ geocoded_query.first.longitude, geocoded_query.first.latitude ]
    end
  end


  # Returns formatted version of query term if it was successfully formatted,
  # else nil.
  private def formatted_query
    @formatted_query ||= geocoded_query.first&.formatted_address
  end


  # Geocodes the raw query term. Returns an array of Geocoder::Result objects.
  # https://github.com/alexreisner/geocoder
  private def geocoded_query
    @geocoded_query ||= Geocoder.search(@search_params[:q])
  end


  # Prepares json data that can be used for creating a Map.
  private def json_for_map
    # Obtain lists of attributes.
    name_list        = @results.map(&:name)
    description_list = @results.map(&:description)
    lng_lat_list     = @results.map(&:lng_lat)

    map_hash = []
    name_list.zip(description_list, lng_lat_list).each do |attrs|
      map_hash << {
        "name"        => attrs[0],
        "description" => description_html(
                           title:    attrs[0],
                           body:     attrs[1],
                           link_url: "#"
                         ),
        "lngLat"      => attrs[2]
      }
    end

    map_hash.to_json
  end


  # Generate an HTML for a map marker popup.
  private def description_html(title:, body:, link_url:)
    <<-HTML
      <h6>#{title}</h6>
      <p>#{body}</p>
      <a href=#{link_url}>link</a>
    HTML
  end

end
