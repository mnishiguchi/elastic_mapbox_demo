# Represents a set of properties data.
class MitsParser::Properties
  # This is the interface with the rest of our application.
  # - param feed_hash - a single hash that wraps a whole feed, which typically
  # has the "Property" key.
  # - return - an array of property hashes that are formatted in our schema.
  # ---
  # Usage: MitsParser::Properties.parse(feed_hash)
  def self.parse(feed_hash)
    properties_array = feed_hash["Property"] || []
    properties_array.map { |property| MitsParser::Property.new(property).parse }
  end
end


# ---
# ---


# Converts a property hash into our standardized format.
class MitsParser::Property
  include MitsParser::Mixin

  def initialize(property_hash)
    @property_hash = property_hash
    assign_attributes
    determine_floorplans_and_photos
  end

  # Build a formatted hash for this instance.
  def parse
    {
      raw_hash:                @property_hash,
      floorplans:              @floorplans.formatted_hash_array,

      unique_feed_identifiers: @identification.unique_feed_identifiers,
      names:                   @identification.names,
      urls:                    @identification.urls,
      emails:                  @identification.emails,
      phones:                  @identification.phones,

      descriptions:            @information.descriptions,
      lease_length_max:        @information.lease_length[:max],
      lease_length_min:        @information.lease_length[:min],
      office_hours:            @information.office_hours,
      parking:                 @information.parking,

      address:                 @location.street,
      city:                    @location.city,
      county:                  @location.county,
      zip:                     @location.zip,
      po_box:                  @location.po_box,
      country:                 @location.country,
      state:                   @location.state,
      longitude:               @location.longitude,
      latitude:                @location.latitude,

      photo_urls:              @photo_urls,
      pet_policy:              @policy.formatted_hash,

      # Might be able to do searches in here similar to the lease length operation
      promotional_info:        @information.promotional,
      amenities:               @amenities.amenity_names || [],
      information:             @others.other_information,
    }
  end

  private

    def assign_attributes
      # These are wrapper objects for each field. They process the property_hash
      # into our standardized format.
      @amenities      = MitsParser::Amenities.new(@property_hash)
      @identification = MitsParser::Identification.new(@property_hash)
      @information    = MitsParser::Information.new(@property_hash, @amenities)
      @location       = MitsParser::Location.new(@property_hash)
      @policy         = MitsParser::Policy.new(@property_hash)
      @floorplans     = MitsParser::Floorplans.new(@property_hash)
      @others         = MitsParser::Others.new(@property_hash)
    end

    # Allocates photos to appropriate floorplans.
    # Returns the remaining photos, which are to be property photos.
    def determine_floorplans_and_photos
      photo = MitsParser::Photos.new(@property_hash, @floorplans)
      photo.add_photos_to_best_floorplan!
      @photo_urls = photo.property_photo_urls
    end
end
