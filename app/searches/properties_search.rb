class PropertiesSearch < Search

  private def search_model
    Property
  end

  private def search_constraints
    {
      limit:        30,
      misspellings: { below: 5 },
      match:        :word_middle,
      where:        where,
      order:        order
    }
  end

  # TODO: pet, interior_amenities, community_amenities
  private def where
    where = {}

    if options[:rent_min].present?
      where[:rent_min] = { gte: options[:rent_min] }
    end

    if options[:rent_max].present?
      where[:rent_max] = { lte: options[:rent_max] }
    end

    if options[:bedroom_count].present?
      # NOTE: options[:bedroom_count] is a string
      where[:floorplan_bedroom_count] = { gte: options[:bedroom_count].to_i }
    end

    if options[:bathroom_count].present?
      # NOTE: options[:bathroom_count] is a string
      where[:floorplan_bathroom_count] = { lte: options[:bathroom_count].to_i }
    end

    # ap where
    where
  end
end
