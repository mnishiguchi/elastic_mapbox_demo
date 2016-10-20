require 'test_helper'

# How to run this test:
#   bundle exec rake test TEST=test/feeds/mits_parser
describe MitsParser::Photos do
  # NOTE: Because MitsParser::Photos take care of finding and allocating best photos
  # for each floorplan, we need to pass a MitsParser::Floorplans object into it
  # when instantiating a MitsParser::Photos class.

  let(:floorplans) { MitsParser::Floorplans.new(property_hash) }

  let(:photos) { MitsParser::Photos.new(property_hash, floorplans) }

  describe "when nested within floorplans" do

    let(:property_hash) do
      {
        "Floorplan" => [
            {
              "id"   => "72285",
              "File" => [
                  { "Src" => "http://floorplan.com/001.jpg" },
                  { "Src" => "http://floorplan.com/002.jpg" }
                ]
            },
            {
              "id"   => "72286",
              "File" => [
                  { "Src" => "http://floorplan.com/003.jpg" },
                  { "Src" => "http://floorplan.com/004.jpg" }
                ]
            }
        ]
      }
    end

    subject do
      photos.add_photos_to_best_floorplan!.property_photo_urls
    end

    it "adds correct photo urls to correct floorplans" do

      first_floorplan = floorplans.objects[0]
      [
        "http://floorplan.com/001.jpg",
        "http://floorplan.com/002.jpg"
      ].each do |url_string|
        assert(first_floorplan.to_json =~ Regexp.new(url_string))
      end

      second_floorplan = floorplans.objects[1]
      [
        "http://floorplan.com/003.jpg",
        "http://floorplan.com/004.jpg"
      ].each do |url_string|
        assert(second_floorplan.to_json =~ Regexp.new(url_string))
      end
    end

    it "#property_photo_urls returns []" do
      property_photos = []
      assert_equal(property_photos, subject)
    end
  end


  describe "when not linked to floorplans" do

    subject do
      photos.add_photos_to_best_floorplan!.property_photo_urls
    end

    let(:property_hash) do
      {
        "Floorplan" => [
            { "Comment" => "No photo is within this Floorplan node" }
        ],
        "File" => [
            { "Src" => "http://example.com/001.jpg" },
            { "Src" => "http://example.com/002.jpg" }
        ]
      }
    end

    let(:expected) do
      [
        "http://example.com/001.jpg",
        "http://example.com/002.jpg"
      ]
    end

    it "returns an array of URL strings" do
      assert_equal(expected, subject)
    end
  end
end


# ---
# ---


describe MitsParser::Photo do

  let(:photo) { MitsParser::Photo.new(photo_hash) }

  let(:photo_hash) do
      {
          "id" => ["125475", "438233"],
          "active" => "true",
          "Type" => "floorplan",
          "Name" => "Larson",
          "Caption" => "Larson",
          "Src" => "http://medialibrary.entrata.com//media_library/1916/5283b51ce5e24704.jpg",
          "Rank" => "1",
          "width" => "640",
          "height" => "480"
      }
  end

  describe "#identification" do

    let(:expected) do
      {
        :ids  => [ "125475", "438233"],
        :name => [ "Larson"],
        :type => [ "floorplan"]
      }
    end

    it "returns an array of identification" do
      assert_equal(expected, photo.identification)
    end
  end

end
