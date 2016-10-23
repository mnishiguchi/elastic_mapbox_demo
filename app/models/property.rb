# == Schema Information
#
# Table name: properties
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :text
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
  searchkick

  belongs_to :management
  has_many :floorplans


  # Allows us to control what data is indexed for searching.
  # https://github.com/ankane/searchkick#indexing
  # NOTE: We need to reindex after making changes to the search attributes.
  def search_data
    search_attributes = {
      name:        name,
      description: description,
      address:     address,
      city:        city,
      state:       state,
      zip:         zip,
    }

    relational = {
      management_name:        management.name,
      floorplan_descriptions: floorplans.map(&:description),
    }

    search_attributes.merge!(relational)
  end

  def full_address
    "#{address}, #{city}, #{state} #{zip}"
  end
end
