/*
* Modal Panel
*/


/**
* Modal Panel Constructor
* @param id [String] The id of the Code List
*
* @return [void]
*/
function IndexSubsets(id) {
  this.id = id;
  this.modalTable = null;
  var counter = 0;

  this.columns = [
    {"data" : "identifier"},
    {"data" : "notation"},
    {"data" : "label"},
    {"data" : "definition"},
    {className: "text-right", "render" : function (data, type, row, meta) {
      var id = "con-menu-" + counter;
      var menu_items =
      [
        { link_path: row["show_path"], disabled: false, icon: "icon-view", text: "Show" },
        { link_path: row["edit_path"], disabled: row["edit_path"] == "", icon: "icon-edit", text: "Edit" }
      ];
      counter ++;
      return generateContextMenu(id, menu_items, null, "left");
      }
    }
  ];
  this.initTable();
  var _this = this;

  // Get selected th callback
  $('#new_subset').click(function() {
    $('#subsets-index-modal').modal('hide');
    setTimeout(function(){ $('#th-select-modal').modal('show'); }, 600);

  });

  $('#subsets-index-modal').on('shown.bs.modal', function () {
    _this.modalTable.columns.adjust();
  });
}

/**
 * Initialise the table/datatable
 * @return [void]
 */
IndexSubsets.prototype.initTable = function() {
  var _this = this;

  var loading_html = generateSpinner("medium");

  _this.modalTable = $('#subsets-index-table').DataTable( {
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "processing": true,
    "ajax": {
      "url": "/thesauri/managed_concepts/"+_this.id+"/find_subsets",
      "data": {"context_id": context_id},
      "error": function (xhr, error, code) {
        handleAjaxError(xhr, status, error);
      }
    },
    "rowId": "id",
    "deferLoading": 0,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No subsets found.",
      "processing": generateSpinner("medium"),
    },
    "columns": _this.columns,
    "orderCellsTop": true,
  });
};


IndexSubsets.prototype.createSubsetCallback = function(data) {
  if(data == null)
    this.createSubset();
  else
    this.createSubsetThesaurus(data);
}

IndexSubsets.prototype.createSubset = function() {
  $.ajax({
    url: createSubsetUrl,
    type: "POST",
    dataType: 'json',
    contentType: 'application/json',
    error: function (xhr, status, error) {
      displayError("An error has occurred.");
    },
    success: function(result) {
      location.href = result.edit_path;
    }
  });
}

IndexSubsets.prototype.createSubsetThesaurus = function(data) {
  $.ajax({
    url: createSubsetInThUrl,
    type: "POST",
    data: JSON.stringify({thesauri: data}),
    dataType: 'json',
    contentType: 'application/json',
    error: function (xhr, status, error) {
      displayError("An error has occurred.");
    },
    success: function(result) {
      location.href = result.edit_path;
    }
  });
}
