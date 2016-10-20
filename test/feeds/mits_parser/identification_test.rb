require 'test_helper'

# How to run this test:
#   bundle exec rake test TEST=test/feeds/mits_parser
describe MitsParser::Identification do

  let(:identification) { MitsParser::Identification.new(property_hash) }

  describe "schema example 1" do
    let(:property_hash) do
      {
        "Identification" => {
              "Type" => "apartment",
              "RentalType" => "",
              "PrimaryID" => "42608",
              "MarketingName" => "Ellicott House",
              "OwnerLegalName" => nil,
              "Phone" => {
                  "Number" => "2022447724"
              }, "Fax" => {
                  "Number" => "2022444906"
              }, "Email" => "info@ellicottliving.com"
          }
      }
    end

    describe "unique_feed_identifiers" do

      let(:expected) do
        { :identification_primary_id => "42608" }
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.unique_feed_identifiers)
        assert(identification.unique_feed_identifiers.is_a?(Hash))
      end
    end

    describe "names" do

      let(:expected) do
        { :identification_marketing_name=>"Ellicott House" }
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.names)
        assert(identification.names.is_a?(Hash))
      end
    end

    describe "urls" do

      let(:expected) do
        {}
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.urls)
        assert(identification.urls.is_a?(Hash))
      end
    end

    describe "emails" do

      let(:expected) do
        { :identification_email => "info@ellicottliving.com" }
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.emails)
        assert(identification.emails.is_a?(Hash))
      end
    end

    describe "phones" do

      let(:expected) do
        {
          :identification_phone_number=>"2022447724",
          :identification_phone_array=>["Number", "2022447724"],
          :identification_fax_number=>"2022444906"
        }
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.phones)
        assert(identification.phones.is_a?(Hash))
      end
    end
  end


  # ---
  # ---


  describe "schema example 2" do
    let(:property_hash) do
      {
        "Identification" => {
             "type" => "apartment",
             "rentaltype" => "standard",
             "PrimaryID" => "20550",
             "MarketingName" => "Bell Del Ray",
             "OwnerLegalName" => nil,
             "Fax" => {
                 "Number" => "(703) 519-1976"
             }, "Website" => "www.bellapartmentliving.com/va/alexandria/bell-del-ray/"
         }
      }
    end

    describe "unique_feed_identifiers" do

      let(:expected) do
        { :identification_primary_id=>"20550" }
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.unique_feed_identifiers)
        assert(identification.unique_feed_identifiers.is_a?(Hash))
      end
    end

    describe "names" do

      let(:expected) do
        { :identification_marketing_name=>"Bell Del Ray" }
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.names)
        assert(identification.names.is_a?(Hash))
      end
    end

    describe "urls" do

      let(:expected) do
        {
          :identification_website=>"www.bellapartmentliving.com/va/alexandria/bell-del-ray/"
        }
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.urls)
        assert(identification.urls.is_a?(Hash))
      end
    end

    describe "emails" do

      let(:expected) do
        {}
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.emails)
        assert(identification.emails.is_a?(Hash))
      end
    end

    describe "phones" do

      let(:expected) do
        { :identification_fax_number=>"(703) 519-1976" }
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.phones)
        assert(identification.phones.is_a?(Hash))
      end
    end
  end


  # ---
  # ---


  describe "schema example 3" do
    let(:property_hash) do
      {
          "Identification" => {
              "IDValue" => "010012"
          },
          "PropertyID" => {
              "Identification" => [{
                  "IDType" => "PrimaryID",
                  "IDValue" => "010012"
              }, {
                  "IDType" => "SecondaryID",
                  "IDValue" => "1032558"
              }],
              "MarketingName" => "Park Estate",
              "WebSite" => "http://parkestateapts.com",
              "Address" => {
                  "Email" => "ParkEstate.MAAC@lead2lease.com"
              },
              "Phone" => {
                  "PhoneType" => "office",
                  "PhoneNumber" => "866-732-0276"
              }
          }
      }
    end

    describe "unique_feed_identifiers" do

      let(:expected) do
        {
            :identification_id_value=>"010012",
            :property_id_identification_array_id_value=>[
              "010012",
              "1032558"
            ]
        }
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.unique_feed_identifiers)
        assert(identification.unique_feed_identifiers.is_a?(Hash))
      end
    end

    describe "names" do

      let(:expected) do
        {:property_id_marketing_name=>"Park Estate"}
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.names)
        assert(identification.names.is_a?(Hash))
      end
    end

    describe "urls" do

      let(:expected) do
        {:property_id_web_site=>"http://parkestateapts.com"}
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.urls)
        assert(identification.urls.is_a?(Hash))
      end
    end

    describe "emails" do

      let(:expected) do
        {:property_id_address_email=>"ParkEstate.MAAC@lead2lease.com"}
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.emails)
        assert(identification.emails.is_a?(Hash))
      end
    end

    describe "phones" do

      let(:expected) do
        {:property_id_phone_phone_number=>"866-732-0276"}
      end

      it "is a correctly formatted hash" do
        assert_equal(expected, identification.phones)
        assert(identification.phones.is_a?(Hash))
      end
    end
  end
end
