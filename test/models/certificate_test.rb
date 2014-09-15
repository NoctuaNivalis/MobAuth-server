# == Schema Information
#
# Table name: certificates
#
#  id                 :integer          not null, primary key
#  device_id          :integer
#  intermediate_ca_id :integer
#  crt                :binary
#  revoked_at         :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
