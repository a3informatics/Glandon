/*
* Extends 'Search Panel'. Modal used to search terminologies and select Code List Items. Paginated.
*/

TermSearchModal.prototype = Object.create(SearchPanel.prototype);

/**
* Term Search Modal Constructor
* @param callback [Function] called when Add Terms is clicked
* @param url [String] url of the search
*
* @return [void]
*/
function TermSearchModal(callback, url) {
  SearchPanel.call(this, url);

  this.selected = [];
  this.callback = callback; // Note that this can also be set in call to search
  this.codeListAllowed = false;

  if(!this.codeListAllowed)
    $("#searchModal .modal-info").text("Code Lists cannot be included and appear grey in the table. Only Code List Items are allowed.")
}


/**
* Initializes with url and shows self
*
* @param selection [Array / String] Search Filter  with either Term IDs or filter current/latest
* @return [void]
*/
TermSearchModal.prototype.initAndShow = function(selection) {
  this.clearSearch();

  // Make URL
  var data = {thesauri: {}};
  data.thesauri[(selection instanceof Array ? "id_set" : "filter")] = selection;
  this.url = searchMultiUrl + "?" + $.param(data);

  // Show self
  $('#searchModal').modal("show");
}

/**
* Initializes the Datatable
*
* @return [void]
*/
TermSearchModal.prototype.initTable = function() {
  this.tsSearchTable = $('#searchModal #searchTable').DataTable({
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "columns": this.columns(),
    "processing": true,
    "scrollY": 500,
    "scrollX": true,
    "scrollCollapse": true,
    "language": {
      "infoFiltered": "",
      "emptyTable": "Make a new column or global search to see data",
      "processing": generateSpinner("small"),
      "sSearch": "Filter:"
    },
    "orderCellsTop": true,
    "select": {
        style: 'multi',
        info: false,
    },
    "rowCallback": function(row, data) {
      if (this.selectionContains(data["id"]))
        this.tsSearchTable.row(row).select();
      if(!this.codeListAllowed && data.identifier == data.parent_identifier)
        $(row).addClass("disabled");
    }.bind(this),
  });
}

/**
* Row Click Event empty override
*
* @return [void]
*/
TermSearchModal.prototype.rowClickEvent = function () { }


/**
* Handles the UI for selection of deselection of an item in the table
* @param id [String] Item ID to handle
* @param select [Boolean] selecting/deselecting ~ true/false
*
* @return [void]
*/
TermSearchModal.prototype.selectOrDeselectItem = function(id, select) {
  if(select){
    if(!this.selectionContains(id))
      this.selected.push(id);
  }
  else {
    if(this.selectionContains(id))
      this.selected = $.grep(this.selected, function(v){return v != id});
  }

  this.updateUI();
}

/**
* Updates UI of the search modal
*
* @return [void]
*/
TermSearchModal.prototype.updateUI = function() {
  var itemCount = this.selected.length;
  $("#searchModal .selection-info #number-selected").text(itemCount);

  if (itemCount > 0)
    $('#searchModal #add_terms').removeClass('disabled');
  if (itemCount == 0)
    $('#searchModal #add_terms').addClass('disabled');
}

/**
* Sets the listeners and handlers for all events in the TermSearchModal
*
* @return [void]
*/
TermSearchModal.prototype.setListeners = function() {
  // Call super
  SearchPanel.prototype.setListeners.call(this);

  var _this = this;

  // Select item within table event
  this.tsSearchTable.on('select', function (e, dt, type, indexes) {
    if(type == "row"){
      var rowData = _this.tsSearchTable.row(indexes[0]).data();
      _this.selectOrDeselectItem(rowData.id, true);
    }
  });

  // Deselect item within table event
  this.tsSearchTable.on('deselect', function (e, dt, type, indexes) {
    if(type == "row"){
      var rowData = _this.tsSearchTable.row(indexes[0]).data();
      _this.selectOrDeselectItem(rowData.id, false);
    }
  });

  // Get selected rows callback
  $('#searchModal #add_terms').off('click').on('click', function() {
    if (_this.selected.length > 0)
      _this.callback(_this.selected);

    $('#searchModal').modal('hide');
  });

  // Clear selection
  $('#searchModal #clear-selection').off('click').on('click', function(){
    _this.tsSearchTable.rows({selected: true}).deselect();
    _this.selected = [];
    _this.updateUI();
  });

  // Show modal
  $('#searchModal').on('shown.bs.modal', function () {
    this.tsSearchTable.columns.adjust();
    this.updateUI();
  }.bind(this));

  // Hide modal
  $('#searchModal').on('hide.bs.modal', function () {
    $("#searchModal #abort_button").click();
    $("#searchModal #clear_button").click();
    $("#searchModal #clear-selection").click();
  }.bind(this));

}

/**
* Checks if current item selection contains an id
*
* @return [Boolean] value true if contained in the selection
*/
TermSearchModal.prototype.selectionContains = function(id) {
  return $.inArray(id, this.selected) != -1;
}
