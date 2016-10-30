# == Schema Information
#
# Table name: properties
#
#  id                :integer          not null, primary key
#  name              :string
#  description       :text
#  formatted_address :string
#  address           :string
#  city              :string
#  county            :string
#  state             :string
#  zip               :string
#  country           :string
#  latitude          :float
#  longitude         :float
#  amenities         :json
#  pet               :json
#  rent_min          :integer
#  rent_max          :integer
#  management_id     :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Property < ApplicationRecord

  searchkick locations: ["location"]

  belongs_to :management
  has_many :floorplans

  # Convert full address to lnglat automatically.
  # https://github.com/alexreisner/geocoder
  geocoded_by :full_address
  after_validation :geocode, :format_address

  # Allows us to control what data is indexed for searching.
  # https://github.com/ankane/searchkick#indexing
  # NOTE: We need to reindex after making changes to the search attributes.
  def search_data
    slice = [
      :state,
      :city,
      :formatted_address,
    ]
    merge = {
      # https://github.com/ankane/searchkick#geospatial-searches
      location: { lat: latitude, lon: longitude },
      floorplan_bedroom_count:  floorplans&.map(&:bedroom_count).uniq.sort,
      floorplan_bathroom_count: floorplans&.map(&:bathroom_count).uniq.sort,
    }
    attributes.symbolize_keys.slice(*slice).merge(merge)
  end


  def rent_minmax_text
    "$#{rent_min} - #{rent_max}"
  end


  def lng_lat
    [ longitude, latitude ]
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


  private def full_address
    "#{address}, #{city}, #{state} #{zip}"
  end


  # A before-filter to clean up address string with geocoder.
  private def format_address
    # https://github.com/alexreisner/geocoder
    results = Geocoder.search(full_address)
    return full_address if results.empty?

    self.formatted_address = results.first&.formatted_address
    self.state      = results.first&.state if results.first&.state
    self.state_code = results.first&.state_code if results.first&.state_code
  end
end
