class CertificatesController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :check_token, except: [:auth]

  def auth
    @skip_header = true
  end
  

  def create
    begin
      crs_file = params.require(:csr)
      crt = CertificateAuthority.sign(crs_file.read, request.host_with_port, @token.user.name)
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: 400
    rescue CertificateAuthority::InvalidCSR => e
      render json: { error: e.message }, status: 400
    rescue Exception => e
      logger.debug e.message
      logger.debug e.backtrace.join "\n"
      render json: { error: e.message }, status: 400
    else
      @token.update! certificate_id: crt.id
      render json: {
        username: @token.user.name,
        certificate: crt.crt.to_pem
      }
    end
  end

  def check
    render json: { ready: @token.certificate_id.present? }
  end

  private

  def check_token
    begin
      logger.debug params.inspect
      code = params.require(:wizard_token)
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: 400
      return false
    end

    unless @token = Token.find_by_code(params.require(:wizard_token))
      render json: { error: "Token not found or expired." }, status: 404
      return false
    end

    unless @token.recent?
      render json: { error: "Token expired." }, status: 410
      return false
    end

    true
  end

end
