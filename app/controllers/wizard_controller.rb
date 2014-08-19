class WizardController < ApplicationController

  before_action :wizard

  def start
    @wizard.first
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
  end

  def steps
    %w[install add_user scan waiting]
  end

end
