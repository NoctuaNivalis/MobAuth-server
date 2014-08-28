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

require 'base64'
require 'securerandom'

class Token < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  # relations
  has_one :certificate

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

  def as_str(host)
    "#{Base64.encode64(certificates_url(host: host))} #{code}"
  end

  def as_qr(host)
    RQRCode::QRCode.new self.as_str(host), size: 4, level: :h
  end

  protected

  def generate_code
    # generate code automatically on creation.
    self.code ||= SecureRandom.base64(10)
  end

end
