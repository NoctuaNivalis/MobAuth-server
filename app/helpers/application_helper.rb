module ApplicationHelper

  # Form helpers
  #

  def form_errors(object)
    render partial: 'form_errors', locals: { object: object }
  end

  def show_flash
    raw("$(\"#flash\").html(\"#{escape_javascript render partial: 'flash'}\");")
  end

end
