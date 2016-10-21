class PropertiesController < ApplicationController

  def index
    query = params[:q].presence || "*"
    @properties = Property.search(query, {
      page: params[:page],
      per_page: 20
    })

    # Searchkick's search method takes 2 parameters:
    # - arg0: a query string
    # - arg1: an options hash
  end
end
