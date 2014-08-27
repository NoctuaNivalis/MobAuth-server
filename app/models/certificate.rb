require 'openssl'

class Certificate < ActiveRecord::Base

  # Relations
  belongs_to :device
  belongs_to :intermediate_ca

  def verify
    self.intermediate_ca.verify self.crt
  end

  def revoke
    self.update revoked_at: Time.now
  end

  def crt
    OpenSSL::X509::Certificate.new read_attribute(:crt)
  end

  def crt=(c)
    write_attribute(:crt, c.to_pem)
  end

end

