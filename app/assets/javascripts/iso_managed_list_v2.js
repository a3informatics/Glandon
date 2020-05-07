function IsoManagedListOldPanel() {
  this.isoManagedTableReload = null;
  this.isoManagedTable = null;
  this.tagId = null;
}

IsoManagedListOldPanel.prototype.refresh = function (id) {
  var _this = this;
  _this.tagId = id;
  if (!_this.isoManagedTableReload) {
    _this.load();
  } else {
    //_this.isoManagedTable.ajax.reload();
    _this.isoManagedTable.ajax.url("/iso_managed_v2/find_by_tag?[iso_managed]tag_id=" + _this.tagId).load();
  }
}

IsoManagedListOldPanel.prototype.load = function () {
  var _this = this;
  _this.isoManagedTable = $('#iso_managed_table').DataTable( {
    "ajax": {
      "url": "/iso_managed_v2/find_by_tag?[iso_managed]tag_id=" + _this.tagId,
      "dataSrc": "data",
      "error": function (xhr, error, code) {
        handleAjaxError(xhr, status, error);
      }
    },
    "bProcessing": true,
    "bInfo" : false,
    "searching": false,
    "pageLength": 5,
    "lengthMenu": [[5, 10, 15, 20, 25], [5, 10, 15, 20, 25]],
    "language": {
        "processing": generateSpinner("medium"),
        "emptyTable": "No items with the selected tag were found."
      },
    "columns": [
      {"data" : "identifier"},
      {"data" : "label"},
      {"data" : "version"},
      {"data" : "version_label"},
      // Following replaces the old way of putting in a button. Use link styled as a button.
      {"render" : function (data, type, row, meta) {
        return '<a href="' + getPathStrongV2(row.type, row.id) + '" class="btn btn-xs">Show</a>';
      }}
    ]
  });
  _this.isoManagedTableReload = true;
}
