# == Schema Information
#
# Table name: properties
#
#  id         :integer          not null, primary key
#  raw_hash   :json
#  address    :string
#  city       :string
#  county     :string
#  state      :string
#  zip        :string
#  country    :string
#  latitude   :float
#  longigute  :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Property < ApplicationRecord
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
      indexes :zip, analyzer: 'english'
      indexes :raw_hash, analyzer: 'english'
    end
  end

  # If we don't need to store/index on Elasticsearch, we could:
  # - override the default as_indexed_json method
  # - choose which fields are included in the JSON representation of a record that is sent to ES.
  def as_indexed_json(options = nil)
    self.as_json(only: [:zip, :raw_hash])
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
            fields: ['zip^5', 'raw_hash']
          }
        },
        highlight: {
          pre_tags: ['<mark>'],
          post_tags: ['</mark>'],
          fields: {
            zip: {},
            raw_hash: {},
          }
        },
        suggest: {
          text: query,
          zip: {
            term: {
              size: 1,
              field: :zip
            }
          },
          raw_hash: {
            term: {
              size: 1,
              field: :raw_hash
            }
          }
        }
      }
    )
  end
end
