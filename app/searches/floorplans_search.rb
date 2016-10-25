class FloorplansSearch < Search

  private def search_model
    Floorplan
  end

  private def search_constraints
    {
      page:         options[:page],
      per_page:     10,
      misspellings: { below: 5 },
      match:        :word_middle,
      where:        where,
      order:        order
    }
  end

  # https://github.com/ankane/searchkick#queries
  # NOTE: We add to where only the keys for which we want to filter.
  private def where
    where = {}

    if options[:rent_min].present? || options[:rent_max].present?
      where[:rent] = where_rent
    end

    if options[:bedroom_count].present?
      where[:bedroom_count] = where_bedroom_count
    end

    if options[:bathroom_count].present?
      where[:bathroom_count] = where_bathroom_count
    end

    # ap where
    where
  end

  private def where_rent
    if options[:rent_min].present? && options[:rent_max].present?
      (options[:rent_min])..(options[:rent_max])
    elsif options[:rent_min].present?
      { gte: options[:rent_min] }
    elsif options[:rent_max].present?
      { lte: options[:rent_max] }
    end
  end

  private def where_bedroom_count
    {
      "studio" => 1,
      "1"      => 1,
      "2"      => 2,
      "3"      => 3,
      "4+"     => { gte: 4 },
    } [ options[:bedroom_count] ]
  end

  private def where_bathroom_count
    {
      "1+" => { gte: 1 },
      "2+" => { gte: 2 },
      "3+" => { gte: 3 },
      } [ options[:bathroom_count] ]
  end

end
