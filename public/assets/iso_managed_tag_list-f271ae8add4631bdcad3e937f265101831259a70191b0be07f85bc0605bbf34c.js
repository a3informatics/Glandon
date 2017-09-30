var isoManagedTagTableReload;
var isoManagedTagTable;
var isoManagedId;
var isoManagedNamespace;
var tagRow;
var tagData;

function imtlInit(id, namespace) {
  isoManagedId = id;
  isoManagedNamespace = namespace
  tagRow = null;
  tagData = null;
}

function imtlRefresh() {
  if (!isoManagedTagTableReload) {
    imtlLoad();
  } else {
    isoManagedTagTable.ajax.reload();
  }
}

function imtlLoad () {
  isoManagedTagTable = $('#iso_managed_tag_table').DataTable( {
    "ajax": {
      "url": "/iso_managed/tags",
      "data": function( d ) {
        d.id = isoManagedId,
        d.namespace = isoManagedNamespace
      },
      "dataSrc": "data"
    },
    "processing": true,
    "bInfo" : false,
    //"searching": false,
    "pageLength": 5,
    "lengthMenu": [[5, 10, 15, 20, 25], [5, 10, 15, 20, 25]],
    "language": {
           "processing": "<img src='/assets/processing-9034d5d34015e4b05d2c1d1a8dc9f6ec9d59bd96d305eb9e24e24e65c591a645.gif'>"
      },
    "columns": [
      {"data" : "label"},
    ]
  });
  isoManagedTagTableReload = true;    
}

$(document).ready(function() {

  $('#tag_add').click(function() {
    if (d3eCurrentSet) {
      var node = d3eGetCurrent();
      if (node.type == C_TAG) {
        add_tag(node.data)
      } 
    } else {
      var html = alertWarning("You need to select a tag node.");
      displayAlerts(html);
    }
  });

  $('#tag_delete').click(function() {
    if (tagRow != null) {
      delete_tag(tagData.id, tagData.namespace)
    } else {
      var html = alertWarning("You need to select a tag.");
      displayAlerts(html);
    }
  });

  $('#iso_managed_tag_table tbody').on('click', 'tr', function () {
    var row = isoManagedTagTable.row(this).index();
    var data = isoManagedTagTable.row(row).data();
    if (tagRow != null) {
      $(tagRow).toggleClass('success');
    }
    $(this).toggleClass('success')
    tagData = data;
    tagRow = this
  });

  function add_tag(data) {
    $.ajax({
      url: "/iso_managed/add_tag",
      data: {
        "id": isoManagedId,
        "namespace": isoManagedNamespace,
        "tag_id": data.id,
        "tag_namespace": data.namespace
      },
      dataType: 'json',
      type: 'POST',
      error: function (xhr, status, error) {
        var html = alertError("An error has occurred adding the tag.");
        displayAlerts(html);
      },
      success: function(result){
        imtlRefresh();
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
        imtlRefresh();
        tagRow = null;
        tagData = null;
      }
    });
  }

});
