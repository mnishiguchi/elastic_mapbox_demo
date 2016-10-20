require 'test_helper'

# How to run this test:
#   bundle exec rake test TEST=test/feeds/mits_parser
describe MitsParser::Properties do

  let(:feed) { eval(File.read("#{file_dir}/feed_c.rb")) }
  let(:parsed_properties) { MitsParser::Properties.parse(feed) }

  it "return an array of formatted properties hash" do
    assert parsed_properties.is_a?(Array)
    assert parsed_properties.first.is_a?(Hash)
  end

  describe "the property hash" do
    it "has correct keys" do
      expected_keys = [
        :raw_hash,
        :floorplans,
        :unique_feed_identifiers,
        :longitude,
        :latitude,
        :names,
        :urls,
        :emails,
        :phones,
        :descriptions,
        :information,
        :office_hours,
        :photo_urls,
        :pet_policy,
        :promotional_info,
        :amenities,
        :parking,
        :address,
        :city,
        :county,
        :state,
        :zip,
        :country,
        :po_box,
        :lease_length_min,
        :lease_length_max
      ]

      assert_equal(Set.new(expected_keys), Set.new(parsed_properties.first.keys))
    end
  end
end
