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

require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
