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

class Token < ActiveRecord::Base
  # relations
  belongs_to :device

  # call_backs
  after_initialize :generate_code

  # validations
  validates :code, uniqueness: true, presence: true
  validates :device_id, uniqueness: true, presence: true

  def recent?
    # Is this a recent (and thus valid) token?
    # Tokens older then 5 minutes are declared invalid, and will be removed
    # automatically. The should no longer be used even if present.
    self.created_at > 5.minutes.ago
  end

  protected

  def generate_code
    # generate code automatically on creation.
    puts "HEY"
    self.code = SecureRandom.urlsafe_base64(32)
  end

end
