/*
* Managed Item Selector Panel
*/

/*
* Params
** type [String] type of the panel (thesauri/cls/clitems)
** multiple [Boolean] enable/disable multiple item selection
** parentPanel [Object Instance] Reference to parent panel
** columns [Function] Columns definitions function
** urls [Object] index and history URLs
*/

/**
* Managed Item Selector Panel Constructor
*
* @param [Object] user-defined values
* @return [void]
*/
function MISelector(params) {
 this.params = params;
 this.div = $("#selector-" + params.type);
 this.parentPanel = params.parentPanel;
 this.initialized = false;
 this.cache = {};

 this.initTables();
 this.setListeners();
}

/**
 ****** General ******
**/

/**
 * Shows panel (load index data)
 *
 * @return [void]
 */
MISelector.prototype.show = function(){
  if (!this.initialized)
    this.loadData({
      url: this.params.urls.index,
      target: this.indexTable,
      offset: 0,
      count: this.getItemCount(this.indexTable),
      cacheData: false
    });
  else
    this.historyTable.draw();
}

/**
 * Sets event listeners & handlers
 *
 * @return [void]
 */
MISelector.prototype.setListeners = function() {
  this.indexTable.on('select.dt deselect.dt', this.onIndexSelect.bind(this));

  this.historyTable.on('select.dt deselect.dt', this.onHistorySelect.bind(this));
}

/**
* Refreshes history table
 *
 * @return [void]
 */
MISelector.prototype.refresh = function() {
  this.indexTable.rows({selected: true}).deselect().select();
}


/**
 * Marks (selects) rows based on selection
 *
 * @return [void]
 */
MISelector.prototype.markRows = function() {
  var _this = this;

  $.each(this.params.parentPanel.selection[this.params.type], function() {
    var row = _this.findRowByParam(_this.historyTable, "id", this.id);
    try { row.select(); } catch(e){};
  });
}

/**
 * Fetches data to fill tables with
 *
 * @param params [Object] Request parameters (url count offset)
 * @return [void]
 */
MISelector.prototype.loadData = function (params) {
  if(params.offset == 0)
    this.processing(true);

	$.ajax({
		url: params.url,
		type: 'GET',
		dataType: 'json',
    data: this.loadDataParams(params.count, params.offset),
		context: this,
		success: function (result) {
			$.each(result.data, function(index, item) {
				params.target.row.add(item);
			});
      params.target.draw();

			if (result.count != null && result.count >= params.count)
        this.onTablePageLoaded(params);
			else
        this.onTableLoaded(params);
		},
		error: function (xhr, status, error) {
      handleAjaxError(xhr, status, error);
			this.processing(false);
		}
	});
}

/**
 * Loads history data from server or cache
 *
 * @param data [Object] data of item selected in the index table
 * @return [void]
 */
MISelector.prototype.loadHistory = function (data) {
  var key = data.identifier + data.scope_id;

  if (!this.loadFromCache(key, this.historyTable))
    this.loadData({
      url: this.makeHistoryUrl(data.identifier, data.scope_id),
      target: this.historyTable,
      offset: 0,
      count: this.getItemCount(this.historyTable),
      cacheData: true,
      cacheKey: data.identifier + data.scope_id
    });
}

/**
 * Clears cache, table, UI
 *
 * @return [void]
 */
MISelector.prototype.reset = function() {
  var _this = this;

  this.clearCache();
  this.indexTable.clear().draw();
  this.indexTable.search("");
  this.historyTable.clear().draw();
  this.historyTable.search("");
  this.initialized = false;
}

/**
 ****** Cache ******
**/

/**
 * Load from cachce
 *
 * @param key [String] Key under which to find cached data
 * @param table [DataTable] Table which to load data into
 * @return [void]
 */
MISelector.prototype.loadFromCache = function (key, table) {
  var cacheData = this.cache[key];

  if(cacheData != null) {
    $.each(cacheData, function(index, row){ table.row.add(row); });
    table.draw();
    return true;
  }
  else
    return false;
}

/**
 * Saves data to cache
 *
 * @param key [String] Key under which to save table data
 * @param table [DataTable] Table whose data to save
 * @return [void]
 */
MISelector.prototype.saveToCache = function (key, table) {
  if (this.cache[key] == null)
    this.cache[key] = table.rows().data();
}

/**
 * Clears cache
 *
 * @return [void]
 */
MISelector.prototype.clearCache = function () {
  delete this.cache;
  this.cache = {};
}

/**
 ****** Events ******
**/

/**
 * Called when each chunk (page) of data is loaded
 *
 * @return [void]
 */
MISelector.prototype.onTablePageLoaded = function (params) {
  this.processing(false);
  toggleTableActive("#index", false);
  params.offset += params.count;

  this.loadData(params);
}

/**
 * Called when each data is finished loading
 *
 * @return [void]
 */
MISelector.prototype.onTableLoaded = function (params) {
  if (params.cacheData)
    this.saveToCache(params.cacheKey, params.target);

  this.processing(false);
  this.initialized = true;
}

