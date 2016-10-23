# The Search class is a base class for all the ElasticSearch searches. It holds
# common behavior of searches.
class Search
  attr_reader :query, :options

  # Takes information that Searchkick's search method requires.
  # - arg0:   a query string
  # - arg1:   an options hash
  # - return: an Searchkick::Results object which responds like an array.
  def initialize(query:, options: {})
    @query   = query.presence || "*"
    @options = options
  end

  # A wrapper of Searchkick's search method. We configure common behavior of
  # all the searches here.
  def search
    search_model.search(@query, {
      page:         options[:page],
      per_page:     10,
      misspellings: { below: 5 },
      match:        :word_middle,
      where:        where,
      order:        order
    })
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

  # Usage:
  #   boost_by: [:orders_count]              # give popular documents a boost
  #   boost_by: {orders_count: {factor: 10}} # default factor is 1
  # NOTE: field must be numeric
  # private def boost_by
  #   []
  # end
end
