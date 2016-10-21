# == Schema Information
#
# Table name: floorplans
#
#  id          :integer          not null, primary key
#  rent        :float
#  description :text
#  name        :string
#  property_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Floorplan < ApplicationRecord
  belongs_to :property
end
