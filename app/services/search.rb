class Search
  attr_reader :query, :options

  # Searchkick's search method takes 2 parameters:
  # - arg0:   a query string
  # - arg1:   an options hash
  # - return: an Searchkick::Results object which responds like an array.
  def initialize(query:, options: {})
    @query   = query.presence || "*"
    @options = options
  end

  def search
    # Base constraints
    constraints = {
      page:         options[:page],
      per_page:     10,
      highlight:    true,
      misspellings: {below: 5},
      match:        :word_middle
    }

    # Filtering and sorting
    constraints[:where] = where
    constraints[:order] = order

    # Perform the search
    search_model.search(@query, constraints)
  end

  # Provides the constant of the class that we want to search on.
  private def search_model
    raise NotImplementedError
  end

  private def where
    {}
  end

  private def order
    return {} unless options[:sort_attribute].present?

    order = options[:sort_order].presence || :asc
    { options[:sort_attribute] => order }
  end
end
