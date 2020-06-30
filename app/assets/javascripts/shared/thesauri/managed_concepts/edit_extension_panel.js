/*
* Edit Extension Panel
*
* Requires:
* extension_children_table [Table] the managed item table
*/

/**
 * Edit Extension Panel Constructor
 *
 * @param urls [Object] contains loadUrl, updateUrl, childUpdateUrl
 * @param extensionId [String] id of the extension being edited
 * @param count [Integer] Number of items fetched in one request
 * @param callback [Function] Function to be called on extension edit
 * @return [void]
 */
function EditExtensionPanel(urls, extensionId, count, callback) {
  var _this = this;
  this.urls = urls;
  this.extensionId = extensionId;
  this.count = count;
  this.callback = callback;
  this.tableId = '#extension-children-table';

  this.init();
  this.loadData(0);
}

/**
 * Initializes the children DataTable
 *
 * @return [void]
 */
EditExtensionPanel.prototype.init = function(){
  this.table = $(this.tableId).DataTable( {
    "order": [[ 0, "desc" ]],
    "columns": this.columns(),
    "pageLength": pageLength, // Global setting
    "lengthMenu": pageSettings, // Global setting
    "paging": true,
    "processing": true,
    "autoWidth": false,
    "select": "api",
    "language": {
      "infoFiltered": "",
      "emptyTable": "No child items.",
      "processing": generateSpinner("small")
    },
  });
}

/**
 * Loads data into children table and handles UI update
 *
 * @param offset [Integer] the offset to retrieve
 * @return [void]
 */
