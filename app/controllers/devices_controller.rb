class DevicesController < ApplicationController

  respond_to :js

  def index
    @user = User.find params.require(:user_id)
    @devices = @user.devices
  end

  def create
    @user = User.find params.require(:user_id)
    @device = @user.devices.create params.require(:device).permit(:name)
  end

end
