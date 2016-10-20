# Represents the identification related fields of a mits feed.
class MitsParser::Identification
  include MitsParser::Mixin

  cattr_accessor :paths

  def initialize(property_hash)
    @property_hash = property_hash
  end

  @@paths = {
    unique_feed_identifiers: [
      %w(Identification IDValue),
      %w(Identification IDType),
      %w(PropertyID Identification PrimaryID),
      %w(Identification PrimaryID),
      %w(Identification SecondaryID),
      %w(Identification IDValue),
      %w(PropertyID Identification Array IDValue),
    ],
    names: [
      %w(Identification MarketingName),
      %w(PropertyID Identification MarketingName),
      %w(PropertyID MarketingName),
      %w(Identification MSA_Name),
      %w(Identification MSA_Number),
      %w(Identification OwnerLegalName),
    ],
    urls:  [
      %w(Identification Website),
      %w(Identification General_ID ID),
      %w(Information DirectionsURL),
      %w(Information FacebookURL),
      %w(Information ListingImageURL),
      %w(Information PropertyAvailabilityURL),
      %w(Information VideoURL),
      %w(PropertyID Identification BozzutoURL),
      %w(PropertyID Identification WebSite),
      %w(PropertyID WebSite),
      %w(Payment CheckPayable),
      %w(Floorplan Amenities General),
    ],
    emails: [
      %w(PropertyID Address Lead2LeaseEmail),
      %w(PropertyID Address Email),
      %w(Identification Email),
      %w(OnSiteContact Email),
    ],
    phones: [
      %w(Identification Phone Number),
      %w(Identification Phone Array),
      %w(Identification Phone Array Number),
      %w(Identification Fax Number),
      %w(PropertyID Phone PhoneNumber),
      %w(OnSiteContact Phone Number),
    ]
  }

  def names
    @names ||= dig_all(@property_hash, *@@paths[:names])
  end

  def urls
    @urls ||= dig_all(@property_hash, *@@paths[:urls])
  end

  def emails
    @emails ||= dig_all(@property_hash, *@@paths[:emails])
  end

  def phones
    @phones ||= dig_all(@property_hash, *@@paths[:phones])
  end

  def unique_feed_identifiers
    @unique_feed_identifiers ||= dig_all(@property_hash, *@@paths[:unique_feed_identifiers])
  end
end
