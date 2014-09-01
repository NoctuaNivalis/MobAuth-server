class CrlsController < ApplicationController

  def show
    ca = IntermediateCa.find params.require(:id)
    render plain: ca.revocation_list.to_pem
  end

end

