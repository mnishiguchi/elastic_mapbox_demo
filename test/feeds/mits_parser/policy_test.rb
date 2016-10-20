require 'test_helper'

# How to run this test:
#   bundle exec rake test TEST=test/feeds/mits_parser
describe MitsParser::Policy do

  let(:policy) { MitsParser::Policy.new(property_hash) }

  describe "when pet is an array" do

    let(:property_hash) do
      {
          "Policy" => {
            "Pet" => [
                { "type" => "Dog", "allowed" => "True" },
                { "type" => "Cat", "allowed" => "True" }
            ]
          }
      }
    end

    let(:expected) do
      {
          pet: [
              { "type" => "Dog", "allowed" => true },
              { "type" => "Cat", "allowed" => true }
          ]
      }
    end

    it "pet is a hash array" do
      assert_equal(expected, policy.formatted_hash)
    end
  end

  describe "when pet is a hash" do

    let(:property_hash) do
      {
        "Policy" => {
              "Pet" => { "type" => "Cat" }
        }
      }
    end

    let(:expected) do
      {
        pet: [
            { "type" => "Cat" }
        ]
      }
    end

    it "is converted into a hash array" do
      assert_equal(expected, policy.formatted_hash)
    end
  end

  describe "with general key" do

    let(:property_hash) do
      {
        "Policy" => {
              "Pet" => {
                  "type"    => "Cat",
                  "allowed" => "true",
                  "Comment" => nil
              },
              "General" => "Maximum of 2 pets per apartment * Cats accepted"
          }
      }
    end

    let(:expected) do
      {
        pet: [
          {
            "type"    => "Cat",
            "allowed" => true
          }
        ],
        general: "Maximum of 2 pets per apartment * Cats accepted"
      }
    end

    it "is a correctly formatted hash" do
      assert_equal(expected, policy.formatted_hash)
    end
  end

  describe "with nil values, empty string, empty array or empty hash" do

    let(:property_hash) do
      {
        "Policy" => {
              "Pet" => [
                  { "type"      => "Cat"},
                  { "Comment"   => nil  },
                  { "empty pet" => []   },
                  { }
              ],
              "General" => ""
          }
      }
    end

    let(:expected) do
      {
        pet: [
          { "type" => "Cat" }
        ]
      }
    end

    it "removes all elements with nil/empty values" do
      assert_equal(expected, policy.formatted_hash)
    end
  end

  describe "with boolean-ish string values" do

    let(:property_hash) do
      {
        "Policy" => {
              "Pet" => {
                  "type"    => "Cat",
                  "allowed" => "True",
                  "PetCare" => "False"
              }
          }
      }
    end

    let(:expected) do
      {
        pet: [
          {
            "type"    => "Cat",
            "allowed" => true,
            "PetCare" => false
          }
        ]
      }
    end

    it "is converted into boolean" do
      assert_equal(expected, policy.formatted_hash)
    end
  end

end
