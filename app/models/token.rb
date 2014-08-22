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

  # call_backs
  after_initialize :generate_code

  # validations
  validates :code, uniqueness: true, presence: true

  def recent?
    # Is this a recent (and thus valid) token?
    # Tokens older then 5 minutes are declared invalid, and will be removed
    # automatically. The should no longer be used even if present.
    self.created_at > 5.minutes.ago
  end

  def to_qr
    RQRCode::QRCode.new code, size: 4, level: :h
    # TODO make it a link to this server, so apps shouldn't be modified on
    # server change.
  end

  protected

  def generate_code
    # generate code automatically on creation.
    self.code ||= SecureRandom.urlsafe_base64(10)
  end

end
