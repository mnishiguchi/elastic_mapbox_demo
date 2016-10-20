require 'test_helper'

# How to run this test:
#   bundle exec rake test TEST=test/feeds/mits_parser
describe MitsParser::Information do
  # NOTE: Because some feeds have parking information within Information node and
  # and others within Amenities node, we provide this class with a reference to
  # the MitsParser::Amenities object. We explicitly pass a MitsParser::Amenities
  # object into it when instantiating a MitsParser::Information class.
  let(:amenities) { MitsParser::Amenities.new(property_hash) }
  let(:information) { MitsParser::Information.new(property_hash, amenities) }


  # ---
  # ---


  describe "descriptions" do

    let(:property_hash) do
      {
        "Information" => {
            "ShortDescription"  => "Located in the heart of East Memphis.",
            "LongDescription"   => "Park Estate, the most desirable address in East Memphis!",
            "DrivingDirections" => "From I-240, take the Poplar Ave West exit.  Turn left onto Estate Dr.  Take the 2nd right onto Wrens Roost Circle and then turn right onto Catbird Ct.",
          }
      }
    end

    let(:expected) do
      {
        :information_long_description => "Park Estate, the most desirable address in East Memphis!",
        :information_short_description => "Located in the heart of East Memphis."
      }
    end

    it "is a correctly formatted hash" do
      assert(information.descriptions.is_a?(Hash))
      assert_equal(expected, information.descriptions)
    end
  end


  # ---
  # ---


  describe "lease_length" do

    let(:property_hash) do
      {
        "Information" => {},
        "Floorplan" => [
            {
                "Identification" => {},
                "LeaseTerm" => { "Avg" => "8", "Min" => "2", "Max" => "14" }
            },
            {
                "Identification" => {},
                "LeaseTerm" => { "Avg" => "8", "Min" => "3", "Max" => "18" }
            },
        ]
      }
    end

    let(:expected) do
      {
        :min => 2, :max => 18
      }
    end
    it "is a correctly formatted hash" do
      assert_equal(expected, information.lease_length)
    end
  end


  # ---
  # ---


  describe "office_hours" do

    let(:property_hash) do
      {
        "Information" => {
            "OfficeHour" => [
             { "OpenTime" => "10:00 AM", "CloseTime" => "05:00 PM", "Day" => "Su" },
             { "OpenTime" => "10:00 AM", "CloseTime" => "07:00 PM", "Day" => "M" },
             { "OpenTime" => "10:00 AM", "CloseTime" => "07:00 PM", "Day" => "T" },
             { "OpenTime" => "10:00 AM", "CloseTime" => "07:00 PM", "Day" => "W" },
             { "OpenTime" => "10:00 AM", "CloseTime" => "07:00 PM", "Day" => "Th" },
             { "OpenTime" => "10:00 AM", "CloseTime" => "06:00 PM", "Day" => "F" },
             { "OpenTime" => "10:00 AM", "CloseTime" => "06:00 PM", "Day" => "Sa" }
           ]
        }
      }
    end

    let(:expected) do
      {
        :sunday   =>{:open=>"10:00", :close=>"17:00"},
        :monday   =>{:open=>"10:00", :close=>"19:00"},
        :tuesday  =>{:open=>"10:00", :close=>"19:00"},
        :wednesday=>{:open=>"10:00", :close=>"19:00"},
        :thursday =>{:open=>"10:00", :close=>"19:00"},
        :friday   =>{:open=>"10:00", :close=>"18:00"},
        :saturday =>{:open=>"10:00", :close=>"18:00"}
      }
    end

    it "is a correctly formatted hash" do
      assert information.office_hours.is_a?(Hash)
      assert_equal(expected, information.office_hours)
    end
  end


  # ---
  # ---


  describe "promotional" do

    let(:property_hash) do
      {
        "Information" => {},
        "Promotional" => ["Welcome Home", "Open Floorplans", "Relaxing Pool", "Pet Friendly", "24-Hour Emergency Maintenance", "All Electric Appliance Package"]
      }
    end

    let(:expected) do
      [
        "Welcome Home", "Open Floorplans", "Relaxing Pool", "Pet Friendly", "24-Hour Emergency Maintenance", "All Electric Appliance Package"
      ]
    end

    it "is an Array" do
      assert(information.promotional.is_a?(Array))
      assert_equal(expected, information.promotional)
    end
  end


  # ---
  # ---


  describe "parking" do

    describe "within Information node" do
      let(:property_hash) do
        {
          "Information" => {
            "Parking" => [
              {
                "type" => "surface lot",
                "Assigned" => "1",
                "SpaceFee" => "10.00",
                "Spaces"   => nil,
                "Comment"  => "Parking for residents is available on a first-come, first-served basis in our private parking lot. Parking permit stickers are required."
              },
            ]
          }
        }
      end

      let(:expected) do
        [
          {
            "type"     => "surface lot",
            "Assigned" => "1",
            "SpaceFee" => "10.00",
            "Spaces"   => nil,
            "Comment"  => "Parking for residents is available on a first-come, first-served basis in our private parking lot. Parking permit stickers are required."
          },
        ]
      end

      it "is an Array" do
        assert(information.parking.is_a?(Array))
        assert_equal(expected, information.parking)
      end
    end

    describe "within Amenities node" do
      let(:property_hash) do
        {
          "Information" => {},
          "Amenities" => {
            "Community" => {
              "General" => [
                { "AmenityName" => "Preferred Employer Available", "AmenityCharge" => nil, "AmenityRank" => nil, "AdditionalAmenity" => "Community Amenity" },
                { "AmenityName" => "Onsite Gated Garage Parking", "AmenityCharge" => nil, "AmenityRank" => nil, "AdditionalAmenity" => "Community Amenity" }
              ]
            }
          }
        }
      end

      let(:expected) do
        ["Onsite Gated Garage Parking"]
      end

      it "is an Array" do
        assert(information.parking.is_a?(Array))
        assert_equal(expected, information.parking)
      end
    end

    describe "within Feature node" do
      let(:property_hash) do
        {
          "Information" => {},
          "Amenities" => {},
          "Feature" => [
              {
                "Title" => "Features", "Description" => "<ul>\n\t<li>\n\t\t<span style=\"font-size:12px;\">99 floor plans to suit your personal style</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Stainless steel ENERGY STAR® appliances</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Granite countertops in Wave Sand, Giallo Vermont or Rose White</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Hardwood 42\" cabinets available in shaker style or flat panel with brushed nickel hardware</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Water-saving Moen fixtures</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Parterre designer wood-style flooring in Lancaster Patina or Natural Hickory</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Sun-filled spaces with oversized windows and inspiring views</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Industrial designer pendant lighting</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Vast closet options; linen closets and pantries available</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Full-size GE ENERGY STAR® washers and dryers</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Custom bathrooms with granite countertops, modern stacked tile in bath, soft gray linen texture tile floors and cabinets with drawer storage</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Pet-friendly community </span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Controlled keyless fob access</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Wired for Verizon FiOS and Comcast</span></li>\n</ul><p>\n\t<span style=\"font-size: 16px;\"><strong>Green Is In</strong></span></p><ul>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Fully digital, Web-programmable Pepco Energy Wise thermostat</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Water-saving Moen fixtures</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">GE ENERGY STAR® appliances </span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Low-energy lighting throughout</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Bike storage</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Energy-tight building construction that incorporates local materials</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Recycling and green cleaning program</span></li>\n</ul><p>\n\t<span style=\"font-size: 16px;\"><strong>Optional Features</strong></span></p><ul>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Stained-concrete floors</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Expanded outdoor living spaces with terraces, balconies and patios</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Moveable kitchen islands with expanded prep space and extra storage</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Expanded ceiling heights</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Tech-friendly, custom built-in desks</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Direct-entry homes with private entrances</span></li>\n</ul><h2>\n\tAmenities</h2><p>\n\t<span style=\"font-size:16px;\"><strong>Interior Stylings</strong></span></p><ul>\n\t<li>\n\t\t<span style=\"font-size:12px;\">16,000 sq. ft. of amenity space</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">24-hour fitness centers with yoga studios, cardio theaters, weights, as well as an express gym</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Artistic workspaces throughout the community</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Lounge, community room and billiards</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">E-café with Wi-Fi</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Flexible spaces for community events and private parties</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Resident storage available</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Controlled keyless fob access</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Pet-friendly community</span></li>\n</ul><p>\n\t<span style=\"font-size:16px;\"><strong>Outdoor Installations</strong></span></p><ul>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Adjacent to the Brookland-CUA Metro Station and several bus stops</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Sparkling outdoor swimming pool with expansive sundeck</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Lush, beautifully landscaped courtyards</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Outdoor lounges with bars and grills</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">First-floor retail and restaurants</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Along the Metropolitan Branch Bike Trail</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Green walls and cool roofs reduce urban heat</span></li>\n\t<li>\n\t\t<span style=\"font-size:12px;\">Garage parking available</span></li>\n</ul>"
              },
              {
                "Title" => "Features", "Description" => "<ul>\n\t<li>\n\t\tStudio, one- and two-bedroom floor plans</li>\n\t<li>\n\t\tOpen floor plans with amazing city views available</li>\n\t<li>\n\t\tDistinctive finishes with modern flair</li>\n\t<li>\n\t\tEuropean-style kitchens and cabinetry</li>\n\t<li>\n\t\tSleek bathroom designs</li>\n\t<li>\n\t\tFully equipped kitchen with stainless steel appliances</li>\n\t<li>\n\t\tSliding wall in select apartments to separate living and sleeping spaces</li>\n\t<li>\n\t\tHard surface flooring</li>\n\t<li>\n\t\tCustomizable closets</li>\n</ul><h2>\n\tAmenities</h2><ul>\n\t<li>\n\t\t6,000 sq. ft. gym/spa with cardio, weights, yoga, spinning, massage room and outdoor fitness deck</li>\n\t<li>\n\t\tRooftop lounge and infinity edge pool</li>\n\t<li>\n\t\tRooftop dog park with washing and grooming station for your pooch</li>\n\t<li>\n\t\tLandscaped rooftop terraces with views of DC</li>\n\t<li>\n\t\tOutdoor living spaces with grills and fire pits</li>\n\t<li>\n\t\tBusiness center </li>\n\t<li>\n\t\tWi-Fi café </li>\n\t<li>\n\t\tGame room</li>\n\t<li>\n\t\tHD theater for you and your friends</li>\n\t<li>\n\t\t24/7 concierge </li>\n\t<li>\n\t\tOn-site garage parking</li>\n\t<li>\n\t\tElectric car-charging stations </li>\n\t<li>\n\t\tBike storage and repair</li>\n\t<li>\n\t\tSocial events and community gatherings</li>\n</ul><p>\n\t<span style=\"color:#808080;\"><span style=\"font-size:12px;\"><span style=\"font-family: arial, sans, sans-serif; white-space: pre-wrap;\">Washington, D.C residents will love The City Market at O Street in Northwest. Their dogs will love this pet-friendly community. Its stellar location is only topped by the community’s luxurious amenities. Residents will enjoy the rooftop pool, concierge services, dog park and game room too. Don’t delay. Reach out to Bozzuto today to secure a spot at this great community. </span></span></span></p>"
              },
          ]
        }
      end

      let(:expected) do
        [
          "garage parking available", "on-site garage parking"
        ]
      end

      it "is an Array" do
        assert(information.parking.is_a?(Array))
        assert_equal(expected, information.parking)
      end
    end

  end
end
