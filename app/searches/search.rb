# # The Search class is a base class for all the ElasticSearch searches. It holds
# # common behavior of searches.
# class Search
#   attr_reader :query, :options
#
#   # - return: an Searchkick::Results object which responds like an array.
#   def initialize(query:, options: {})
#     @query   = query.presence || "*"
#     @options = options
#   end
#
#   # A wrapper of Searchkick's search method. We configure common behavior of
#   # all the searches here.
#   # - arg0:   a query string
#   # - arg1:   an options hash
#   def search
#     # Invoke Searchkick's search method with our search constraints.
#     search_model.search(@query, search_constraints)
#   end
#
#   # Provides the constant of the class that we want to search on.
#   private def search_model
#     raise NotImplementedError
#   end
#
#   private def search_constraints
#     {
#       where: where,
#       order: order,
#     }
#   end
#
#   private def where
#     {}
#   end
#
#   private def order
#     return {} unless options[:sort_attribute].present?
#
#     order = options[:sort_order].presence || :asc
#     { options[:sort_attribute] => order }
#   end
#
# end
