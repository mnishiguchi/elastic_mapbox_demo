class PropertiesSearch
  attr_reader :query, :options

  private def search_model
    Property
  end

  # - return: an Searchkick::Results object which responds like an array.
  def initialize(query:, options: {})
    @query   = query.presence || "*"
    @options = options
  end

  # A wrapper of Searchkick's search method. We configure common behavior of
  # all the searches here.
  # - arg0:   a query string
  # - arg1:   an options hash
  def search
    # Invoke Searchkick's search method with our search constraints.
    search_model.search(@query, search_constraints)
  end

  private def search_constraints
    {
      match:        :word_middle,
      misspellings: { below: 5 },
      limit:        30,
      where: where,
      order: order,
    }
  end

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

    return where
  end

  private def order
    return {} unless options[:sort_attribute].present?

    order = options[:sort_order].presence || :asc
    { options[:sort_attribute] => order }
  end
end
