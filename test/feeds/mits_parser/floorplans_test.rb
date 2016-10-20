require 'test_helper'

# How to run this test:
#   bundle exec rake test TEST=test/feeds/mits_parser
describe MitsParser::Floorplans do

  let(:floorplans) { MitsParser::Floorplans.new(property_hash) }


  # ---
  # ---


  describe "#formatted_hash_array" do

    let(:property_hash) { eval(File.read("#{file_dir}/feed_c.rb")) }
    let(:formatted_hash_array) { floorplans.formatted_hash_array }

    it "is an Array of Hash" do
      assert(formatted_hash_array.is_a?(Array))
      assert(formatted_hash_array.first.is_a?(Hash))
    end

    it "returns information in a correct format" do
      expected_keys = [
        :raw_hash,
        :unique_feed_identifiers,
        :name,
        :deposit,
        :unit_count,
        :units_available_today,
        :units_available_one_month,
        :units_available_two_month,
        :total_room_count,
        :bathroom_count,
        :bedroom_count,
        :square_feet_min,
        :square_feet_max,
        :rent_max,
        :rent_min,
        :photo_urls,
        :descriptions,
        :amenities
      ]
      assert_equal(expected_keys, formatted_hash_array.first.keys)
    end
  end


  # ---
  # ---


  describe "#has_file_within?" do

    describe "with nested file node" do
      let(:property_hash) do
        {
          "Floorplan" => [
            {
              "File" => [ { "Name" => "a photo nested within a floorplan" } ]
            }
          ]
        }
      end

      it "returns true" do
        assert(floorplans.has_file_within? === true)
      end
    end

    describe "without nested file node" do
      let(:property_hash) do
        {
          "Floorplan" => [ {}, {} ],
          "File"      => [ { "Name" => "a photo" }, {} ]
        }
      end

      it "returns false" do
        assert(floorplans.has_file_within? === false)
      end
    end
  end


  # ---
  # ---


  describe "the photo_urls field" do

    # NOTE: Since photo urls are passed in from MitsParser::Photos object,
    # we test that process in conjunction with MitsParser::Photos in the
    # test/feeds/mits_parser/photos_test.rb file.

  end


  # ---
  # ---


  describe "the amenities field"  do

    subject { floorplans.formatted_hash_array.first[:amenities] }

    describe "with nested amenities" do
      let(:property_hash) do
        {
          "Floorplan" => [
            {
                "Amenities" => {
                  "Balcony"         => "true",
                  "CeilingFan"      => "false",
                  "Fireplace"       => "t",
                  "LargeClosets"    => "f",
                  "Patio"           => "yes",
                  "PrivateBalcony"  => "no",
                  "PrivatePatio"    => "y",
                  "WD_Hookup"       => "n",
                  "WindowCoverings" => "1",
                  "CustomAmenity"   => "0"
                }
            }
          ]
        }
      end

      let(:expected) do
        [
          "Balcony",
          "Fireplace",
          "Patio",
          "PrivatePatio",
          "WindowCoverings",
        ]
      end

      it "is an Array of amenity names" do
        assert_equal(expected, subject)
      end
    end

    describe "without nested amenities" do
      let(:floorplans) do
        MitsParser::Floorplans.new({
          "Floorplan" => [ {}, {} ],
          "Amenities" => [ {}, {} ]
        })
      end

      it "returns []" do
        assert_equal([], subject)
      end
    end
  end


  # ---
  # ---


  describe "the unique_property_hash_identifiers field" do

    subject { floorplans.formatted_hash_array[0][:unique_feed_identifiers] }

    let(:property_hash) do
      {
        "Floorplan" => [
          {
              "Name"       => "S",
              "id"         => "252047",
              "Identification" => {
                  "IDType" => "FloorPlanID",
                  "IDValue" => "12102"
              }
          }
        ]
      }
    end

    it "is an array of ids" do
      assert_equal(["252047", "12102"], subject)
    end
  end


  # ---
  # ---


  describe "the name field" do

    let(:property_hash) do
      {
        "Floorplan" => [
          { "Name" => "ABC", "id" => "252047" },
          { "Name" => "XYZ", "id" => "252392" }
        ]
      }
    end

    it "is a name string" do
      assert_equal("ABC", floorplans.formatted_hash_array[0][:name])
      assert_equal("XYZ", floorplans.formatted_hash_array[1][:name])
    end
  end


  # ---
  # ---


  describe "the deposit field" do

    let(:property_hash) do
      {
        "Floorplan" => [
            # Pattern A
            {
                "Deposit" => {
                    "type" => "security deposit", "Amount" => "100"
                }
            },
            # Pattern B
            {
                "Deposit" => {
                    "DepositType" => "Security Deposit", "Amount" => {
                        "AmountType" => "Actual", "ValueRange" => {
                            "Exact" => "$150.00"
                        }
                    }
                }
            }
        ]
      }
    end

    it "is a correct integer" do
      assert floorplans.formatted_hash_array[0][:deposit].is_a?(Integer)
      assert_equal(100, floorplans.formatted_hash_array[0][:deposit])
      assert_equal(150, floorplans.formatted_hash_array[1][:deposit])
    end
  end


  # ---
  # ---


  describe "the unit-count-related fields" do

    let(:unit_count) { floorplans.formatted_hash_array[0][:unit_count] }
    let(:units_available_today) { floorplans.formatted_hash_array[0][:units_available_today] }
    let(:units_available_one_month) { floorplans.formatted_hash_array[0][:units_available_one_month] }
    let(:units_available_two_month) { floorplans.formatted_hash_array[0][:units_available_two_month] }

    let(:property_hash) do
      {
        "Floorplan" => [{
              "UnitCount" => "77",
              "UnitsAvailable" => "5",
              "UnitsAvailable30Days" => "2",
              "UnitsAvailable60Days" => "3",
          }]
      }
    end

    it "unit_count is a correct integer" do
      assert_equal(77, unit_count)
    end

    it "units_available_today is a correct integer" do
      assert_equal(5, units_available_today)
    end

    it "units_available_one_month is a correct integer" do
      assert_equal(2, units_available_one_month)
    end

    it "units_available_two_month is a correct integer" do
      assert_equal(3, units_available_two_month)
    end

    describe "when key does not exist" do
      let(:property_hash) do
        {
          "Floorplan" => [{
                "id" => "1A10"
           }]
        }
      end
      it "is nil" do
        assert_equal(nil, units_available_two_month)
      end
    end
  end


  # ---
  # ---


  describe "the room-count-related fields" do

    let(:total_room_count) { floorplans.formatted_hash_array[0][:total_room_count] }
    let(:bathroom_count) { floorplans.formatted_hash_array[0][:bathroom_count] }
    let(:bedroom_count) { floorplans.formatted_hash_array[0][:bedroom_count] }

    let(:property_hash) do
      {
        "Floorplan" => [{
              "Room" => [{
                  "type" => "bathroom",
                   "Count" => "3"
              },
               {
                  "type" => "bedroom",
                   "Count" => "5"
              }]
          }]
      }
    end

    it "total_room_count is a correct integer" do
      assert_equal(8, total_room_count)
    end

    it "bathroom_count is a correct integer" do
      assert_equal(3, bathroom_count)
    end

    it "bedroom_count is a correct integer" do
      assert_equal(5, bedroom_count)
    end

    describe "when key does not exist" do
      let(:property_hash) do
        {
          "Floorplan" => [{
                "id" => "1A10"
           }]
        }
      end
      it "is nil" do
        assert_equal(nil, total_room_count)
      end
    end
  end


  # ---
  # ---


  describe "the description field" do

    subject { floorplans.formatted_hash_array[0][:descriptions] }

    let(:property_hash) do
      {
        "Floorplan" => [{
            "Comment" => "Renovated%201%20Bedroom%20Apartment",
            "Concession" => {
                "active" => "true",
                "Value" => nil,
                "Term" => nil,
                "Description" => "(1) 3% TAAC Discount  (2) 3% Preferred Employer Program, see list for eligibility  (3) 3% SAAC Discount"
            }
        }]
      }
    end

    let(:expected) do
      {
        :comment=>"Renovated%201%20Bedroom%20Apartment",
        :concession_description=>"(1) 3% TAAC Discount (2) 3% Preferred Employer Program, see list for eligibility (3) 3% SAAC Discount"
      }
    end

    it "is a correctly formatted hash" do
      assert_equal(expected, subject)
    end
  end


  # ---
  # ---


  describe "the square_feet field" do

    let(:min) { floorplans.formatted_hash_array[0][:square_feet_min] }
    let(:max) { floorplans.formatted_hash_array[0][:square_feet_max] }

    describe "when both min and max specified" do
      let(:property_hash) do
        {
          "Floorplan" => [{
              "SquareFeet" => {
                  "min" => "630",
                  "max" => "840"
              }
          }]
        }
      end

      it "is a correct integer" do
        assert_equal(630, min)
        assert_equal(840, max)
      end
    end

    describe "when a value is nil or non-numeric" do
      let(:property_hash) do
        {
          "Floorplan" => [{
              "SquareFeet" => {
                  "min" => nil,
                  "max" => "this is not numeric"
              }
          }]
        }
      end

      it "is a nil" do
        assert_equal(nil, min)
        assert_equal(nil, max)
      end
    end

    describe "when a value is floating-point number" do
      let(:property_hash) do
        {
          "Floorplan" => [{
              "SquareFeet" => {
                  "min" => "1.99",
                  "max" => "99.99"
              }
          }]
        }
      end

      it "is a floored integer" do
        assert_equal(1, min)
        assert_equal(99, max)
      end
    end
  end


  # ---
  # ---


  describe "the rent field" do

    let(:min) { floorplans.formatted_hash_array[0][:rent_min] }
    let(:max) { floorplans.formatted_hash_array[0][:rent_max] }

    describe "when both min and max specified" do
      let(:property_hash) do
        {
          "Floorplan" => [{
              "MarketRent" => {
                  "min" => "530", "max" => "530"
              }, "EffectiveRent" => {
                  "min" => "", "max" => "840"
              }
          }]
        }
      end

      it "is a correct integer" do
        assert_equal(530, min)
        assert_equal(840, max)
      end
    end

    describe "when a value is nil or non-numeric" do
      let(:property_hash) do
        {
          "Floorplan" => [{
              "MarketRent" => {
                  "min" => "hello", "max" => "world"
              }, "EffectiveRent" => {
                  "min" => "", "max" => ""
              }
          }]
        }
      end

      it "is a nil" do
        assert_equal(nil, min)
        assert_equal(nil, max)
      end
    end

    describe "when a value is floating-point number" do
      let(:property_hash) do
        {
          "Floorplan" => [{
              "MarketRent" => {
                  "min" => "1000.99", "max" => "1500.99"
              }, "EffectiveRent" => {
                  "min" => "200.99", "max" => "1300.99"
              }
          }]
        }
      end

      it "is a floored integer" do
        assert_equal(200, min)
        assert_equal(1500, max)
      end
    end
  end

end
