# Represents a collection of floorplans.
class MitsParser::Floorplans
  include MitsParser::Mixin

  def initialize(property_hash)
    @property_hash = property_hash
    set_data
  end

  # Returns an Array of hashes.
  def formatted_hash_array
    @formatted_hash_array ||= objects.map(&:formatted_hash)
  end

  # Returns an Array of Floorplan objects.
  def objects
    @objects ||= @raw_floorplans_array.map { |floorplan_hash| MitsParser::Floorplan.new(floorplan_hash) }
  end

  # Return true if File node exists within Property node.
  def has_file_within?
    file = deep_find_first(@raw_floorplans_array.first, MitsParser::Photos.node_names)
    !!file && (file.size > 0)
  end

  private

    def set_data
      @raw_floorplans_array = deep_find_all(@property_hash, ["Floorplan"])
    end
end


# ---
# ---


# Represents an individual floorplan.
# Photos are assigned here if this floorplan has a File node within. Otherwise,
# we leave the photo_url_urls field empty and the Photo class can handle it by
# doing similarity analysis.
class MitsParser::Floorplan
  include MitsParser::Mixin

  attr_reader :raw_floorplan_hash

  def initialize(floorplan_hash)
    @raw_floorplan_hash = floorplan_hash
    @photo_urls         = []
  end

  # Build a formatted hash for this instance.
  def formatted_hash
    @formatted_hash ||= {
      ## Feed Data stuff
      raw_hash:                  @raw_floorplan_hash,
      unique_feed_identifiers:   identification[:ids],

      ## Has One to Has One
      name:                      identification[:name],

      # Integers
      deposit:                   deposit,

      # These integers should be ignored if they are zero -
      # this concern might have to be worked out a bit better
      unit_count:                units[:count],
      units_available_today:     units[:available_today],
      units_available_one_month: units[:available_one_month],
      units_available_two_month: units[:available_two_month],
      total_room_count:          total_room_count,
      bathroom_count:            room_count[:bathrooms],
      bedroom_count:             room_count[:bedrooms],
      square_feet_min:           square_feet[:min],
      square_feet_max:           square_feet[:max],
      rent_max:                  rent[:max],
      rent_min:                  rent[:min],

      photo_urls:                photo_urls,

      ## Has Many to Has One
      descriptions:              descriptions,

      ## Has Many to Has Many
      amenities:                 amenities,
    }
  end

  # Adds a passed-in url to this floorplan.
  def add_photo_url(photo_url)
    @photo_urls << photo_url
  end

  # Returns a hash.
  def identification
    @identification ||= begin
      ids  = deep_find_all(@raw_floorplan_hash, ["id", "Id", "IDValue", "AffiliateID"])
      name = deep_find_all(@raw_floorplan_hash, ["name", "Name"]).first

      { ids: ids, name: name }
    end
  end

  private

    # Return an array of amenity names within this floorplan.
    # NOTE: Disabled items are ignored.
    def amenities
      data = deep_find_all(@raw_floorplan_hash, [:amenities, "Amenities"])
      amenities_hash = data.reduce(Hash.new, :merge)
      return [] unless amenities_hash&.is_a?(Hash)

      if amenities_hash.values.first.to_s =~ TRUE_FALSE_REGEX
        # Extract from the hash amenity name keys whose values are true-ish string.
        amenities_hash.select { |k, v| v.to_s  =~ TRUE_REGEX }.keys
      else
        []
      end
    end


    # Returns a hash.
    def units
      @units ||= begin
        count                = deep_find_first(@raw_floorplan_hash, ["UnitCount"])
        available_today      = deep_find_first(@raw_floorplan_hash, ["UnitsAvailable"])
        available_one_month  = deep_find_first(@raw_floorplan_hash, ["UnitsAvailable30Days"])
        available_two_month  = deep_find_first(@raw_floorplan_hash, ["UnitsAvailable60Days"])

        {
          count:               s_to_i(count),
          available_today:     s_to_i(available_today),
          available_one_month: s_to_i(available_one_month),
          available_two_month: s_to_i(available_two_month),
        }
      end
    end

    # Returns a hash.
    def descriptions
      data = dig_all(@raw_floorplan_hash, %w(Comment), %w(Concession Description), %w(Amenities General))

      # Convert all the extra whitespace into one space.
      data = data.map { |k, v| [ k, v.squish ] }.to_h if data.is_a?(Hash)
    end

    # Obtain all photo_urls nested within this floorplan.
    def photo_urls
      deep_find_all(@raw_floorplan_hash, MitsParser::Photos.node_names)
    end

    def room_count
      @room_count ||= begin
        # Default values
        room_count_hash = { bedrooms: nil, bathrooms: nil }

        rooms = deep_find_all(@raw_floorplan_hash, brute_force_keys("room")).compact
        if rooms.present?
          # Pattern A: hash arrays in the "Room" node.
          rooms.map do |room|
            data = room.to_a.flatten.compact.map(&:underscore)
            if data.include?("bedroom")
              room_count_hash[:bedrooms] = s_to_i(data.join(''))
            elsif data.include?("bathroom")
              room_count_hash[:bathrooms] = s_to_i(data.join(''))
            end
          end
        else
          # Pattern B: string values in the "Bathrooms" and "Bedrooms" nodes.
          bedrooms  = deep_find_first(@raw_floorplan_hash, brute_force_keys("bedroom"))
          bathrooms = deep_find_first(@raw_floorplan_hash, brute_force_keys("bathroom"))
          room_count_hash[:bedrooms]  = s_to_i(bedrooms) if bedrooms.present?
          room_count_hash[:bathrooms] = s_to_i(bathrooms) if bathrooms.present?
        end

        room_count_hash
      end
    end

    # Return an interger if total count was able to be obtained, else nil.
    def total_room_count
      count = deep_find_first(@raw_floorplan_hash, ["TotalRoomCount"])
      if count.present?
        s_to_i(count)
      else
        return if !room_count.values.all?
        room_count.values.reduce(:+)
      end
    end

    # Return an interger if deposit was able to be obtained, else nil.
    def deposit
      data = deep_find_first(@raw_floorplan_hash, ["Deposit"])
      return unless data

      case data
      when Hash
        data = deep_find_first(data, ["Exact", "Amount"])
        s_to_i(data.to_s)
      when String
        s_to_i(data)
      end
    end

    # Return an interger if values were able to be obtained, else nil.
    def square_feet
      data   = deep_find_all(@raw_floorplan_hash, ["SquareFeet"])
      return { min: nil, max: nil } unless data

      minmax = minmax_from_hash_array(data)
      { min: minmax[0], max: minmax[1], }
    end

    # Return an interger if values were able to be obtained, else nil.
    def rent
      data   = deep_find_all(@raw_floorplan_hash, ["MarketRent", "EffectiveRent"])
      return { min: nil, max: nil } unless data

      minmax = minmax_from_hash_array(data)
      { min: minmax[0], max: minmax[1], }
    end
end
