require 'test_helper'

# How to run this test:
#   bundle exec rake test TEST=test/feeds/mits_parser
describe MitsParser::Others do

  # NOTE: Testing this class is dependent on what paths we specify in
  # MitsParser::Others class. Please check the @@paths variable.
  describe "schema example 1" do
    let(:property_hash) do
      {
        "Concession" => {
            "active" => "true",
            "Value" => nil,
            "Term" => nil,
            "Description" => "(1) 3% TAAC Discount  (2) 3% Preferred Employer Program, see list for eligibility  (3) 3% SAAC Discount"
        }
      }
    end

    let(:others) { MitsParser::Others.new(property_hash) }

    let(:expected) do
        {
          :concession=>{
            "active"=>"true",
            "Value"=>nil,
            "Term"=>nil, 
            "Description"=>"(1) 3% TAAC Discount  (2) 3% Preferred Employer Program, see list for eligibility  (3) 3% SAAC Discount"
            }
        }
    end

    it "returns information in a correct format" do
      assert_equal(expected, others.other_information)
    end
  end
end
