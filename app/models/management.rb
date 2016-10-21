# == Schema Information
#
# Table name: managements
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Management < ApplicationRecord
  has_many :properties
end
