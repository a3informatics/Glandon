$(document).ready(function() {
  new UploadsSelector();
});


/*
************ Uplods Selector ************
*/


/**
* Uploads Selector Constructor
*
* @return [void]
*/
function UploadsSelector() {
  this.div = $("#uploads-body");
  this.removeUrl = removeUploadsUrl;
  this.removeAllUrl = removeAllUploadsUrl;
  this.table = this.initTable();

  this.setListeners();
}


/*
************ General ************
*/


/**
 * Posts data to server, runs callbacks
 *
 * @param params [Object] request parameters, must contain url, type, data, callback
 * @return [void]
 */
UploadsSelector.prototype.executeRequest = function (params) {
  this.loading(true);

	$.ajax({
		url: params.url,
		data: params.data,
		type: params.type,
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
* Sets event listeners, handlers
*
* @return [void]
*/
UploadsSelector.prototype.setListeners = function() {
  $("#select-all-files").on("click", function() {
    this.table.rows().select();
  }.bind(this));

  $("#deselect-all-files").on("click", function() {
    this.table.rows().deselect();
  }.bind(this));

  $("#remove-selected-files").on("click", this.removeItems.bind(this, false));
}

/**
* Builds request to remove one or more uploads.
*
* @param confirmed [Boolean] set to true if ConfirmationDialog should be skipped
* @return [void]
*/
UploadsSelector.prototype.removeItems = function(confirmed) {
  if (!confirmed) {
    new ConfirmationDialog(this.removeItems.bind(this, true), {dangerous: true}).show();
    return;
  }

  var selected = this.table.rows({selected: true});

  if (selected.count() == 0)
    return;

  var requestUrl = selected.count() == this.table.rows().count() ? this.removeAllUrl : this.removeUrl,
      data = selected.data().toArray().map(function(r) { return r[0] == "" ? r[1] : (r[1] + "." + r[0]) });

  this.executeRequest({
      url: requestUrl,
      type: "DELETE",
      data: { upload: { files: data } },
      callback: function(result){
        selected.remove().draw();
        this.loading(false);
      }.bind(this)
  });
}


/*
************ Support ************
*/


/**
* Toggle loading
*
* @param enable [Boolean] true/false - enables/disabled loading state
* @return [void]
*/
UploadsSelector.prototype.loading = function(enable) {
  this.table.processing(enable);
  this.div.find(".btns-wrap .btn").toggleClass("disabled", enable)
}

/**
* DataTable Initialize
*
* @return [DataTable Instance] Initialized Uploads DataTable
*/
UploadsSelector.prototype.initTable = function() {
  return $("#uploaded-files").DataTable({
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "processing": true,
    "searching": false,
    "paging": false,
    "select": "multi",
    "scrollY": 400,
    "scrollCollapse": true,
    "scrollX": true,
    "info": false,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No files in the Uploads directory.",
      "processing": generateSpinner("small")
    },
  });
}