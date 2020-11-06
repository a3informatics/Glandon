function displayAttributes(id, namespace, deleteEnabled) {

  var isoManagedId = id;
  var isoManagedNamespace = namespace;
  var deleteEnabled = deleteEnabled;
  var data = {"id": isoManagedId, "namespace": isoManagedNamespace};
  $.ajax({
    url: "/iso_managed/tags",
    type: "GET",
    data: data,
    dataType: 'json',
    beforeSend: function() {
      $('#tag_panel_spinner').addClass('display-element');
    },
    error: function (xhr, status, error) {

    },
    success: function(result){
      $('#tag_panel_spinner').removeClass('display-element');
      $('#tags_container').html('');
      for (var i=0; i < result.data.length; i++) {
        var tagItem = result.data[i];
        $('#tags_container').append('<span id="'+ tagItem.id +'" namespace="'+ tagItem.namespace +'" class="label label-info tagItem">' + tagItem.label + '</span>')
      }
      if (deleteEnabled === true) {
        $('.tagItem').css('cursor', 'pointer').append(' <span class="icon-times"></span>');
        $('.tagItem').click(function() {
          delete_tag($(this).attr('id'), $(this).attr('namespace'));
       });
      } else if (deleteEnabled === false){
        //Do nothing
      }
      if( $('#tags_container').is(':empty') ) {
        $('#tags_container').text('No tags added yet');
      };
    }
  });
}


function delete_tag(id, namespace) {
  $.ajax({
    url: "/iso_managed/delete_tag",
    data: {
      "id": isoManagedId,
      "namespace": isoManagedNamespace,
      "tag_id": id,
      "tag_namespace": namespace
    },
    dataType: 'json',
    type: 'POST',
    error: function (xhr, status, error) {
      var html = alertError("An error has occurred deleting the tag.");
      displayAlerts(html);
    },
    success: function(result){
      displayAttributes(isoManagedId, isoManagedNamespace, true);
    }
  });
}