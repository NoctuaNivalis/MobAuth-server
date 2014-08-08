# == Schema Information
#
# Table name: certificates
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  device_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Certificate < ActiveRecord::Base
  belongs_to :user
  belongs_to :device
end
