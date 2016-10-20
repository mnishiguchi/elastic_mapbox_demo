require 'test_helper'

# How to run this test:
#   bundle exec rake test TEST=test/feeds/mits_parser
describe MitsParser::Amenities do

  describe "schema example 1" do
    let(:property_hash) do
      {
        "Information" => {},
        "File" => [],
        "Amenities" => {
          "Community" => {
            "General" => [{
              "AmenityName"       => "Preferred Employer Available",
              "AmenityCharge"     => nil,
              "AmenityRank"       => nil,
              "AdditionalAmenity" => "Community Amenity"
            }, {
              "AmenityName"       => "Scenic View",
              "AmenityCharge"     => nil,
              "AmenityRank"       => nil,
              "AdditionalAmenity" => "Community Amenity"
            }]
          },
          "Floorplan" => {
            "General" => [{
              "AmenityName"       => "High Speed Access",
              "AmenityCharge"     => nil,
              "AmenityRank"       => nil,
              "AdditionalAmenity" => "Floorplan Amenity"
            }, {
              "AmenityName"       => "Elevator Access",
              "AmenityCharge"     => nil,
              "AmenityRank"       => nil,
              "AdditionalAmenity" => "Floorplan Amenity"
            }]
          }
        }
      }
    end

    let(:object) { MitsParser::Amenities.new(property_hash) }


    it "returns information in a correct format" do
      expected = [
        "Preferred Employer Available",
        "Scenic View",
        "High Speed Access",
        "Elevator Access"
      ]

      assert_equal(expected, object.amenity_names)
    end
  end


  # ---
  # ---


  describe "schema example 2" do

    let(:property_hash) do
      {
        "Information" => {},
        "File" => [],
        "Amenities" => {
          "Community" => {
            "FitnessCenter"       => "true",
            "Availability24Hours" => "true",
            "Pool"                => "false"
          },
          "Floorplan" => {
            "Handrails"  => "1",
            "WD_Hookup"  => "1",
            "WheelChair" => "0"
          },
          "General" => [{
            "AmenityName"       => "Minutes to Chevy Chase Pavilion",
            "AmenityCharge"     => nil,
            "AmenityRank"       => nil,
            "AdditionalAmenity" => "Community Amenity"
          }, {
            "AmenityName"       => "Alcove",
            "AmenityCharge"     => nil,
            "AmenityRank"       => nil,
            "AdditionalAmenity" => "Community Amenity"
          }]
        }
      }
    end

    let(:object) { MitsParser::Amenities.new(property_hash) }

    it "returns information in a correct format" do
      expected = [
        "Fitness center",
        "Always available",
        "Minutes to Chevy Chase Pavilion",
        "Alcove",
        "Handrails",
        "Washer dryer hookup"
      ]

      assert_equal(expected, object.amenity_names)
    end
  end


  # ---
  # ---


  describe "schema example 3" do

    let(:property_hash) do
      {
        "Utility" => {
            "AirCon"            => "True",
            "BroadbandInternet" => "True",
            "Cable"             => "True",
            "Electric" => "False",
            "Gas"      => "False",
            "Heat"     => "False"
        }
      }
    end

    let(:object) { MitsParser::Amenities.new(property_hash) }

    it "returns information in a correct format" do
      expected = [ "Air con", "Broadband internet", "Cable"]

      assert_equal(expected, object.amenity_names)
    end
  end
end
