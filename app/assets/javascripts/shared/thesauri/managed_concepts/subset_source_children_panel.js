/*
* Subset Source Children Panel
*
* Requires:
* source_children_table [Table] the table of children of the source code-list in the subset edit page
* subset_edit_children_table [Table] the table of children of the subset code-list in the subset edit page
*/

/**
 * Subset Source Children Panel Constructor
 *
 * @param url [String] url of the data source
 * @param count [Integer] count - amount of items fetched in one call
 * @param subsetEditPanel [Object Instance] subsetEditPanel - reference to the instance of the SubsetEditPanel object
 * @param lockCallback [Function] lockCallback - callback to extend the edit lock timer
 * @return [void]
 */
function SubsetSourceChildrenPanel(url, count, subsetEditPanel, lockCallback) {
  this.url = url;
  this.count = count;
  this.extendLock = lockCallback;
  this.subsetEditPanel = subsetEditPanel;
  this.autoSelectMode = false;

  this.init();
  this.loadData(0);
}

/**
 * Initializes DataTable
 *
 * @return [void]
 */
SubsetSourceChildrenPanel.prototype.init = function () {
  this.childrenTable = $('#source_children_table').DataTable( {
    "order": [[ 0, "asc" ]],
    "columns": this.columns(),
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "processing": true,
    "scrollY": 600,
    "scrollCollapse": true,
    "paging": true,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No children items found.",
      "processing": generateSpinner("small")
    },
    "select": 'multi'
  });
}


/**
 * Fetches the children items from the server
 *
 * @param offset [Integer] item count offset
 * @return [void]
 */
SubsetSourceChildrenPanel.prototype.loadData = function (offset) {
  this.processing(true);

  $.ajax({
    url: this.url,
    data: {"count": this.count, "offset": offset},
    type: 'GET',
    dataType: 'json',
    context: this,
    success: function(result) {
      for (i=0; i<result.data.length; i++) {
        this.childrenTable.row.add(result.data[i]);
      }
      this.childrenTable.draw();

      if (result.count >= this.count)
        this.loadData(result.offset + this.count)
      else {
        this.processing(false);
        this.updateUI();
      }
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      this.processing(false);
    }
  });
}

/**
 * Marks items present in the other panel green
 *
 * @return [void]
 */
SubsetSourceChildrenPanel.prototype.autoSelect = function() {
  toggleTableActive("#source_children_table", false);

	// Checks if overview table is loading, retries in 200 ms
	if(this.subsetEditPanel.loading)
		setTimeout(this.autoSelect.bind(this), 200);

	// Overview table done loading
	else {
		var _this = this;
		this.autoSelectMode = true;

		setTimeout(function () {
      this.childrenTable.rows().deselect();
			var indexes = [];
			this.subsetEditPanel.childrenTable.rows().every(function (rowIdx, tl, rl) {
				var rowResult = _this.findRowByParam("id", this.data());
				if(rowResult.length != 0)
					indexes.push(rowResult.index());
			});
			this.childrenTable.rows(indexes).select();

			this.autoSelectMode = false;
      toggleTableActive("#source_children_table", true);
		}.bind(this), 0)
	}
}

/**
 * User updates item (add/remove a child from the subset)
 *
 * @param indexes [Array] Indexes of the selected children in the Source Code List Table
 * @param action [String] Action of item handler (can be "add" or "remove")
 * @return [void]
 */
SubsetSourceChildrenPanel.prototype.addOrRemoveItems = function(indexes, action) {
  if(this.autoSelectMode)
    return;

  var itemIds = this.childrenTable.rows(indexes).data().toArray().map(function(e) { return e.id });
  var callback = this.autoSelect.bind(this);

  switch (action) {
    case "add":
      this.subsetEditPanel.updateSubset(action, itemIds, callback);
      break;
    case "remove":
      if (itemIds.length > 1)
        this.subsetEditPanel.updateSubset("remove_all", null, callback);
      else
        this.subsetEditPanel.updateSubset(action, itemIds, callback);
  }
}

/**
 * Sets event listeners
 *
 * @return [void]
 */
SubsetSourceChildrenPanel.prototype.setListeners = function () {
  var _this = this;

  this.childrenTable.off('select').on('select', function(e, dt, type, indexes){
    _this.addOrRemoveItems(indexes, "add");
  });

  this.childrenTable.off('deselect').on('deselect', function(e, dt, type, indexes){
    _this.addOrRemoveItems(indexes, "remove");
  });

  $("#select-all-button").off("click").on("click", function(){
    _this.childrenTable.rows({selected: false}).select();
  });

  $("#deselect-all-button").off("click").on("click", function(){
    _this.childrenTable.rows({selected: true}).deselect();
  });
}

/**
 * Updates UI
 *
 * @return [void]
 */
SubsetSourceChildrenPanel.prototype.updateUI = function () {
  this.childrenTable.draw();
  this.autoSelect();
  this.setListeners();
}

/**
 * Enables / Disables processing on the panel
 *
 * @param enable [Boolean] processing enable/disable ~ true/false
 * @return [void]
 */
SubsetSourceChildrenPanel.prototype.processing = function(enable){
  if(enable){
    this.childrenTable.processing(true);
    $("#subset-edit-btns").children().addClass("disabled");
  }
  else{
    this.childrenTable.processing(false);
    $("#subset-edit-btns").children().removeClass("disabled");
  }
}

/**
 * Finds a row in a DataTable based on data
 * @param dataType [String] DataType by which to search, e.g. id
 * @param data [Object] Data value object which to compare
 *
 * @return [DatatTable Row] DataTable Row result api instance (can be empty)
 */
SubsetSourceChildrenPanel.prototype.findRowByParam = function (dataType, data) {
	return this.childrenTable.row(function (idx, dt, node) {
		return dt[dataType] == data[dataType] ? true : false;
	});
}

/**
 * Column definitions for DataTable
 *
 * @return [Array] of objects, column defs
 */
SubsetSourceChildrenPanel.prototype.columns = function(){
  var _this = this;

  return [{
    "data" : "preferred_term",
    "render": function (data, type, row, meta) {
        if (type == "display")
          return _this.subsetEditPanel.childItemHTML(row);
        else return data;
      }
    }];
}