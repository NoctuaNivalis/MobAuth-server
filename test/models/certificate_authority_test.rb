require 'test_helper'
require 'openssl'

class CertificateAuthorityTest < ActiveSupport::TestCase

  setup :define_options

  test "signed crs is verified" do
    # Make new key
    key = OpenSSL::PKey::RSA.new 4096

    # Make new request
    request = OpenSSL::X509::Request.new
    request.version = 0
    request.subject = OpenSSL::X509::Name.new([
      ['C',  @options[:country], OpenSSL::ASN1::PRINTABLESTRING],
      ['ST', @options[:state], OpenSSL::ASN1::PRINTABLESTRING],
      ['L',  @options[:city], OpenSSL::ASN1::PRINTABLESTRING],
      ['O',  @options[:organization], OpenSSL::ASN1::UTF8STRING],
      ['OU', @options[:department], OpenSSL::ASN1::UTF8STRING],
      ['CN', @options[:common_name], OpenSSL::ASN1::UTF8STRING],
      ['emailAddress', @options[:email], OpenSSL::ASN1::UTF8STRING]
    ])
    request.public_key = key.public_key
    request.sign key, OpenSSL::Digest::SHA1.new

    # Ask CA to sign key.
    crt = CertificateAuthority.sign(request.to_pem)

    # Check if it's stored.
    assert_equal Certificate.last, crt, \
      "Certificate not stored."

    # Check if it's signed by the CA.
    assert CertificateAuthority.verify(crt.crt), \
      "Signed certificate not signed by the ca?"

    # Revoke the certificate
    CertificateAuthority.revoke(crt.crt)

    # Check if it's on the list
    list = crt.intermediate_ca.revocation_list
    assert list.verify(crt.intermediate_ca.key), \
      "List not signed by it's ca."
    assert_match /Serial Number: 0*#{crt.crt.serial}/, list.to_text, \
      "Certificate not on revocation list."
  end

  # TODO test invalid crt's, verify with old_ca, ...

  private

  def define_options
    @options = {
      country: 'BE',
      state: 'Oost-Vlaanderen',
      city: 'Ghent',
      organization: 'Deloitte',
      department: 'ERS',
      common_name: 'Felix',
      email: ''
    }
  end

end
