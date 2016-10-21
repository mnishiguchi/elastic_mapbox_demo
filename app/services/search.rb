class Search
  attr_reader :query, :options

  DEFAULT_PER_PAGE = 10

  # Searchkick's search method takes 2 parameters:
  # - arg0: a query string
  # - arg1: an options hash
  def initialize(query:, options: {})
    @query   = query.presence || "*"
    @options = options
  end

  def search
    constraints = {
      page:     options[:page],
      per_page: DEFAULT_PER_PAGE
    }
    constraints[:where] = where
    constraints[:order] = order

    search_class.search(@query, constraints)
  end

  # Provides the constant of the class that we want to search on.
  private def search_class
    raise NotImplementedError
  end

  private def where
    {}
  end

  private def order
    if options[:sort_attribute].present?
      order = options[:sort_order].presence || :asc
      { options[:sort_attribute] => order }
    else
     {}
    end
  end
end
