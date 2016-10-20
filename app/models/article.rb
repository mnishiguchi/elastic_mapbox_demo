class Article < ApplicationRecord

  include Elasticsearch::Model

  # Ensures that Elasticsearch indexes are updated when a record is created or updated.
  include Elasticsearch::Model::Callbacks

  # Set up index_name and document_type
  # ---
  # Let's standardize on:
  #  - the index_name with the application name and
  #  - the document type with a model name
  index_name Rails.application.class.parent_name.underscore
  document_type self.name.underscore

  # Tell Elasticsearch how we want to index our data for this model.
  # ---
  # We can also specify field types here.
  # Elasticsearch supports various types.
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html
  settings index: { number_of_shards: 1 } do
    mapping dynamic: false do
      indexes :title, analyzer: 'english'
      indexes :body, analyzer: 'english'
    end
  end

  # If we don't need to store/index on Elasticsearch, we could:
  # - override the default as_indexed_json method
  # - choose which fields are included in the JSON representation of a record that is sent to ES.
  def as_indexed_json(options = nil)
    self.as_json(only: [:title, :body])
  end

  # Spawns requests to Elasticsearch:
  # - calling the Elasticsearch cluster and
  # - sending it our query written as a Ruby Hash.
  # NOTE: This methods returns Elasticsearch::Model::Response (not ActiveRecord::Relation)
  def self.search(query)
    # Implement this with Elasticsearch Query DSL.
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['title^5', 'body']
          }
        },
        highlight: {
          pre_tags: ['<mark>'],
          post_tags: ['</mark>'],
          fields: {
            title: {},
            body: {},
          }
        },
        suggest: {
          text: query,
          title: {
            term: {
              size: 1,
              field: :title
            }
          },
          body: {
            term: {
              size: 1,
              field: :body
            }
          }
        }
      }
    )
  end

end
