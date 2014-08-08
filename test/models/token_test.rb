# == Schema Information
#
# Table name: tokens
#
#  id         :integer          not null, primary key
#  code       :string(255)      not null
#  device_id  :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
