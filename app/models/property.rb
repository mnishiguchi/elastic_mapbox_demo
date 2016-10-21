# == Schema Information
#
# Table name: properties
#
#  id            :integer          not null, primary key
#  name          :string
#  address       :string
#  city          :string
#  county        :string
#  state         :string
#  zip           :string
#  country       :string
#  latitude      :float
#  longitude     :float
#  management_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Property < ApplicationRecord
  searchkick word_middle: [
    :name  
  ]

  belongs_to :management
  has_many :floorplans

  # Tells Searchkick which columns we want it to use in searches other than
  # the attributes on the model itself.
  # ---
  # NOTE:
  # - The purpose of these indices is for searching, not for data management.
  # - We need reindex after making changes to the search attributes so that
  # ElasticSearch can get notified of the changes.
  def search_data
    attrs = attributes.dup
    relational = {
      management_name:        management.name,
      floorplan_names:        floorplans.map(&:name),
      floorplan_descriptions: floorplans.map(&:description),
      floorplan_rents:        floorplans.map(&:rent),
    }
    attrs.merge!(relational)
  end
end
