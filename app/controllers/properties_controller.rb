class PropertiesController < ApplicationController

  def index
    @movies = SearchProperties.new(
                query: params[:q],
                options: search_params
              ).search
  end

  def search_params
    params.permit(
      :page,
      :per_page,
      :sort_attribute,
      :sort_order,
      :genre
    )
  end
end
