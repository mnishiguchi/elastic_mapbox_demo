# This class represents the //Property/Amenities node, in which we assume that
# there can be Community, Floorplan and General sub-nodes. Since some schemas
# have Utility node that is very similar to Amenitites, we handle Utility node here.
class MitsParser::Amenities
  include MitsParser::Mixin

  def initialize(property_hash)
    @property_hash = property_hash
    set_data
  end

  # Returns an array of all the amenity name strings.
  def amenity_names
    @amenity_names ||= (community + general + floorplans + utility).uniq
  end

  private

    def set_data
      @raw_amenities_data = deep_find_first(@property_hash, ["Amenities"]) || []
      @raw_utility_data = deep_find_first(@property_hash, ["Utility"]) || []
    end

    # Deals with the "//Amenities[]//community" node
    # Returns an Array of Strings.
    def community
      @community ||= begin
        # Find information and coerce format. We assume hash is really a Hash.
        raw_hash = deep_find_first(@raw_amenities_data, ["Community"])
        transformed = transform_hash(raw_hash, TRANSFROM)
        amenity_name_strings(transformed)
      end
    end

    # Deals with the "//Amenities[]//Floorplan" node
    # Returns an Array of Strings.
    def floorplans
      @floorplans ||= begin
        # Find information and coerce format. We assume hash is really a Hash.
        raw_hash    = deep_find_first(@raw_amenities_data, ["Floorplan"])
        transformed = transform_hash(raw_hash, TRANSFROM)
        amenity_name_strings(transformed)
      end
    end

    # Deals with the "//Amenities[]/General" node
    # Returns an Array of Strings.
    def general
      @general ||= begin
        result = []

        # Find information and coerce format. We assume hash is really a Hash.
        if (general = @raw_amenities_data.is_a?(Hash) && @raw_amenities_data.fetch("General", []))
          if general.is_a?(Array)
            general.each do |hash|
              hash = transform_hash(hash, TRANSFROM)
              result << amenity_name_strings(hash)
            end
          elsif general.is_a?(Hash)
            hash = transform_hash(hash, TRANSFROM)
            result << amenity_name_strings(hash)
          end
        end

        result.flatten
      end
    end

    # Deals with the "//Utility" node
    # Returns an Array of Strings.
    def utility
      @utility ||= begin
        hash = transform_hash(@raw_utility_data, TRANSFROM)
        amenity_name_strings(hash)
      end
    end

    # Extract AmenityName strings from a hash.
    # hash must be general, communuty or floorplans within the Amenity node.
    # Return an Array of Strings.
    def amenity_name_strings(hash)
      raise ArgumentError.new("hash must be a hash") unless hash.is_a?(Hash)

      if hash.key?(:general)
        # A hash with the ":general" key which has array of amenity hashes.
        # e.g., { general: [ { "AmenityName" => "Awesome room", ... }, { "AmenityName" => "Awesome parking", ... } ] }
        hash[:general].map { |hash| deep_find_all(hash, ["AmenityName"]) }.flatten
      elsif hash.key?(:amenity_name)
        # e.g., { "AmenityName" => "Awesome room", ... }
        Array(hash[:amenity_name])
      elsif hash.values.first.to_s =~ TRUE_FALSE_REGEX
        # A hash of key to boolean.
        # e.g., { "AirCon" => true, "Cable" => false, ... }
        # We extract amenity names with the boolean true.
        hash.select { |_, bool| bool }.keys.map(&:to_s).map(&:humanize)
      else
        []  # Invalid hash was passed in. Most likely it was {}.
      end
    end

    TRANSFROM = {
      keys: {
        "Availability24Hours" => "AlwaysAvailable",
        "Available24Hours"    => "AlwaysAvailable",
        "WD_Hookup"           => "WasherDryerHookup"
      },
      values: BOOLEAN_STRING_MAP
    }
end