/**
 * Select Index Table Item Event
 *
 * @return [void]
 */
MISelector.prototype.onIndexSelect = function (e, dt, type, indexes) {
  switch (e.type) {
    case "select":
      var data = this.indexTable.row(indexes[0]).data();
      this.loadHistory(data);
      break;
    case "deselect":
      this.clearTable(this.historyTable);
      break;
  }
}

/**
 * Select History Table Item Event
 *
 * @return [void]
 */
MISelector.prototype.onHistorySelect = function (e, dt, type, indexes) {
  var parentData = this.indexTable.rows({selected: true}).data()[0];
  var data = this.historyTable.rows(indexes).data();
  var selected = e.type == "select";
  data.each(function(d){d.notation = parentData.notation });

  this.parentPanel.onPanelSelectionChange(this.params.type, selected, data);
}

/**
 ****** Support ******
**/

/**
 * Generates history url
 *
 * @param identifier [String] Item identifier
 * @param scopeId [String] Scope Id
 * @return [String] history url
 */
MISelector.prototype.makeHistoryUrl = function (identifier, scopeId) {
  return this.params.urls.history.replace("miHistoryId", identifier).replace("miScopeId", scopeId);
}

/**
 * Generates item count for request for fetching data
 *
 * @return [Int] Item count for specific type
 */
MISelector.prototype.getItemCount = function(target){
	if (target == this.indexTable)
    return 1000;
  else
    return 100;
}

/**
 * Finds a row in a DataTable based on data
 *
 * @param [DataTable] table to search in
 * @param [String] DataType by which to search, e.g. id
 * @param [String] Value which to compare
 * @return [DatatTable Row] DataTable Row result api instance (can be empty)
 */
MISelector.prototype.findRowByParam = function (table, dataType, data) {
	return table.row(function (idx, dt, node) {
		return dt[dataType] == data ? true : false;
	});
}

/**
 * Deselects all items
 *
 * @return [void]
 */
MISelector.prototype.deselectAll = function(){
  this.historyTable.rows({selected: true}).deselect().draw();
}

/**
 * Generates parameters for request for fetching data
 *
 * @param [Int] Data Count
 * @param [Int] Data Offset
 * @return [Object] ajax load data parameters
 */
MISelector.prototype.loadDataParams = function(c, o){
  switch (this.params.type) {
    case "clitems":
    case "cls":
      return { managed_concept: { count: c, offset: o, type: "all" } };
    case "thesauri":
      return { thesauri: { count: c, offset: o } };
    case "bcs":
      return { biomedical_concept: { count: c, offset: o } };
  }
}

/**
 * Enables or disables processing within the modal tables
 *
 * @param enable [Boolean] Processing enable / disable == true / false
 * @return [void]
 */
MISelector.prototype.processing = function (enable) {
  this.indexTable.processing(enable);
  this.historyTable.processing(enable);
  toggleTableActive("#index", !enable);
  toggleTableActive("#history", !enable);
}

/**
 * Clears target table data
 *
 * @param target [DataTable] Target table
 * @return [void]
 */
MISelector.prototype.clearTable = function (target) {
  target.rows().remove().draw();
}

/**
 ****** Initializers ******
**/

/**
 * Initialize all tables
 *
 * @return [void]
 */
MISelector.prototype.initTables = function() {
  this.indexTable = this.indexTableInit();
  this.historyTable = this.historyTableInit();
}

/**
 * Initializes Index table
 *
 * @return [DataTable] initialized DT instance
 */
MISelector.prototype.indexTableInit = function() {
  return $(this.div).find("#index").DataTable({
    "order": [[0, "desc"]],
		"columns": this.params.columns("index", this.params.type),
		"pageLength": 10,
    "lengthChange": false,
		"processing": true,
		"paging": true,
    "scrollY": 400,
    "scrollCollapse": true,
    "select": "single",
    "autoWidth": false,
		"language": {
			"infoFiltered": "",
			"emptyTable": "No items were found.",
			"processing": generateSpinner("small")
		},
    "createdRow": function(row, data, dataIndex) {
     $(row).addClass(data.owner.toLowerCase() == "cdisc" ? 'row-cdisc y' : 'row-sponsor b');
   }
  });
}

/**
 * Initializes History table
 *
 * @return [DataTable] initialized DT instance
 */
MISelector.prototype.historyTableInit = function () {
  return $(this.div).find("#history").DataTable({
    "order": [[0, "desc"]],
		"columns": this.params.columns("history", this.params.type),
		"pageLength": 10,
    "lengthChange": false,
		"processing": true,
    "scrollY": 400,
    "scrollCollapse": true,
    "select": (this.params.multiple == true ? "multi" : "single"),
		"paging": true,
    "autoWidth": false,
		"language": {
			"infoFiltered": "",
			"emptyTable": "No items were found.",
			"processing": generateSpinner("small")
		},
    "drawCallback": function( settings ) {
      this.markRows();
    }.bind(this)
  });
}
