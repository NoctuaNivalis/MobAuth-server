class CertificatesController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    unless @token = Token.find_by_code(params.require(:wizard_token))
      render json: { error: "Token not found or expired." }, status: 404
      return
    end

    unless @token.recent?
      render json: { error: "Token expired." }, status: 410
      return
    end

    begin
      crs_file = params.require(:csr)
      crt = CertificateAuthority.sign(crs_file)
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: 400
    rescue CertificateAuthority::InvalidCSR => e
      render json: { error: e.message }, status: 400
    #rescue Exception => e
    #  logger.debug e.message
    #  logger.debug e.backtrace.join "\n"
    #  render json: { error: e.message }, status: 400
    else
      @token.update! certificate: crt.to_pem
      render plain: crt.to_pem
    end
  end

end
