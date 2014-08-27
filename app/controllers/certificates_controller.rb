class CertificatesController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :check_token

  def create
    begin
      crs_file = params.require(:csr)
      crt = CertificateAuthority.sign(crs_file)
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: 400
    rescue CertificateAuthority::InvalidCSR => e
      render json: { error: e.message }, status: 400
    rescue Exception => e
      logger.debug e.message
      logger.debug e.backtrace.join "\n"
      render json: { error: e.message }, status: 400
    else
      @token.update! certificate: crt.to_pem
      render json { certificate: crt.to_pem , username: User.find_by(id: session[:remember_token])}, status: 200
    end
  end

  def check
    #checkt of er een certificaat in het token zit (indien zo is linking gebeurd)
    render json: { ready: @token.certificate.present? } 
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

    unless @token = Token.find_by_code(code)
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
