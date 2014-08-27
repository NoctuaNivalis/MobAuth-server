class DevicesController < ApplicationController

  respond_to :js

  before_action :find_user
  before_action :find_device, only: [:edit, :update, :destroy]

  def index
    @devices = @user.devices
  end

  def create
    @device = @user.devices.new params.require(:device).permit(:name)
    token = Token.find_by_code session[:wizard_token]
    @device.certificate = Certificate.find(token.certificate_id)
    token.destroy
    @device.save
    errors_to_flash @device
  end

  def edit
  end

  def update
    @device.update params.require(:device).permit(:name)
    errors_to_flash @device
  end
    
  def destroy
    @device.certificate.revoke
    @device.destroy
    flash.now[:success] = "Device unlinked and removed."
  end

  private

  def find_user
    @user = User.find params.require(:user_id)
  end

  def find_device
    @device = Device.find params.require(:id)
  end

end
