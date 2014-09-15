# == Schema Information
#
# Table name: tokens
#
#  id             :integer          not null, primary key
#  code           :string(255)      not null
#  created_at     :datetime
#  updated_at     :datetime
#  certificate_id :integer
#  user_id        :integer
#

require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
