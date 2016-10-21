module PropertiesHelper


  # ---
  # Sorting
  # ---


  def sort_attribute_select_tag(params)
    options = {
      "Name"       => "name",
      "City"       => "city",
      "State"      => "state",
      "Zip"        => "zip",
      "Updated at" => "updated_at"
    }
    select_tag(
      "sort_attribute",
      options_for_select(options, params[:sort_attribute]),
      include_blank: true
    )
  end

  def sort_order_select_tag(params)
    options = {
      "Ascending"  => "asc",
      "Descending" => "desc"
    }
    select_tag(
      "sort_order",
      options_for_select(options, params[:sort_order]),
      include_blank: true
    )
  end


  # ---
  # Filtering
  # ---



  def city_select_tag(params)
    select_tag(
      "city",
      options_for_select(Property.pluck("city").uniq, params[:city]),
      include_blank: true
    )
  end

  def state_select_tag(params)
    select_tag(
      "state",
      options_for_select(Property.pluck("state").uniq, params[:state]),
      include_blank: true
    )
  end

  def zip_select_tag(params)
    select_tag(
      "zip",
      options_for_select(Property.pluck("zip").uniq, params[:zip]),
      include_blank: true
    )
  end

  # def floorplan_rents_select_tag(params)
  #   select_tag(
  #     "floorplan_rents",
  #     options_for_select(Property.joins(:floorplans).pluck(:rent).uniq.sort, params[:floorplan_rents]),
  #     include_blank: true
  #   )
  # end
end
