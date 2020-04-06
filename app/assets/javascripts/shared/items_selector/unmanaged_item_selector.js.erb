/*
* Unmanaged Item Selector Panel [Extends: MISelector]
*/

/*
* Params
** type [String] type of the panel (thesauri/cls/clitems)
** errorDiv [JQUery Object] Div for showing errors
** multiple [Boolean] enable/disable multiple item selection
** parentPanel [Object Instance] Reference to parent panel
** columns [Function] Columns definitions function
** urls [Object] index and history URLs
*/

UMISelector.prototype = Object.create(MISelector.prototype);

/**
* Unmanaged Item Selector Panel Constructor
*
* @param [Object] user-defined values
* @return [void]
*/
function UMISelector(params) {
 MISelector.call(this, params);

}

/**
 ****** General ******
**/

/**
 * Set listeners (extends setListeners from MISelector)
 *
 * @return [void]
 */
UMISelector.prototype.setListeners = function(){
  MISelector.prototype.setListeners.call(this);

  this.childrenTable.on('select.dt deselect.dt', this.onChildSelect.bind(this));
}

/**
 * Load Data into Children Table from server / cache
 *
 * @param data [Object] data object of the parent item
 * @return [void]
 */
UMISelector.prototype.loadChildrenTable = function (data) {
  var key = data.id;

  if (!this.loadFromCache(key, this.childrenTable))
    this.loadData({
      url: this.makeChildrenUrl(data.id),
      target: this.childrenTable,
      offset: 0,
      count: 10000,
      cacheData: true,
      cacheKey: data.id
  });
}

/**
 * Deselects all items in the children table
 *
 * @return [void]
 */
UMISelector.prototype.deselectAll = function() {
  this.childrenTable.rows({selected: true}).deselect().draw();
}

/**
 * Resets cache, table (extends reset from MISelector)
 *
 * @return [void]
 */
UMISelector.prototype.reset = function() {
  MISelector.prototype.reset.call(this);

  this.childrenTable.clear().draw();
  this.childrenTable.search("");
  this.toggleTableTabs("index");
}

/**
 * Refreshes children table (overrides refresh from MISelector)
 *
 * @return [void]
 */
UMISelector.prototype.refresh = function() {
  this.historyTable.rows({selected: true}).deselect().select();
}

/**
 * Marks (selects) rows based on selection (overrides markRows from MISelector)
 *
 * @return [void]
 */
UMISelector.prototype.markRows = function() {
  var _this = this;

  $.each(this.params.parentPanel.selection[this.params.type], function() {
    var row = _this.findRowByParam(_this.childrenTable, "id", this.id);
    try { row.select(); } catch(e){ console.log(e) };
  });
}

/**
 ****** Events ******
**/

/**
 * Select Child Item Event
 *
 * @return [void]
 */
UMISelector.prototype.onChildSelect = function (e, dt, type, indexes) {
  var selected = e.type == "select";

  var parentData = this.historyTable.rows({selected: true}).data()[0];
  var data = this.childrenTable.rows(indexes).data();
  data.each(function(item){ item.parentData = parentData });

  this.parentPanel.onPanelSelectionChange(this.params.type, selected, data);
}

/**
 * History Version Select Event (overrides onHistorySelect from MISelector)
 *
 * @return [String] history url
 */
UMISelector.prototype.onHistorySelect = function (e, dt, type, indexes) {
  switch (e.type) {
    case "select":
      var data = this.historyTable.row(indexes[0]).data();
      data.notation = this.indexTable.rows({selected: true}).data()[0].notation;

      this.loadChildrenTable(data);
      this.toggleTableTabs("children");
      break;
    case "deselect":
      this.clearTable(this.childrenTable);
      this.toggleTableTabs("index");
      break;
  }
}

/**
 ****** Support ******
**/

/**
 * Toggles tabs visible / hidden
 *
 * @param targetTable [String] table to show name
 * @return [String] children url
 */
UMISelector.prototype.toggleTableTabs = function (targetTable) {
  switch(targetTable){
    case "children":
      this.div.find("#children").closest(".card").show();
      this.div.find("#index").closest(".card").hide();
      break;
    case "index":
      this.div.find("#children").closest(".card").hide();
      this.div.find("#index").closest(".card").show();
      break;
  }
}

/**
 * Generates url for CL children
 *
 * @param id [String] CL id
 * @return [String] children url
 */
UMISelector.prototype.makeChildrenUrl = function (id) {
  return this.params.urls.children.replace("miClId", id);
}

/**
 * Enables or disables processing within the modal tables
 * (extends processing from MISelector)
 *
 * @param enable [Boolean] Processing enable / disable == true / false
 * @return [void]
 */
UMISelector.prototype.processing = function (enable) {
  MISelector.prototype.processing.call(this, enable);

  this.childrenTable.processing(enable);
  toggleTableActive("#children", !enable);
}



/**
 ****** Initializers ******
**/

/**
 * Initialize all tables
 * (extends initTables from MISelector)
 *
 * @return [void]
 */
UMISelector.prototype.initTables = function() {
  MISelector.prototype.initTables.call(this);

  this.historyTable.select.style('single');
  this.childrenTable = this.childrenTableInit();
}

/**
 * Initialize the Children table
 *
 * @return [void]
 */
UMISelector.prototype.childrenTableInit = function() {
  return $(this.div).find("#children").DataTable({
    "order": [[0, "desc"]],
		"columns": this.params.columns("children", this.params.type),
		"pageLength": 10,
    "lengthChange": false,
		"processing": true,
		"paging": true,
    "scrollY": 400,
    "scrollCollapse": true,
    "select": (this.params.multiple == true ? "multi" : "single"),
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
