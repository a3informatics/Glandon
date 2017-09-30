var isoManagedTableReload;
var isoManagedTable;
var tagId;
var tagNamespace;

function imlRefresh(id, namespace) {
  tagId = id;
  tagNamespace = namespace
  if (!isoManagedTableReload) {
    imlLoad();
  } else {
    isoManagedTable.ajax.reload();
  }
}

function imlLoad () {
  isoManagedTable = $('#iso_managed_table').DataTable( {
    "ajax": {
      "url": "/iso_managed/find_by_tag",
      "data": function( d ) {
        d.id = tagId,
        d.namespace = tagNamespace
      },
      "dataSrc": "data"
    },
    "bProcessing": true,
    "bInfo" : false,
    "searching": false,
    "pageLength": 5,
    "lengthMenu": [[5, 10, 15, 20, 25], [5, 10, 15, 20, 25]],
    "language": {
           "processing": "<img src='/assets/processing-9034d5d34015e4b05d2c1d1a8dc9f6ec9d59bd96d305eb9e24e24e65c591a645.gif'>"
      },
    "columns": [
      {"data" : "scoped_identifier.identifier", "width" : "30%"},
      {"data" : "label", "width" : "50%"},
      {"data" : "scoped_identifier.version", "width" : "10%"},
      {"data" : "scoped_identifier.version_label", "width" : "10%"},
      // Following replaces the old way of putting in a button. Use link styled as a button.
      {"render" : function (data, type, row, meta) {
        return '<a href="' + getPathStrong(row.type, row.id, row.namespace) + '" class="btn btn-primary btn-xs">Show</a>';
      }}
    ]
  });
  isoManagedTableReload = true;    
}
;
