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

class Floorplan < ApplicationRecord
  belongs_to :property
end
