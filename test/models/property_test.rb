# == Schema Information
#
# Table name: properties
#
#  id         :integer          not null, primary key
#  raw_hash   :json
#  address    :string
#  city       :string
#  county     :string
#  state      :string
#  zip        :string
#  country    :string
#  latitude   :float
#  longigute  :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PropertyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
