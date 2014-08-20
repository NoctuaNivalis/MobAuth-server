require 'openssl'

class CertificateAuthority

  OPTIONS = {
    country:      Settings.intermediate.country,
    state:        Settings.intermediate.state,
    city:         Settings.intermediate.city,
    organization: Settings.intermediate.organization,
    department:   Settings.intermediate.department,
    common_name:  Settings.intermediate.common_name,
    email:        Settings.intermediate.email
  }

  def initialize
    # Loading the private key of the certificate authority.
    ca_key_file = File.open(Settings.key_file)
    ca_key = OpenSSL::PKey::RSA.new ca_key_file, Settings.ca_passphrase
    ca_key_file.close

    # Loading the ca certificate
    ca_crt_file = File.open(Setings.crt_file)
    ca_crt = OpenSSL::X509::Certificate.new ca_crt_file
    ca_crt_file.close

    # Generating an intermediate ca key and crs.
    im_key = OpenSSL::PKey::RSA.new Settings.intermediate.key_size
    im_csr = OpenSSL::X509::Request.new
    im_csr.version = 0
    im_csr.subject = OpenSSL::X509::Name.new [
      ['C',            options[:country],      OpenSSL::ASN1::PRINTABLESTRING],
      ['ST',           options[:state],        OpenSSL::ASN1::PRINTABLESTRING],
      ['L',            options[:city],         OpenSSL::ASN1::PRINTABLESTRING],
      ['O',            options[:organization], OpenSSL::ASN1::UTF8STRING],
      ['OU',           options[:department],   OpenSSL::ASN1::UTF8STRING],
      ['CN',           options[:common_name],  OpenSSL::ASN1::UTF8STRING],
      ['emailAddress', options[:email],        OpenSSL::ASN1::UTF8STRING]
    ]
    im_csr.public_key = im_key.public_key
    im_csr.sign(ca_key, OpenSSL::Digest::SHA1.new)

    # Signing the intermediate ca crs with the root ca.
    im_crt = OpenSSL::X509::Certificate.new
    im_crt.serial = 0
    im_crt.version = 2
    im_crt.not_before = Time.now
    im_crt.not_after = Time.now + Settings.intermediate.valid_for.days
    im_crt.subject = im_crs.subject
    im_crt.public_key = im_crs.public_key
    im_crt.issuer = ca_key.subject

    im_extension_factory = OpenSSL::X509::ExtensionFactory.new
    im_extension_factory.subject_certificate = im_cert
    im_extension_factory.issuer_certificate = ca_cert

    im_crt.add_extension im_extension_factory.create_extension(
      'basicConstraints', 'CA:TRUE', true)
    im_crt.add_extension im_extension_factory.create_extension(
      'keyUsage', 'cRLSign,keyCertSign', true)

    im_crt.sign ca_key, OpenSSL::Digest::SHA1.new

    # Remembering the certificate and the key.
    @im_key = im_key
    @im_crt = im_crt
  end

end
