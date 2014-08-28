class WizardController < ApplicationController

  before_action :wizard
  before_action :token, except: [:start]

  def start
    @wizard.first
    loop do
      @token = Token.new
      break if @token.save
    end
    session[:wizard_token] = @token.code
    render partial: 'wizard'
  end

  def next
    @wizard.next
    render 'wizard'
  end

  def previous
    @wizard.previous
    render 'wizard'
  end

  private

  def wizard
    @wizard = Wizard.new steps, session
    @host = request.host_with_port
  end

  def token
    @token = Token.find_by_code session[:wizard_token]
  end

  def steps
    %w[install add_user scan waiting]
  end

end
