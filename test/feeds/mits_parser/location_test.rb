require 'test_helper'

# How to run this test:
#   bundle exec rake test TEST=test/feeds/mits_parser
describe MitsParser::Location do

  let(:feed) { eval(File.read("#{file_dir}/feed_c.rb")) }
  let(:object) { MitsParser::Location.new(feed["Property"].first) }

  describe "address" do
    let(:address) { object.street }

    it "is a string of a street address" do
      assert(address.is_a?(String))
    end
  end

  describe "county" do
    let(:county) { object.county }

    it "is a string of a county" do
      assert(county.is_a?(String))
    end
  end

  describe "zip" do
    let(:zip) { object.zip }

    it "is a numeric string of a zipcode" do
      assert(zip.is_a?(String))
      assert(!!(zip =~ /\A[0-9]+\z/))
    end
  end

  describe "state" do
    let(:state) { object.state }

    it "is a string of a state" do
      assert(state.is_a?(String))
    end
  end

  describe "country" do
    let(:country) { object.country }

    it "is a string of a country" do
      assert(country.is_a?(String))
    end

    it "is coerced into United States by default" do
      assert_equal("United States", country)
    end
  end

  describe "latitude" do
    let(:latitude) { object.latitude }

    it "is a string of a latitude" do
      assert(latitude.is_a?(Numeric))
    end
  end

  describe "longitude" do
    let(:longitude) { object.longitude }

    it "is a string of a longitude" do
      assert(longitude.is_a?(Numeric))
    end
  end
end
