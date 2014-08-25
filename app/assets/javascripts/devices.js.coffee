# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $("#add-button").prop('disabled', true)

  $("#add-field").keyup ->
    $("#add-button").prop('disabled', this.value == "" ? true : false)

  $("#add-button").click (e) ->
    e.preventDefault()
    $(".modal-content").load("/wizard/start", (response, status, xhr) ->
      if status == "error"
        $("#flash").html("<div class=\"alert alert-danger fade in\"><button class=\"close\" data-dismiss=\"a;ert\">&times;</button><strong>Error!</strong> Could not retrieve modal.</div>")
      else
        $("#link-modal").modal()
    );

  $(".link-modal-close").click (e) ->
    # nothing special yet

  $(document).on('click', "#link-modal-save", (e) ->
    e.preventDefault()
    $("#link-modal").modal('hide')
    $("#new_device").append($("#new_device").parent().find('input').clone())
    $("#new_device").append('<input type="hidden" name="_method" value="post">')
    $("#new_device").submit()
  );
  
$(document).ready(ready)
$(document).on('page:load', ready)
