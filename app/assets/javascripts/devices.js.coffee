# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $("#add-button").click (e) ->
    e.preventDefault()
    alert('sup!')
    $("#new_device").append($("#new_device").parent().find('input').clone());
    $("#new_device").append('<input type="hidden" name="_method" value="post">');
    $("#new_device").submit()
  
$(document).ready(ready)
$(document).on('page:load', ready)
