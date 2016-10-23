# == Schema Information
#
# Table name: floorplans
#
#  id             :integer          not null, primary key
#  name           :string
#  description    :text
#  rent           :integer
#  bathroom_count :integer
#  bedroom_count  :integer
#  property_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class FloorplanTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
