# Represents a collection of photos of a mits feed.
# ---
# NOTE: This class is dependent on the MitsParser::Floorplans class.
# Therefore when we make changes in MitsParser::Floorplans may break code in this class.
class MitsParser::Photos
  include MitsParser::Mixin

  cattr_accessor :node_names

  def initialize(property_hash, floorplans)
    @property_hash       = property_hash
    @floorplans          = floorplans
    @property_photo_urls = []
    set_data
  end

  @@node_names = [
    "File",
    "PhotoSet",
    "SlideshowImageURL",
    "ImageURL"
  ]

  MIN_SCORE_TO_ASSOCIATE_PHOTO_TO_FLOORPLAN = 1

  # Returns an Array of Photo objects.
  def objects
    @objects ||= @raw_photos_array.map { |photo_hash| MitsParser::Photo.new(photo_hash) }
  end

  # Adds photos to best matching floorplan's hash if any matching floorplan was
  # found. Returns the object itself.
  def add_photos_to_best_floorplan!

    # Ignore if File node is nested within Floorplan because MitsParser::Floorplan
    # can handle that case.
    unless @floorplans.has_file_within?

      objects.each do |photo|

        best_floorplan = best_floorplan_for_photo(photo)

        if should_add_to_floorplan?(best_floorplan)
          add_photo_url_to_best_floorplan(photo, best_floorplan)
        else
          add_photo_url_to_property(photo)
        end
      end
    end

    self
  end

  def property_photo_urls
    @property_photo_urls
  end

  private

    def set_data
      @floorplans_array = @floorplans.formatted_hash_array
      @raw_photos_array = deep_find_all(@property_hash, MitsParser::Photos.node_names)
    end

    # Finds a best matching floorplan for a given photo.
    # Returns a hash of best floorplan object and its score.
    def best_floorplan_for_photo(photo)
      raise ArgumentError.new("photo must be a hash") unless photo.is_a?(MitsParser::Photo)

      # Default values
      best_floorplan_hash = { score: 0, object: nil }

      # Iterate over all floorplan objects, evaluate similarity against the specified photo.
      @floorplans.objects.each do |floorplan|
        similarity = floorplan_photo_similarity(floorplan, photo)
        if similarity.to_f > best_floorplan_hash[:score]
          best_floorplan_hash[:score]  = similarity
          best_floorplan_hash[:object] = floorplan
        end
      end

      best_floorplan_hash
    end

    # Takes in a best floorplan hash and determine whether we should add the
    # photo in question to that floorplan.
    def should_add_to_floorplan?(best_floorplan)
      MIN_SCORE_TO_ASSOCIATE_PHOTO_TO_FLOORPLAN <= best_floorplan[:score]
    end

    # Takes in a Photo object and best floorplan hash.
    # Converts the Photo into URL and adds it to the specified floorplan.
    def add_photo_url_to_best_floorplan(photo, best_floorplan)
      raise ArgumentError.new("photo must be a MitsParser::Photo") unless photo.is_a?(MitsParser::Photo)
      raise ArgumentError.new("best_floorplan must be a hash") unless best_floorplan.is_a?(Hash)

      best_floorplan[:object].add_photo_url(photo.raw_photo_hash.to_s[URI.regexp])
    end

    # Takes in a Photo.
    # Converts the Photo into URL and store it in an instance variable.
    def add_photo_url_to_property(photo)
      raise ArgumentError.new("photo must be a MitsParser::Photo") unless photo.is_a?(MitsParser::Photo)

      @property_photo_urls << photo.raw_photo_hash.to_s[URI.regexp]
    end

    # FIXME: improve this.
    # Analyze the similarity of floorplan and photo based on identification meta-data.
    # Returns a score in integer.
    def floorplan_photo_similarity(floorplan, photo)
      raise ArgumentError.new("floorplan must be a MitsParser::Floorplan") unless floorplan.is_a?(MitsParser::Floorplan)
      raise ArgumentError.new("photo must be a MitsParser::Photo") unless photo.is_a?(MitsParser::Photo)

      photo_ids     = photo.identification.values.flatten
      floorplan_ids = floorplan.identification.values.flatten

      intersection  = photo_ids & floorplan_ids

      intersection.size
    end
end


# ---
# ---


# Represents a single photo.
class MitsParser::Photo
  include MitsParser::Mixin

  attr_reader :ids, :type, :name, :raw_photo_hash

  def initialize(photo_hash)
    @raw_photo_hash = photo_hash
  end

  def identification
    @identification ||= begin
      {
        :ids  => deep_find_all(@raw_photo_hash, ["id", "Id", "IDValue", "AffiliateID", "FileID"]),
        :name => deep_find_all(@raw_photo_hash, ["name", "Name"]),
        :type => deep_find_all(@raw_photo_hash, ["Type"]),
      }
    end
  end
end
