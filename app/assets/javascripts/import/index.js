$(document).ready(function() {
  new ImportsIndex();
});

/*
************ Imports Index ************
*/


/**
* Imports Index Constructor
*
* @return [void]
*/
function ImportsIndex() {
  this.div = $("#imports-index");
  this.dataUrl = importsUrl;
  this.refreshRate = 10000;
  this.table = this.initTable();

  this.setListeners();
  this.refreshData(true);
}


/*
************ General ************
*/


/**
 * Posts data to server, runs callbacks
 *
 * @param params [Object] request parameters, must contain url, type, data, callback, withLoading
 * @return [void]
 */
ImportsIndex.prototype.executeRequest = function (params) {
  if (params.withLoading)
    this.loading(true);

	$.ajax({
		url: params.url,
		data: params.data,
		type: params.type,
    cache: false,
		dataType: 'json',
		context: this,
		success: function(result){
			params.callback(result);
		},
		error: function (xhr, status, error) {
			handleAjaxError(xhr, status, error);
      this.loading(false);
		}
	});
}

/**
* Sets events listeners, handlers
*
* @return [void]
*/
ImportsIndex.prototype.setListeners = function() {
  $("#clear_button").on("click", this.removeItems.bind(this, false));
  $("#main tbody").on("click", ".btn.remove", this.removeItems.bind(this, false));
  setInterval(this.refreshData.bind(this, false), this.refreshRate);
}

/**
* Empties table and builds a request to reload data
*
* @return [void]
*/
ImportsIndex.prototype.refreshData = function(withLoading) {
  this.table.clear();

  this.executeRequest({
    url: this.dataUrl,
    type: "GET",
    data: {},
    withLoading: withLoading,
    callback: function(result){
      $.each(result.data, function(i, import_data) {
        this.table.row.add(import_data);
      }.bind(this));

      this.table.draw();
      this.loading(false);
    }.bind(this)
  });
}

/**
* Builds delete import request
*
* @param confirmed [Boolean] set to true if ConfirmationDialog should be skipped
* @param e [Event] original click event
* @return [void]
*/
ImportsIndex.prototype.removeItems = function(confirmed, e) {
  if (!confirmed) {
    new ConfirmationDialog(this.removeItems.bind(this, true, e), {dangerous: true}).show();
    return;
  }

  var url = $(e.target).attr("data-url");

  this.executeRequest({
    url: url,
    type: "DELETE",
    data: { },
    callback: function(result){
      this.refreshData();
    }.bind(this)
  });
}


/*
************ General ************
*/


/**
* Toggle loading
*
* @param enable [Boolean] true/false - enables/disabled loading state
* @return [void]
*/
ImportsIndex.prototype.loading = function(enable) {
  this.table.processing(enable);
  this.div.find(".btns-wrap .btn").toggleClass("disabled", enable)
}

/**
* Initialize DataTable
*
* @return [DataTable Instance] Index Improts DataTable
*/
ImportsIndex.prototype.initTable = function() {
  return this.div.find("#main").DataTable({
    "order": [[ 1, 'asc' ]],
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "columns": this.columns(),
    "processing": true,
    "searching": false,
    "paging": false,
    "scrollY": 500,
    "scrollCollapse": true,
    "scrollX": true,
    "info": false,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No Imports found.",
      "processing": generateSpinner("small")
    },
  });
}

/**
* DataTable columns definitions
*
* @return [Array] array of column defs
*/
ImportsIndex.prototype.columns = function() {
  return [
    {"data": "id", "orderable": false},
    {"data": "owner"},
    {"data": "identifier"},
    {"data": "input_file"},
    {"data": "complete",  "orderable": false, "render": function (data, type, row, meta) {
      return trueFalseIcon(data, true);
    }.bind(this) },
    {"data": "success", "orderable": false, "render": function (data, type, row, meta) {
      return trueFalseIcon(data, true);
    }.bind(this) },
    {"data": "auto_load", "orderable": false, "render": function (data, type, row, meta) {
      return trueFalseIcon(data, true);
    }.bind(this) },
    {"render": function (data, type, row, meta) {
      return "<a href='" + row.import_path + "' class='btn btn-xs light'>Show</a>";
    } },
    {"render": function (data, type, row, meta) {
      return "<a href='#' class='btn btn-xs red remove' data-url='" + row.import_path + "'>Delete</a>";
    } },
  ]
}