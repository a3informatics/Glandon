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
  this.modalTable = this.initTable();

  // Get selected th callback
  $('#new_subset').click(function() {
    $('#subsets-index-modal').modal('hide');
    setTimeout(function(){ $('#th-select-modal').modal('show'); }, 600);
  });

  $('#subsets-index-modal').on('shown.bs.modal', function () {
    this.modalTable.columns.adjust();
  }.bind(this));
}

/**
 * Initialise the table/datatable
 * @return [void]
 */
IndexSubsets.prototype.initTable = function() {
  return $('#subsets-index-table').DataTable( {
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "columns": this.columns(),
    "processing": true,
    "orderCellsTop": true,
    "ajax": {
      "url": "/thesauri/managed_concepts/"+this.id+"/find_subsets",
      "data": {"context_id": contextId},
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

IndexSubsets.prototype.columns = function() {
  counter = 0;

  return [
    {"data" : "identifier"},
    {"data" : "notation"},
    {"data" : "label"},
    {"data" : "definition"},
    {className: "text-right", "render" : function (data, type, row, meta) {
      var id = "con-menu-" + counter;
      var menuItems =
      [
        { link_path: row["show_path"], disabled: false, icon: "icon-view", text: "Show" },
        { link_path: row["edit_path"], disabled: row["edit_path"] == "", icon: "icon-edit", text: "Edit" }
      ];
      counter ++;
      return generateContextMenu(id, menuItems, null, "left");
    }}
  ];
}
