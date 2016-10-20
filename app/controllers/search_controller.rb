class SearchController < ApplicationController

  def search
    # Just call our Page.search method.
    # Ensure the controller doesn't fail if the search form is submitted empty.
    @results = Article.search(params[:query]) unless params[:query].blank?

    # NOTE: It is important to have our view support both
    # Elasticsearch::Model::Response and ActiveRecord::Relation.
    # Assuming that the results from Elasticsearch/ActiveRecord are stored in
    # the @results variable, we will always need to run
    # @results.respond_to?(:es_method) and verify that the Elasticsearch method
    # exists before we call it.
  end
end
