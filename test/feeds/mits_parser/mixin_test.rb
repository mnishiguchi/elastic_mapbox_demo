require 'json'
require 'test_helper'

# How to run this test:
#   bundle exec rake test TEST=test/feeds/mits_parser
describe MitsParser::Mixin do

  let(:properties) do
    data = File.read("#{file_dir}/feed_b_property.json")
    # http://stackoverflow.com/a/26399045/3837223
    JSON.parse(data.encode("ASCII",{:undef=>:replace,:replace=>""}))
  end

  let(:property_hash) { properties.first }

  # Create a fake class that has Mixin included so that we can
  # call all the Mixin methods on its instance.
  let(:object) do
    class SomeClass
      include MitsParser::Mixin
    end
    SomeClass.new
  end


  describe ".dig(hash, path)" do

    describe "with a single property" do

      describe "for valid path" do
        it "traverses all the array elements if the location contains an array" do
          days     = object.dig(property_hash, ["Information", "OfficeHour", "Array", "Day"])
          expected = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
          assert_equal(expected, days)

          open_times = object.dig(property_hash, ["Information", "OfficeHour", "Array", "OpenTime"])
          expected   = ["9:00 AM", "9:00 AM", "9:00 AM", "9:00 AM", "9:00 AM", "10:00 AM", "1:00 PM"]
          assert_equal(expected, open_times)
        end
      end

      describe "for nonexistent path" do
        subject { object.dig(property_hash, ["Hello", "konnichiwa"]) }

        it "returns an empty array" do
          assert_equal([], subject)
        end
      end
    end

    describe "with a collection of properties" do

      describe "for valid path" do
        subject { object.dig(properties, ["Array", "managementID"]) }

        it "returns an array of values that were found for each element" do
          assert_equal ["2785", "4583"], subject
        end
      end

      describe "for nonexistent path" do
        subject { object.dig(properties, ["Array", "inVaLidPaTh"]) }

        it "returns array of empty arrays" do
          assert_equal [[], []], subject
        end
      end
    end
  end


  describe ".dig_all(hash, *paths)" do

    describe "for multiple paths" do
      subject do
        object.dig_all(property_hash,
          ["File", "Array", "id"],
          ["File", "Array", "Type"],
        )
      end

      it "returns a hash of path => value" do
        expected = {
          file_arrayid: [
            "252047", "1275220", "252049", "1275221", "252051", "1275222", "252053", "1275224", "252055", "1275225", "252057", "1275226", "252059", "1275227", "252061", "1275228", "252063", "1275229", "252065", "1275230", "252067", "1275231", "259719", "1275234", "252069", "1275235", "252071", "1275237", "42608_1", "1185839", "42608_2", "1185844", "42608_3", "1185848", "42608_4", "1185847", "42608_5", "1185845", "42608_6", "1185846", "42608_7", "1185841", "42608_8", "1185850", "42608_9", "1185838", "42608_10", "1185834", "42608_11", "1185851", "42608_12", "3261828", "42608_13", "1185829", "42608_14", "1185830", "42608_15", "1185835", "42608_16", "1185837", "42608_17", "1185843", "42608_18", "1185842", "42608_19", "1185849", "42608_20", "1185833", "42608_21", "1185832", "42608_22", "1185831", "42608_23", "1185840", "42608_24", "3263410", "42608_25", "3263411"
          ],
          file_array_type: [
            "floorplan", "floorplan", "floorplan", "floorplan", "floorplan", "floorplan", "floorplan", "floorplan", "floorplan", "floorplan", "floorplan", "floorplan", "floorplan", "floorplan", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo", "photo"
          ]
        }

        assert_equal(expected, subject)
      end

      it "does not return nonexistent key" do
        refute subject.keys.include?("non_existent_key")
      end
    end

    describe "for a single paths" do
      subject do
        object.dig_all(property_hash,
          ["Policy", "Pet", "type"],
        )
      end

      it "returns a hash of path => value" do
        expected = {
          policy_pettype: "Cat"
        }
        assert_equal(expected, subject)
      end
    end
  end


  describe ".dig_or_default(hash, default_value, *paths)" do

    describe "when the specified path exists" do
      subject do
        object.dig_or_default(property_hash, "no value", %w(Identification Address Zip))
      end

      it "returns the value that was found" do
        assert_equal "20008", subject
      end
    end

    describe "when the specified path do not exist" do
      subject do
        object.dig_or_default(property_hash, "USA", %w(Identification Address Country))
      end

      it "returns the specified default value" do
        assert_equal "USA", subject
      end
    end
  end
end
