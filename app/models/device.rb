# == Schema Information
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#

class Device < ActiveRecord::Base
  belongs_to :user
  has_one :certificate

  validates :name,
    presence: true,
    length: { maximum: 50 },
    uniqueness: { scope: :user }

end
