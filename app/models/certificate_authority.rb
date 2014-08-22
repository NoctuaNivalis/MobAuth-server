require 'openssl'
require 'singleton'

module CertificateAuthority

  class Pair
    attr_accessor :key, :crt
    def initialize(key=nil, crt=nil)
      @key = key
      @crt = crt
    end
  end

  class << self

    @@old_files = nil
    @@new_files = nil

    def sign(csr)
      # Signs the certificate signing request, returning a certificate.
      load_instances

      # Checking the csr's signature.
      raise 'CSR can not be verified' unless csr.verify csr.public_key

      # Generating a certficte.
      crt = OpenSSL::X509::Certificate.new
      crt.serial = 0
      crt.version = 2
      crt.not_before = Time.now
      crt.not_after = Time.now + Settings.client_crt.valid_for.days
      crt.subject = csr.subject
      crt.public_key = csr.public_key
      crt.issuer = @@new_files.crt.subject

      extension_factory = OpenSSL::X509::ExtensionFactory.new
      extension_factory.subject_certificate = crt
      extension_factory.issuer_certificate = @@new_files.crt

      crt.add_extension extension_factory.create_extension(
        'basicConstraints', 'CA:FALSE')
      crt.add_extension extension_factory.create_extension(
        'keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')
      crt.add_extension extension_factory.create_extension(
        'subjectKeyIdentifier', 'hash')

      # Signing the certificate.
      crt.sign @@new_files.key, OpenSSL::Digest::SHA1.new

      crt
    end

    def revoke(crt)
      load_instances
      if crt.not_after < Time.now
        # Invalid certificate
        # TODO should this still be revoked?
      elsif crt.verify @@new_ca.crt.public_key
        revoke_with @@new_ca, crt
      elsif @@old_ca && crt.verify(@@old_ca.crt.public_key)
        revoke_with @@old_ca, crt
      else
        # not one of our crt's
        # TODO crash somehow.
      end
    end

    def verify(crt)
      load_instances
      crt.verify @@new_files.crt.public_key || \
        (@@old_files && crt.verify(@@old_files.crt.public_key))
    end

    private

    def valid?(pair)
      Time.now < pair.crt.not_after
    end

    def usable?(pair)
      Time.now + Settings.client_crt.valid_for.days < pair.crt.not_after
    end

    def revoke_with(pair, crt)
      # TODO
    end

    def load_instances
      # Set the new and old ca's and check if they should switch.
      begin
        @@new_files ||= load_files :new_files
      rescue
        @@new_files = generate_files
        save_files :new_files, @@new_files
      end
      if not usable?(@@new_files)
        @@old_files = @@new_files
        save_files :old_files, @@old_files
        @@new_files = generate_files
        save_files :new_files, @@new_files
      end
    end

    def generate_files
      # Loading the private key and certificate of the certificate authority.
      ca = Pair.new
      open Settings.key_file do |io|
        ca.key = OpenSSL::PKey::RSA.new io, Settings.ca_passphrase
      end
      open Settings.crt_file do |io|
        ca.crt = OpenSSL::X509::Certificate.new io
      end

      # Generating an intermediate ca key and crs.
      im = Pair.new
      im.key = OpenSSL::PKey::RSA.new Settings.intermediate.key_size
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
      csr.public_key = im.key.public_key
      csr.sign(ca.key, OpenSSL::Digest::SHA1.new)

      # Signing the intermediate ca crs with the root ca.
      im.crt = OpenSSL::X509::Certificate.new
      im.crt.serial = 0
      im.crt.version = 2
      im.crt.not_before = Time.now
      im.crt.not_after = Time.now + Settings.intermediate.valid_for.days
      im.crt.subject = csr.subject
      im.crt.public_key = csr.public_key
      im.crt.issuer = ca.crt.subject

      extension_factory = OpenSSL::X509::ExtensionFactory.new
      extension_factory.subject_certificate = im.crt
      extension_factory.issuer_certificate = ca.crt

      im.crt.add_extension extension_factory.create_extension(
        'basicConstraints', 'CA:TRUE', true)
      im.crt.add_extension extension_factory.create_extension(
        'keyUsage', 'cRLSign,keyCertSign', true)

      im.crt.sign ca.key, OpenSSL::Digest::SHA1.new

      # Remembering the certificate and the key.
      return im
    end

    def load_files(which)
      unless File.file? Settings.intermediate[which].key
        raise "No key file (#{which.to_s}) to be found."
      end

      unless File.file? Settings.intermediate[which].crt
        raise "No certificate file (#{which.to_s}) to be found."
      end

      pair = Pair.new

      passphrase = Settings.intermediate[which].passphrase
      open Settings.intermediate[which].key do |io|
        pair.key = OpenSSL::PKey::RSA.new io, passphrase
      end
      open Settings.intermediate[which].crt do |io|
        pair.crt = OpenSSL::X509::Certificate.new io
      end

      return pair
    end

    def save_files(which, files)
      cipher = OpenSSL::Cipher::Cipher.new 'AES-128-CBC'
      open Settings.intermediate[which].key, 'w', 0600 do |io|
        io.write files.key.export(cipher, Settings.intermediate[which].passphrase)
      end

      open Settings.intermediate[which].crt, 'w', 0644 do |io|
        io.write files.crt.to_pem
      end
    end

  end

end
