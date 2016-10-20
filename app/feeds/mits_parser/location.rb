# Represents the location related fields of a mits feed.
class MitsParser::Location
  include MitsParser::Mixin

  cattr_accessor :paths

  def initialize(property_hash)
    @property_hash = property_hash
    set_data
  end

  def longitude
    @longitude ||= begin
      value = deep_find_first(@property_hash, ["Longitude"]).to_f
      value == 0 ? nil : value
    end
  end

  def latitude
    @latitude ||= begin
      value  = deep_find_first(@property_hash, ["Latitude"]).to_f
      value == 0 ? nil : value
    end
  end

  def street
    @street ||= deep_find_first(@address, ["Address", "Address1"]) || ""
  end

  def city
    @city ||= deep_find_first(@address, ["City"]) || ""
  end

  def county
    @county ||= deep_find_first(@address, ["County", "CountyName"]) || ""
  end

  def zip
    @zip ||= begin
      data = deep_find_first(@address, ["Zip", "PostalCode"]) || ""
      data.to_s  # Coerce it to string in case that the value is integer.
    end
  end

  def po_box
    @po_box ||= deep_find_first(@address, ["PO_Box"]) || ""
  end

  def country
    @country ||= deep_find_first(@address, ["Country"]) || "USA"
  end

  def state
    @state ||= deep_find_first(@address, ["State"]) || ""
  end

  private

    def set_data
      @address = dig(@property_hash, ["Identification", "Address"])
    end

    @@paths = {
        latitude: [
          %w(Identification Latitude),
          %w(ILS_Identification Latitude),
          %w(PropertyID Identification Latitude)
        ],
        longitude: [
          %w(Identification Longitude),
          %w(ILS_Identification Longitude),
          %w(PropertyID Identification Longitude)
        ],
        address: [
          %w(Identification Address Address1),
          %w(Identification Address ShippingAddress),
          %w(Identification Address MailingAddress),
          %w(PropertyID Address Address),
          %w(PropertyID Address Address1),
        ],
        city:    [
          %w(Identification Address City),
          %w(PropertyID Address City),
        ],
        county:  [
          %w(PropertyID Address CountyName),
        ],
        zip:     [
          %w(Identification Address Zip),
          %w(PropertyID Address Zip),
        ],
        po_box:  [
          %w(Identification Address PO_Box),
        ],
        country: [
          %w(Identification Address Country),
        ],
        state:   [
          %w(Identification Address State),
        ],
      }
end
