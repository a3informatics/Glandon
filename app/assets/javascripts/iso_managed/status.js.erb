$(document).ready(function() {

  var timer = new Timer($('#edit_lock_token').val(), "imh_header", $('#warning_timeout').val());
  var unload = new UnloadV2($('#edit_lock_token').val(), false, unloadCallback);

  $("#edit-properties-button").on("click", function() {
    new EditProperties(epItemextension, "extension", "ManagedConcept", null).show();
  });

  function unloadCallback() {
    timer.unload();
  }

  $("#version-edit-submit").on("click", function() {
    unload.keep = true;
    var value = $("#select-release option:selected").val();
    var data = { "iso_managed": { "sv_type": value } };
    $.ajax({
      url: url_release,
      type: 'PUT',
      dataType: 'json',
      data: JSON.stringify( data ),
      contentType: 'application/json',
      error: function (xhr, status, error) {
        handleAjaxError(xhr, status, error);
      },
      success: function(result){
        location.reload();
      }
    });
  });

  $(".content-editable").on("click", function(){
    $("#"+$(this).attr("id")+"-after").css("display", "inline-block");
    $(this).css("display", "none");
  });

  $(".keep-token-click").on("click", function(){
    unload.keep = true;
  });

});
