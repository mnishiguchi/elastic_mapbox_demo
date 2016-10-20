# Represents the information related fields of a mits feed.
class MitsParser::Information
  include MitsParser::Mixin

  cattr_accessor :paths

  # NOTE: Because some feeds have parking information within Information node and
  # and others within Amenities node, we provide this class with a reference to
  # the MitsParser::Amenities object. We explicitly pass a MitsParser::Amenities
  # object into it when instantiating a MitsParser::Information class.
  def initialize(property_hash, amenities)
    @property_hash = property_hash
    @amenity_names = amenities.amenity_names
  end

  @@paths = {
      descriptions: [
        %w(Information LongDescription),
        %w(Information NeighborhoodText),
        %w(Information OverviewBullet1),
        %w(Information OverviewBullet2),
        %w(Information OverviewBullet3),
        %w(Information OverviewText),
        %w(Information OverviewTextStripped),
        %w(Information ShortDescription),
      ],
      lease_length: [
        %w(Information LeaseLength),
      ],
      promotional: [
        %w(Promotional),
        %w(Promotional Array),
      ],
      parking: [
        %w(Information Parking),
      ]
    }

  def promotional
    @promotional  ||= dig_or_default(@property_hash, "", *@@paths[:promotional])
  end

  def descriptions
    @descriptions ||= dig_all(@property_hash, *@@paths[:descriptions])
  end

  def lease_length
    @lease_length ||= begin
      lease_length = deep_find_all(@property_hash, ["LeaseLength", "LeaseTerm"])

      minmax = [nil, nil]
      case lease_length
      when Hash
        minmax = minmax_from_hash(lease_length)
      when Array
        minmax = minmax_from_hash_array(lease_length)
      end
      { min: minmax[0], max: minmax[1] }
    end
  end

  def parse_date(string_time)
    return string_time if ["Closed", "By Appointment Only"].include?(string_time)
    Time.parse(string_time).strftime("%R")
  end

  def office_hours
    @office_hours ||= begin
      raw_office_hours_data = deep_find_all(@property_hash, ["OfficeHour"])

      @office_hours = {}.tap do |office_hour_hash|
        raw_office_hours_data.each do |office_hour_day|
          day = office_hour_day["Day"].downcase
          day = transform_day_string(day) if transform_day_string(day)
          office_hour_hash[day] = {
            open:  parse_date(office_hour_day["OpenTime"]),
            close: parse_date(office_hour_day["CloseTime"])
          }
        end
      end
    end
  end

  def parking
    @parking ||= begin
      # Pattern A:
      # - at: //Information//Parking
      # - typically a hash.
      # ---
      # Pattern B:
      # - at: //Amenities//*
      # - strings that contain the word 'parking' in a hash value.
      # ---
      # Pattern C:
      # - at: //Feature
      # - strings that contain the word 'parking' in an HTML string.
      raw_parking_hash_array = deep_find_all(@property_hash, ["Parking"])
      raw_feature_hash_array = deep_find_all(@property_hash, ["Feature"])

      if raw_parking_hash_array.present?
        raw_parking_hash_array
      elsif raw_feature_hash_array.present?
        parking_features = raw_feature_hash_array.map(&:values).flatten.map do |desc|
          # Parse the HTML by Nokogiri and extract strings that contain "parking".
          nokogiri = Nokogiri::HTML(desc.downcase).xpath('//*[contains(text(), "parking")]')
          next unless nokogiri

          # Here we extract a string between HTML tags.
          # NOTE: Sometimes space characters exist.
          items = nokogiri.to_s.match(/>\W*.*parking.*\W*</i).to_a
          items.map { |item| item && item.delete("<").delete(">").squish }
        end.flatten
      else
        # Extract amenity names that contain "parking".
        parking_amenities = @amenity_names.select { |name| name =~ /parking/i }
      end
    end
  end
end
