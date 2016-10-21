# == Schema Information
#
# Table name: properties
#
#  id            :integer          not null, primary key
#  name          :string
#  address       :string
#  city          :string
#  county        :string
#  state         :string
#  zip           :string
#  country       :string
#  latitude      :float
#  longitude     :float
#  management_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Property < ApplicationRecord
  searchkick

  belongs_to :management
  has_many :floorplans
end
