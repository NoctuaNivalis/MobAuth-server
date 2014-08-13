class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  protected

  def errors_to_flash object, f = flash.now
    if object.errors.any?
      f[:error] = "Could not save #{object.class.name.downcase}: #{object.errors.full_messages.first}"
    else
      f[:success] = "Saved #{object.class.name.downcase}."
    end
  end
end
