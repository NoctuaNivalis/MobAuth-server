require 'openssl'

module CertificateAuthority

  # Exceptions
  class InvalidCSR < StandardError
    def initialize
      super('CSR cannot be verified.')
    end
  end

  class << self

    def sign(csr_file, host)
      # Signs the certificate signing request, returning a certificate.
      load_instances
      new_ca.sign(csr_file, host)
    end

    def revoke(crt)
      load_instances

      if crt.not_after < Time.now
        # Invalid certificate
        # TODO should this still be revoked?
        return
      end

      certificate = Certificate.find_by_crt(crt.to_pem)
      unless certificate
        # not one of our crt's
        # TODO crash somehow.
        return
      end

      certificate.revoke
    end

    def verify(crt)
      load_instances
      Certificate.find_by_crt(crt.to_pem).verify
    end

    private

    def old_ca
      IntermediateCa.order('id desc').second
    end

    def new_ca
      IntermediateCa.last
    end

    def load_instances
      if new_ca.nil? || !new_ca.usable?
        IntermediateCa.create
      end
    end

  end

end