EditExtensionPanel.prototype.loadData = function (offset) {
  this.processing(true);

  $.ajax({
    url: this.urls.loadUrl,
    data: {"count": this.count, "offset": offset},
    type: 'GET',
    dataType: 'json',
    context: this,
    success: function(result) {
      for (i=0; i<result.data.length; i++) {
        this.table.row.add(result.data[i]);
      }
      this.table.draw();

      if (result.count >= this.count)
        this.loadData(result.offset + this.count);
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
 * Update extension ajax call, refreshes table if callback not set
 *
 * @param params [Object] params containing: url, type, data
 * @param callback [Function] success callback (optional)
 * @return [void]
 */
EditExtensionPanel.prototype.updateExtension = function(params, callback) {
  this.processing(true);

  $.ajax({
    url: params.url,
    type: params.type,
    data: params.data,
    dataType: 'json',
    contentType: 'application/json',
    context: this,
    success: function(result) {
      this.processing(false);
      if(callback != null)
        callback(result);
      else
        this.refresh();
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      this.processing(false);
    }
  });
}

/**
 * Adds children items to the extension
 *
 * @param ids [Array] the array with news id items
 * @return [void]
 */
EditExtensionPanel.prototype.addToExtension = function(ids) {
  var params = {
    url: this.urls.updateUrl,
    type: "POST",
    data: JSON.stringify({managed_concept: {"extension_ids": ids}})
  }

  this.updateExtension(params, null);
}

/**
 * Delete child item from the extension
 *
 * @param id [String] the id of the item to remove
 * @return [void]
 */
EditExtensionPanel.prototype.removeFromExtension = function(id) {
  var params = {
    url: this.urls.destroyChildUrl.replace("umcid", id),
    type: "DELETE",
    data: JSON.stringify({unmanaged_concept: {"parent_id": this.extensionId}})
  }

  this.updateExtension(params, null);
}

/**
 * Creates a new item as a child of the extension
 *
 * @return [void]
 */
EditExtensionPanel.prototype.newExtensionChild = function() {
  var params = {
    url: this.urls.newChildUrl,
    type: "POST",
    data: JSON.stringify({managed_concept: {identifier: "SERVERIDENTIFER"}})
  }

  this.updateExtension(params, null);
}

/**
 * Creates new item(s) as a child of the extension based on synonyms
 *
 * @param id [String] the id of the reference item
 * @param count [Int] number of synonyms that the item has
 * @return [void]
 */
EditExtensionPanel.prototype.newExtensionSynChildren = function(id, count) {
  this.itemSelectUI(false);

  if(count < 1)
    return;

  var params = {
    url: this.urls.newSynChildUrl,
    type: "POST",
    data: JSON.stringify({managed_concept: {reference_id: id}})
  }

  this.updateExtension(params, null);
}

/**
 * Edit item properties handler; finds row, appends parent, context id, calls the EditProperties modal
 *
 * @param id [String] id of the item to edit properties of
 * @return [void]
 */
EditExtensionPanel.prototype.editItemProperties = function(id) {
  var row = this.findRowByParam("id", id);
  row.data()["parent_id"] = extensionId;
  row.data()["context_id"] = contextId;
  var callback = function(item) { row.data(item); this.updateUI(); }.bind(this);

  new EditProperties(row.data(), "child", "UnmanagedConcept", callback).show();
}

/**
 * Handles click on exlude button in a table row, opens ConfirmationDialog
 *
 * @param id [String] id of the item to edit properties of
 * @return [void]
 */
EditExtensionPanel.prototype.excludeItemHandler = function(id) {
  new ConfirmationDialog (
    this.removeFromExtension.bind(this, [id]),
    { subtitle: "This action will remove the item from the extension. If this is its only parent, it will be deleted altogether.",
      dangerous: true }).show();
}

/**
 * Sets the event listeners and handlers in the panel
 *
 * @return [void]
 */
EditExtensionPanel.prototype.setListeners = function () {
  var _this = this;

  // New child item in extension event
  $("#new-item-button")
    .off('click')
    .on('click', this.newExtensionChild.bind(this));

  // New child item fron synonym in extension event
  $("#new-from-synonyms-button")
    .off('click')
    .on('click', this.newFromSynonymHandler.bind(this));

  // Remove item from extension event
  $(this.tableId)
    .off('click', '.exclude')
    .on('click', '.exclude', function(){ _this.excludeItemHandler.bind(_this, $(this).attr("data-id"))() });

  // Edit item properties event
  $(this.tableId)
    .off('click', '.update-properties')
    .on('click', ".update-properties", function() { _this.editItemProperties.bind(_this, $(this).attr("data-id"))() });
}

/**
 * Handles click on new item from synonym button
 *
 * @return [void]
 */
EditExtensionPanel.prototype.newFromSynonymHandler = function() {
  this.itemSelectUI(true);

  var _this = this;

  // Select row event
  this.table.off('select').on('select', function (e, dt, type, indexes) {
    var row = _this.table.row(indexes[0]);
    var synonyms = row.data().synonym.split(';');
    var synonymsCount = (synonyms.length == 1 ? (synonyms[0].length > 0 ? 1 : 0) : synonyms.length);
    var confirmText = "This action will create " + synonymsCount + " new Code List Item(s) in this extension based on this item's synonyms.";

    new ConfirmationDialog(
      _this.newExtensionSynChildren.bind(_this, row.data().id, synonymsCount),
      { subtitle: confirmText },
      _this.itemSelectUI.bind(_this, false)).show();
  });

  // Cancel selection event
  $("#item-from-synonyms-cancel")
    .off("click")
    .on("click", _this.itemSelectUI.bind(_this, false));
}

/**
 * Enables / Disables selection of a table row for creating an item from synonyms
 *
 * @param enable [Boolean] selecting enable/disable ~ true/false
 * @return [void]
 */
EditExtensionPanel.prototype.itemSelectUI = function(enable){
  if(enable){
    this.table.select.style('single');
    $("#extension-children-table").addClass('table-row-clickable no-mark');
    $("#edit-extension-actions").children().addClass("disabled");
    $('.table-row-clickable tbody tr, html, body').attr('style', 'cursor: crosshair');
    $("#item-from-synonyms-help").show();
  }
  else{
    this.table.row({selected: true}).deselect();
    this.table.select.style('api');
    $('.table-row-clickable tbody tr, html, body').removeAttr('style');
    $("#extension-children-table").removeClass('table-row-clickable no-mark');
    $("#edit-extension-actions").children().removeClass("disabled");
    $("#item-from-synonyms-help").hide();
  }
}

/**
 * Enables / Disables processing on the panel
 *
 * @param enable [Boolean] processing enable/disable ~ true/false
 * @return [void]
 */
EditExtensionPanel.prototype.processing = function(enable){
  if(enable){
    this.table.processing(true);
    $("#edit-extension-actions").children().addClass("disabled");
  }
  else{
    this.table.processing(false);
    $("#edit-extension-actions").children().removeClass("disabled");
  }
}

/**
 * Updates panel UI
 *
 * @return [void]
 */
EditExtensionPanel.prototype.updateUI = function() {
  this.table.columns.adjust();
  this.table.draw();
  this.callback();
  this.setListeners();
}

/**
 * Refresh table
 *
 * @return [void]
 */
EditExtensionPanel.prototype.refresh = function() {
  this.table.clear();
  this.loadData(0);
  this.callback();
}

/**
 * Finds a row in a DataTable based on data
 *
 * @param dataType [String] DataType by which to search, e.g. id
 * @param data [Object] Data value object which to compare
 * @return [DatatTable Row] DataTable Row result api instance (can be empty)
 */
EditExtensionPanel.prototype.findRowByParam = function (dataType, data) {
	return this.table.row(function (idx, dt, node) {
		return dt[dataType] == data ? true : false;
	});
}

/**
 * Generates the HTML for exlude button of a child item
 *
 * @param data [Object] item data object
 * @return [String] Formatted HTML with id as data-id attribute
 */
EditExtensionPanel.prototype.excludeBtnHTML = function (data) {
	return "<span class='icon-times text-accent-2 clickable text-small exclude ttip' data-id='"+data.id+"'>"+
            "<span class='ttip-text ttip-left shadow-small text-small text-medium'>"+
              "Exclude item"+
            "</span>"+
          "</span>";
}

/**
 * Generates the HTML for edit button of a child item
 *
 * @param data [Object] item data object
 * @return [String] Formatted HTML with id as data-id attribute
 */
EditExtensionPanel.prototype.editBtnHTML = function (data) {
	return "<span class='icon-edit text-link clickable text-small update-properties ttip' data-id='"+data.id+"'>"+
            "<span class='ttip-text ttip-left shadow-small text-small text-medium'>"+
              "Edit item properties"+
            "</span>"+
          "</span>";
}

/**
 * Table columns
 *
 * @return [Array] Object of column definitions
 */
EditExtensionPanel.prototype.columns = function () {
	return [
    {"data" : "identifier"},
    {"data" : "notation"},
    {"data" : "preferred_term"},
    {"data" : "synonym"},
    {"data" : "definition"},
    {"data" : "tags", "render" : function (data, type, row, meta) {
      return (data == null ? data : colorCodeTagsBadge(data));
    }},
    {"render" : function (data, type, row, meta) {
      return (row.referenced ? "" : this.editBtnHTML(row));
    }.bind(this)},
    {"render" : function (data, type, row, meta) {
      return (row.delete ? this.excludeBtnHTML(row) : "");
    }.bind(this)}
  ];
}
