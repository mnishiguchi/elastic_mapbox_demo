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
#  amenities     :json
#  pet           :json
#  rent_min      :integer
#  rent_max      :integer
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
      rent_min:    rent_min,
      rent_max:    rent_max,
      amenities:   amenities,
      pet:         pet,
    }

    relational = {
      management_name:          management.name,
      floorplan_descriptions:   floorplans.map(&:description),
      floorplan_bedroom_count:  floorplans.map(&:bedroom_count),
      floorplan_bathroom_count: floorplans.map(&:bathroom_count),
    }

    search_attributes.merge!(relational)
  end

  def full_address
    "#{address}, #{city}, #{state} #{zip}"
  end

  # Invoked when a Floorplan is updated.
  def update_rent_minmax(rent)
    return if rent.nil?

    if self.rent_min.nil? || rent.to_i < self.rent_min.to_i
      update(rent_min: rent)
    end

    if rent.to_i > self.rent_max.to_i
      update(rent_max: rent)
    end
  end
end
