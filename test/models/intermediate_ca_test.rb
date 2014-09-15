# == Schema Information
#
# Table name: intermediate_cas
#
#  id          :integer          not null, primary key
#  keypair     :binary
#  certificate :binary
#  created_at  :datetime
#  updated_at  :datetime
#

require 'test_helper'

class IntermediateCaTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
