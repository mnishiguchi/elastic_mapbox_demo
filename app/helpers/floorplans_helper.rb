module FloorplansHelper

  def bedroom_count_select_tag(params)
    select_tag(
      "bedroom_count",
      options_for_select(%w(studio 1 2 3 4+), params[:bedroom_count]),
      include_blank: true
    )
  end

  def bathroom_count_select_tag(params)
    select_tag(
      "bathroom_count",
      options_for_select(%w(1+ 2+ 3+), params[:bathroom_count]),
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
