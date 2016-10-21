class SearchForProperties < Search

  private def search_model
    Property
  end

  private def where
    where = {}

    if options[:city].present?
      where[:city] = options[:city]
    end

    if options[:state].present?
      where[:state] = options[:state]
    end

    if options[:zip].present?
      where[:zip] = options[:zip]
    end

    if options[:management_name].present?
      where[:management_name] = options[:management_name]
    end

    # if options[:floorplan_rents].present?
    #   where[:floorplan_rents] = { lte: options[:floorplan_rents] }
    # end

    where
  end
end
