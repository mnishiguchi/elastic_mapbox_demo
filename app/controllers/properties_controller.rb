class PropertiesController < ApplicationController

  def index
    @properties = SearchForProperties.new(
                    query:   params[:q],
                    options: search_params
                  ).search
  end

  def search_params
    params.permit(
      :page,
      :sort_attribute,
      :sort_order
    )
  end
end
