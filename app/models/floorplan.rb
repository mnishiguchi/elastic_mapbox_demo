# == Schema Information
#
# Table name: floorplans
#
#  id             :integer          not null, primary key
#  name           :string
#  description    :text
#  rent           :integer
#  bathroom_count :integer
#  bedroom_count  :integer
#  property_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Floorplan < ApplicationRecord
  searchkick

  belongs_to :property

  before_save :update_property_rent_minmax


  def update_property_rent_minmax
    property.update_rent_minmax(self.rent)
  end

  # Allows us to control what data is indexed for searching.
  # https://github.com/ankane/searchkick#indexing
  # NOTE: We need to reindex after making changes to the search attributes.
  def search_data
    search_attributes = {
      name:            name,
      description:     description,
      rent:            rent,
      bathroom_count:  bathroom_count,
      bedroom_count:   bedroom_count,
    }

    relational = {
      property_state:  property.state,
      property_city:   property.city,
      property_zip:    property.zip,
    }

    search_attributes.merge!(relational)
  end
end
