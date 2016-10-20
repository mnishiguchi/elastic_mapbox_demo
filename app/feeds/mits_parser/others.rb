# Represents all the other information than we extracted.
# ---
# NOTE: None the data fields will be transformed.
class MitsParser::Others
  include MitsParser::Mixin

  cattr_accessor :paths

  def initialize(property_hash)
    @property_hash = property_hash
  end

  def other_information
    @other_information ||= begin
      dig_all(@property_hash, *@@paths[:other_information])
    end
  end

  # Determine paths for other information, then dig_all
  @@paths = {
      other_information: [
        %w(Accounting),
        %w(Concession),
        %w(Feature),
        %w(FeaturedButton),
        %w(Fee),
        %w(Information DrivingDirections),
        %w(Information Rents),
        %w(Information Services),
        %w(Information StartRent),
        %w(Information StructureType),
        %w(Information TwitterHandle),
        %w(Information UnitCount),
        %w(Information VideoURL),
        %w(Information YearBuilt),
        %w(Information YearRemodeled),
        %w(Information BuildingCount),
        %w(Information NumberOfAcres),
        %w(NearbyCommunity Array Name),
        %w(Payment CheckPayable),
        # %w(_),
        # %w(_),
      ]
    }
end
