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

require 'openssl'

class IntermediateCa < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  @@serialNumber = 0

  # relations
  has_many :certificates

  # call_backs
  before_create :generate_files

  def usable?
    Time.now + Settings.client_crt.valid_for.days < self.crt.not_after
  end

  def dated?
    self.crt.not.after < Time.now
  end

  def sign(csr, host, username)
    # Checking the csr's signature.
    csr = OpenSSL::X509::Request.new csr
    raise InvalidCSR unless csr.verify csr.public_key

    time = Time.now

    # Generating a certificate.
    crt = OpenSSL::X509::Certificate.new
    crt.serial = @@serialNumber+=1
    crt.version = 2
    crt.not_before = time
    crt.not_after = Time.now + Settings.client_crt.valid_for.days
    name = OpenSSL::X509::Name.new [['CN', username]]
    crt.subject = name
    crt.public_key = csr.public_key
    crt.issuer = self.crt.subject

    extension_factory = OpenSSL::X509::ExtensionFactory.new
    extension_factory.subject_certificate = crt
    extension_factory.issuer_certificate = self.crt

    crt.add_extension extension_factory.create_extension(
      'basicConstraints', 'CA:FALSE')
    crt.add_extension extension_factory.create_extension(
      'keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')
    crt.add_extension extension_factory.create_extension(
      'subjectKeyIdentifier', 'hash')
    crt.add_extension extension_factory.create_extension(
      'crlDistributionPoints', "URI:#{crl_url(self, host: host)}")

    # Signing the certificate.
    crt.sign self.key, OpenSSL::Digest::SHA1.new

    # Saving it as one of our certificates
    certificate = Certificate.create crt: crt
    certificates << certificate
    self.save!

    certificate
  end

  def verify(crt)
    crt.verify self.crt.public_key
  end

  def revocation_list
    crl = OpenSSL::X509::CRL.new
    certificates.each do |crt|
      if crt.revoked_at.present?
        revoked = OpenSSL::X509::Revoked.new
        revoked.serial = crt.crt.serial
        revoked.time = crt.revoked_at
        crl.add_revoked(revoked)
      end
    end
    crl.version = 1
    crl.last_update = Time.now
    crl.next_update = Time.now
    crl.issuer = self.crt.subject
    crl.sign self.key, OpenSSL::Digest::SHA1.new
    crl
  end

  def key
    OpenSSL::PKey::RSA.new(read_attribute(:keypair)) if read_attribute(:keypair)
  end

  def crt
    OpenSSL::X509::Certificate.new(read_attribute(:certificate)) if read_attribute(:certificate)
  end

  private

  def key=(k)
    write_attribute :keypair, k.to_pem
  end

  def crt=(c)
    write_attribute :certificate, c.to_pem
  end

  def generate_files

    # Don't generate if they exist.
    if self.key && self.crt
      raise "WHUT?"
    end

    # Loading the private key and certificate of the certificate authority.
    ca_key = ca_crt = nil
    open Settings.key_file do |io|
      ca_key = OpenSSL::PKey::RSA.new io, Settings.ca_passphrase
    end
    open Settings.crt_file do |io|
      ca_crt = OpenSSL::X509::Certificate.new io
    end

    # Generating an intermediate ca key and crs.
    im_key = OpenSSL::PKey::RSA.new Settings.intermediate.key_size
    csr = OpenSSL::X509::Request.new
    csr.version = 0
    csr.subject = OpenSSL::X509::Name.new [
      ['C',            Settings.intermediate.country,      OpenSSL::ASN1::PRINTABLESTRING],
      ['ST',           Settings.intermediate.state,        OpenSSL::ASN1::PRINTABLESTRING],
      ['L',            Settings.intermediate.city,         OpenSSL::ASN1::PRINTABLESTRING],
      ['O',            Settings.intermediate.organization, OpenSSL::ASN1::UTF8STRING],
      ['OU',           Settings.intermediate.department,   OpenSSL::ASN1::UTF8STRING],
      ['CN',           Settings.intermediate.common_name,  OpenSSL::ASN1::UTF8STRING],
      ['emailAddress', Settings.intermediate.email,        OpenSSL::ASN1::UTF8STRING]
    ]
    csr.public_key = im_key.public_key
    csr.sign(ca_key, OpenSSL::Digest::SHA1.new)

    # Signing the intermediate ca crs with the root ca.
    im_crt = OpenSSL::X509::Certificate.new
    im_crt.serial = 0
    im_crt.version = 2
    im_crt.not_before = Time.now
    im_crt.not_after = Time.now + Settings.intermediate.valid_for.days
    im_crt.subject = csr.subject
    im_crt.public_key = csr.public_key
    im_crt.issuer = ca_crt.subject

    extension_factory = OpenSSL::X509::ExtensionFactory.new
    extension_factory.subject_certificate = im_crt
    extension_factory.issuer_certificate = ca_crt

    im_crt.add_extension extension_factory.create_extension(
      'basicConstraints', 'CA:TRUE', true)
    im_crt.add_extension extension_factory.create_extension(
      'keyUsage', 'cRLSign,keyCertSign', true)

    im_crt.sign ca_key, OpenSSL::Digest::SHA1.new

    # Remembering the certificate and the key.
    self.key = im_key
    self.crt = im_crt

  end

end

