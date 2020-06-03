/*
* Subset Edit Children Panel
*
* Requires:
* source_children_table [Table] the table of children of the source code-list in the subset edit page
* subset_edit_children_table [Table] the table of children of the subset code-list in the subset edit page
*/

/**
 * Subset Edit Children Panel Constructor
 *
 * @param urls [Object] Various urls for panel functionality
 * @param count [Integer] amount of items fetched in one call
 * @param lockCallback [Function] callback to extend the edit lock timer
 * @return [void]
 */
function SubsetEditChildrenPanel(urls, count, lockCallback) {
  this.urls = urls;
  this.count = count;
  this.extendLock = lockCallback;

  this.init();
  this.loadData(0);
}

/**
 * Initializes DataTable
 *
 * @return [void]
 */
SubsetEditChildrenPanel.prototype.init = function() {
  this.childrenTable = $('#subset_children_table').DataTable( {
    "columns": this.columns(),
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "processing": true,
    "searching": false,
    "scrollY": 600,
    "scrollCollapse": true,
    "paging": true,
    "autoWidth": false,
    "rowReorder": {
      "dataSrc": "ordinal",
      "selector": 'tr',
    },
    "language": {
      "infoFiltered": "",
      "emptyTable": "This subset is empty. Add children by selecting them from the source code list.",
      "processing": generateSpinner("small")
    },
  });
}

/**
* User updates item (add/remove a child from the subset)
 *
 * @param offset [Integer] item count offset
 * @return [void]
 */
SubsetEditChildrenPanel.prototype.loadData = function (offset) {
  this.processing(true);

  $.ajax({
    url: this.urls.childrenUrl,
    data: {"count": this.count, "offset": offset},
    type: 'GET',
    dataType: 'json',
    context: this,
    success: function(result) {
      for (i=0; i<result.data.length; i++) {
        this.childrenTable.row.add(result.data[i]);
      }
      this.childrenTable.draw();

      if (result.count >= this.count) {
        this.loadData(result.offset + this.count)
      } else {
        this.updateUI();
        this.processing(false);
      }
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      this.processing(false);
    }
  });
}

/**
 * Update the Thesaurus selection, extends edit lock
 * @param action [String] (add/remove),
 * @param data [Array] ids of items
 * @param callback [Function] callback executed on request success
 *
 * @return [void]
 */
 SubsetEditChildrenPanel.prototype.updateSubset = function (action, data, callback) {
	this.extendLock();
	this.processing(true);

	setTimeout(function(){ this.executeRequest(this.buildRequestParams(action, data), callback) }.bind(this), 0);
}

/**
 * Posts data to server, runs callbacks
 * @param requestParams [Object] parameters, must contain:
 		url [String],
		data [Object] formatted for the request,
		request type [String]
 * @param callback [Function] callback executed on request success
 *
 * @return [void]
 */
SubsetEditChildrenPanel.prototype.executeRequest = function (requestParams, callback) {
	$.ajax({
		url: requestParams.url,
		data: requestParams.data,
		type: requestParams.type,
		dataType: 'json',
		context: this,
		success: function(result){
			try { callback() } catch(exc) {};
      this.refresh();
		},
		error: function (xhr, status, error) {
			handleAjaxError(xhr, status, error);
			this.refresh();
		}
	})
}


/**
 * Sets Listeners
 *
 * @return [void]
 */
SubsetEditChildrenPanel.prototype.setListeners = function() {
  this.childrenTable.off('row-reordered').on('row-reordered', function(e, details, changes){
    if(details.length > 0)
      this.reorderChild(details, changes.triggerRow.data());
  }.bind(this));
}

/**
 * Handler for changing the order of the subset children
 *
 * @param details [Object] original details object from rowReorder
 * @param rowData [Object] data of the trigger row
 * @return [void]
 */
SubsetEditChildrenPanel.prototype.reorderChild = function(details, rowData) {
  var t = $.grep(details, function(e){ return e.newData == rowData.ordinal})[0];

  var newOrdinal = t.newData;
  var targetId = rowData.member_id;
  var previous = this.findRowByParam("ordinal", newOrdinal - 1);
  var previousId = previous[0].length == 0 ? null : previous.data().member_id;

  var data = {member_id: targetId};
  if(previousId != null)
   data.after_id = previousId;

  this.updateSubset("move_after", data, null);
}


/**
 * Refreshes data in table
 *
 * @return [void]
 */
SubsetEditChildrenPanel.prototype.refresh = function () {
  this.childrenTable.clear();
  this.loadData(0);
  this.extendLock();
}

/**
 * Enables / Disables processing on the panel
 *
 * @param enable [Boolean] processing enable/disable ~ true/false
 * @return [void]
 */
SubsetEditChildrenPanel.prototype.processing = function(enable){
  if(enable){
    this.loading = true;
    this.childrenTable.processing(true);
    toggleTableActive("#source_children_table", false);
    $("#subset-edit-btns").children().addClass("disabled");
  }
  else{
    this.loading = false;
    this.childrenTable.processing(false);
    toggleTableActive("#source_children_table", true);
    $("#subset-edit-btns").children().removeClass("disabled");
  }
}

/**
 * Updates panel UI, draws table, sets listeners
 *
 * @return [void]
 */
SubsetEditChildrenPanel.prototype.updateUI = function() {
  this.childrenTable.columns.adjust();
  this.childrenTable.draw();
  this.setListeners();
}

/**
 * Finds a row in a DataTable
 *
 * @param dataType [String] DataType by which to search ("index", or "html")
 * @param value [Anything] Value which to compare
 * @return [DataTable Row] Row from a DataTable
 */
SubsetEditChildrenPanel.prototype.findRowByParam = function(dataType, value){
  return this.childrenTable.row(function (idx, data, node){ return data[dataType] == value ? true : false; });
}

/**
 * Generates a params object for ajax request
 *
 * @param action [String] name of the action (can be "add", "remove", "remove_all", "move_after")
 * @param ids [Array] ids of affected items
 * @return [Object] params containing url, data and type
 */
SubsetEditChildrenPanel.prototype.buildRequestParams = function(action, ids){
  var params = {url: "", data: {}, type: ""};

  switch (action) {
    case "add":
      params.url = this.urls.addUrl;
      params.type = "POST";
      params.data = {subset: {cli_ids: ids}}
      break;
    case "remove":
      params.url = this.urls.removeUrl;
      params.type = "DELETE";
      params.data = {subset: {member_id: this.findRowByParam("id", ids[0]).data().member_id}}
      break;
    case "remove_all":
      params.url = this.urls.removeAllUrl;
      params.type = "DELETE";
      params.data = {};
      break;
    case "move_after":
      params.url = this.urls.moveAfterUrl;
      params.type = "PUT";
      params.data = {subset: ids}
      break;
  }
  return params;
}

/**
 * Column definitions for DataTable
 *
 * @return [Array] of objects, column defs
 */
SubsetEditChildrenPanel.prototype.columns = function() {
  var _this = this;

  return [
    {"data" : "ordinal"},
    {"data" : "preferred_term",
     "render": function (data, type, row, meta) {
        if (type == "display")
          return _this.childItemHTML(row);
        else return data;
    }}
  ];
}

/**
 * Generates HTML for a child item in the table
 *
 * @param data [JSON Object] Child item JSON
 * @return [String] Formatted HTML
 */
SubsetEditChildrenPanel.prototype.childItemHTML = function(data) {
  var html = '<div class="font-regular text-small">'+data.preferred_term+'</div>';
  html += '<div class="font-light text-small">'+data.notation+' ('+data.identifier+')</div>';
  return html;
}
