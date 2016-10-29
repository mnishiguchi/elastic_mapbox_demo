module PropertiesHelper

  def properties_title
    "#{pluralize(@properties.count, "apartment")} found"
  end

  def search_filters_text(search_filters)
    return if search_filters.nil?

    [].tap do |sc_text|
      sc_text << rent_condition_text(search_filters[:rent_min], search_filters[:rent_max])
      sc_text << room_count_condition_text(search_filters[:bedroom_count], search_filters[:bathroom_count])
      sc_text.compact!
      sc_text.insert(1, " | ") if sc_text.size > 1
    end.join("")
  end

  def rent_condition_text(rent_min, rent_max)
    if rent_min.present? && rent_max.present?
      "$#{rent_min} to $#{rent_max}"
    elsif rent_min.present?
      "Min $#{rent_min}"
    elsif rent_max.present?
      "Max $#{rent_max}"
    end
  end

  def room_count_condition_text(bedroom_count, bathroom_count)
    if bedroom_count.present? && bathroom_count.present?
      "#{pluralize(bedroom_count, "bed")} | #{pluralize(bathroom_count, "bath")}"
    elsif bedroom_count.present?
      pluralize(bedroom_count, "bed")
    elsif bathroom_count.present?
      pluralize(bathroom_count, "bath")
    end
  end


  # ---
  # Sorting
  # ---


  # def sort_attribute_select_tag(params)
  #   options = {
  #     "Name"       => "name",
  #     "City"       => "city",
  #     "State"      => "state",
  #     "Zip"        => "zip",
  #     "Updated at" => "updated_at"
  #   }
  #   select_tag(
  #     "sort_attribute",
  #     options_for_select(options, params[:sort_attribute]),
  #     include_blank: true
  #   )
  # end
  #
  # def sort_order_select_tag(params)
  #   options = {
  #     "Ascending"  => "asc",
  #     "Descending" => "desc"
  #   }
  #   select_tag(
  #     "sort_order",
  #     options_for_select(options, params[:sort_order]),
  #     include_blank: true
  #   )
  # end


  # ---
  # Filtering
  # ---


  # def city_select_tag(params)
  #   select_tag(
  #     "city",
  #     options_for_select(Property.pluck("city").uniq, params[:city]),
  #     include_blank: true
  #   )
  # end
  #
  # def state_select_tag(params)
  #   select_tag(
  #     "state",
  #     options_for_select(Property.pluck("state").uniq, params[:state]),
  #     include_blank: true
  #   )
  # end
  #
  # def zip_select_tag(params)
  #   select_tag(
  #     "zip",
  #     options_for_select(Property.pluck("zip").uniq, params[:zip]),
  #     include_blank: true
  #   )
  # end

  # def bedroom_count_select_tag(params)
  #   select_tag(
  #     "bedroom_count",
  #     options_for_select(%w(studio 1 2 3 4+), params[:bedroom_count]),
  #     include_blank: true
  #   )
  # end
  #
  # def bathroom_count_select_tag(params)
  #   select_tag(
  #     "bathroom_count",
  #     options_for_select(%w(1+ 2+ 3+), params[:bathroom_count]),
  #     include_blank: true
  #   )
  # end

  # def floorplan_rents_select_tag(params)
  #   select_tag(
  #     "floorplan_rents",
  #     options_for_select(Property.joins(:floorplans).pluck(:rent).uniq.sort, params[:floorplan_rents]),
  #     include_blank: true
  #   )
  # end
end
