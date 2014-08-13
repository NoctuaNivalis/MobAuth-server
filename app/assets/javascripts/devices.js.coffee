# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $("#add-button").prop('disabled', true)

  $("#add-field").keyup ->
    $("#add-button").prop('disabled', this.value == "" ? true : false)

  $("#add-button").click (e) ->
    e.preventDefault()
    $("#link-modal").modal({
      show: true
    })

  $(".link-modal-close").click (e) ->
    # nothing special yet

  $("#link-modal-save").click (e) ->
    e.preventDefault()
    $("#link-modal").modal('hide')
    $("#new_device").append($("#new_device").parent().find('input').clone())
    $("#new_device").append('<input type="hidden" name="_method" value="post">')
    $("#new_device").submit()
  
$(document).ready(ready)
$(document).on('page:load', ready)
