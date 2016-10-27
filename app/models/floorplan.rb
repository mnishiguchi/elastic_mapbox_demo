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

  before_save :update_property_rent_minmax
  after_commit :reindex_property


  def update_property_rent_minmax
    property.update_rent_minmax(self.rent)
  end

  # Note that searchkick will not automatically reindex when the associated
  # models change. You need to handle this yourself.
  def reindex_property
    property.reindex
  end
end
