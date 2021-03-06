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

require 'base64'
require 'securerandom'

class Token < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  # relations
  has_one :certificate
  belongs_to :user

  # call_backs
  after_initialize :generate_code

  # validations
  validates :code, uniqueness: true, presence: true
  validates :user, presence: true

  def recent?
    # Is this a recent (and thus valid) token?
    # Tokens older then 5 minutes are declared invalid, and will be removed
    # automatically. The should no longer be used even if present.
    self.created_at > 5.minutes.ago
  end

  def as_str(host)
    host ="192.168.43.118"
    #"#{Base64.encode64(certificates_url(host: host))} #{code}"
    "#{encode(host)} #{code}"
  end

  def as_qr(host)
    RQRCode::QRCode.new self.as_str(host), size: 4, level: :h
  end

  protected

  def generate_code
    # generate code automatically on creation.
    self.code ||= SecureRandom.base64(10)
  end

  def encode(ip)
    Base64.encode64(ip.split('.').map { |s| s.to_i.chr }.join)
  end

end
