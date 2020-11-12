/*
 * Select Table
 *
 * Requires:
 * 1 or more children tables [Table]
 * 1 overview table [Table] target
 */

/**
 * Managed Children Select Table
 * @param dataUrl [String] url of the data source, must match columns format on the bottom
 * @param tableId [String] id of the table
 * @param count [Integer] Number of items fetched in one request
 * @param target [Object Instance] reference to the table object instance
 * @param type [String] type of the data and columns format, can be: "thCodeList", "thOverview" ...
 * @param kind [String] kind of tab data, optional ("normal", "subsets", "extensions")
 *
 * @return [void]
 */
function ManagedChildrenSelect(dataUrl, tableId, count, target, type, kind) {
	this.dataUrl = dataUrl;
	this.tableId = tableId;
	this.count = count;
	this.target = target;
	this.type = type;
	this.kind = kind;
	this.loading = false;
	this.dataLoaded = false;
	this.autoSelectMode = false;
}

/**
 * Initializes the DataTable, enables multiple selection
 *
 * @return [Object Instance] this instance
 */
ManagedChildrenSelect.prototype.init = function () {
	this.table = $(this.tableId).DataTable({
		"order": [[0, "desc"]],
		"columns": this.columns(),
		"pageLength": pageLength,
		"lengthMenu": pageSettings,
		"processing": true,
		"paging": true,
		"autoWidth": false,
		"select": "multi",
		"language": {
			"infoFiltered": "",
			"emptyTable": "No items were found.",
			"processing": generateSpinnerWText("small")
		},
		"createdRow": function(row, data, dataIndex) {
			// Add color-owner badges to the overview table
			if(this.type == "thOverview")
		 		$(row).addClass(data.owner.toLowerCase() == "cdisc" ? 'row-cdisc' : 'row-sponsor');
	 }.bind(this)
	});

	return this;
}

/**
 * Loads data into table based on offset, executes callback when finished
 * @param offset [Integer] offset of data index
 * @param callback [Function] called on load completed
 *
 * @return [void]
 */
ManagedChildrenSelect.prototype.loadData = function (offset, callback) {
	this.processing(true, "Loading data...");

	$.ajax({
		url: this.dataUrl,
		data: this.loadDataParams(this.count, offset),
		type: 'GET',
		dataType: 'json',
		cache: false,
		context: this,
		success: function (result) {

			$.each(result.data, function(index, item){
				this.table.row.add(item);
			}.bind(this));

			this.redraw();

			if (result.count >= this.count)
				this.loadData(parseInt(result.offset) + this.count, callback)
			else {
				this.processing(false);
				this.dataLoaded = true;
				callback();
			}
		},
		error: function (xhr, status, error) {
			handleAjaxError(xhr, status, error);
			this.processing(false);
		}
	});
}

/**
 * Sets the event handlers: row select, deselect, bulk select, bulk deselect
 *
 * @return [Object Instance] this instance
 */
ManagedChildrenSelect.prototype.setListeners = function () {
	var _this = this;

	// On item (row) select event handler
	this.table.on('select', function (e, dt, type, indexes) { _this.addOrRemoveItems(indexes, "add") });

	// On item (row) deselect event handler
	this.table.on('deselect', function (e, dt, type, indexes) {	_this.addOrRemoveItems(indexes, "remove") });

	// Select all click event handler
	$(this.tableId + "-bulk-select").on("click", function () {
		_this.table.rows({
			search: 'applied',
			selected: false
		}).select()
	});

	// Deselect all click event handler
	$(this.tableId + "-bulk-deselect").on("click", function () {
		new ConfirmationDialog(function () {
			_this.table.rows({
				search: 'applied',
				selected: true
			}).deselect()
		}).show()
	});

	return this;
}

/**
 * Add or remove items. Passes the selected item(s) to the target
 * @param indexes [Array Int] Indexes of rows that were selected/deselected
 * @param action [String] Can be "add" or "remove"
 *
 * @return [void]
 */
ManagedChildrenSelect.prototype.addOrRemoveItems = function (indexes, action) {
	if (!this.autoSelectMode) {

		if (this.target.mcs.loading) {
			this.revertAction(indexes, action);
			return;
		}
		this.processing(true, "Updating selection...");

		var params = { context: this, action: action, autoDeselect: false };
		var items = this.table.rows(indexes).data();
		var callback = this.target.updateSelectionCallback.bind(this.target, items, params);

		this.target.updateSelection(params, items, callback);
	}
}

/**
 * Iterates through target table rows and selects - marks those that are contained in this table
 *
 * @return [void]
 */
ManagedChildrenSelect.prototype.autoSelect = function () {
	this.processing(true, "Loading...");

	// Checks if overview table is loading, retries in 200 ms
	if(this.target.mcs.loading)
		setTimeout(this.autoSelect.bind(this), 200);

	// Overview table done loading
	else {
		var _this = this;
		this.autoSelectMode = true;

		setTimeout(function () {
			var indexes = [];
			this.target.table.rows().every(function (rowIdx, tl, rl) {
				var rowResult = _this.findRowByParam("scopeAndIdentifier", this.data());
				if(rowResult.length != 0)
					indexes.push(rowResult.index());
			});
			this.table.rows(indexes).select();

			this.autoSelectMode = false;
			this.processing(false);
		}.bind(this), 0)
	}
}

/**
 * Auto - Deselects items by argument data based on ids
 * @param data [DataTable Row Data] data from another table to be found and deselected in this one
 *
 * @return [void]
 */
ManagedChildrenSelect.prototype.autoDeselect = function (data) {

	// Checks if overview table is loading, retries in 200 ms
	if(this.target.mcs.loading)
		setTimeout(this.autoDeselect.bind(this, data), 200);

	// Overview table done loading
	else {
		setTimeout(function () {
			var _this = this;
			this.processing(true, "Loading...");
			this.autoSelectMode = true;

			$.each(data, function(i, item){
				this.findRowByParam("scopeAndIdentifier", item).deselect();
			}.bind(this));

			this.autoSelectMode = false;
			this.processing(false);
		}.bind(this), 0)
	}
}

/**
 * Refreshes the table and reloads data
 * @param newUrl [String] newUrl (optional) only if source url changes
 *
 * @return [void]
 */
ManagedChildrenSelect.prototype.refresh = function (newUrl) {
	var _this = this;

	this.dataUrl = newUrl != null ? newUrl : this.dataUrl;
	this.table.rows().remove().draw();
	this.loadData(0, this.autoSelect.bind(this));
}

/**
 * Re-draws the table
 *
 * @return [void]
 */
ManagedChildrenSelect.prototype.redraw = function () {
	this.table.columns.adjust();
	this.table.draw();
}

/**
 * Toggles the processing state of the table on/off
 * @param enable [Boolean] true if should start processing, false if should stop processing
 * @param text [String] Message displayed white processing
 *
 * @return [void]
 */
ManagedChildrenSelect.prototype.processing = function (enable, text) {
	this.loading = enable;

	if(enable && text != null)
		$(this.tableId+"_processing").html(generateSpinnerWText("small", text));

	this.table.processing(enable);
	toggleTableActive(this.tableId, !enable);

	enable ? $("#select-cdisc-ver-button").addClass("disabled") : $("#select-cdisc-ver-button").removeClass("disabled");

	if($("#cdisc-version-label").text() != "None")
		enable ? $("#release-select-tabs .tab-option").addClass("disabled") : $("#release-select-tabs .tab-option").removeClass("disabled")
}

/**
 * Generates parameters for request for fetching data
 * @param c [Int] Data Count
 * @param o [Int] Data Offset
 *
 * @return [Object] formatted data object
 */
ManagedChildrenSelect.prototype.loadDataParams = function(c, o){
	var data = {};

	var param = this.dataUrl.indexOf("managed_concept") != -1 ? "managed_concept" : "thesauri";
	data[param] = { count: c, offset: o }

	if(this.kind != null)
		data[param].type = this.kind;

	return data;
}

/**
 * Finds a row in a DataTable based on data and type
 * @param dataType [String] DataType by which to search, e.g. id, scopeAndIdentifier
 * @param data [Object] Data object which to compare
 *
 * @return [DatatTable Row] DataTable Row result api instance (can be empty)
 */
ManagedChildrenSelect.prototype.findRowByParam = function (dataType, data) {
	if(dataType == "scopeAndIdentifier")
		return this.table.row(function (idx, dt, node) {	return (dt.scope_id == data.scope_id && dt.scoped_identifier == data.scoped_identifier) ? true : false;  });
	else
		return this.table.row(function (idx, dt, node) {	return dt[dataType] == data[dataType] ? true : false;  });
}

/**
 * Finds rows in a DataTable based on a single data parameter
 * @param dataType [String] DataType by which to search, e.g. id, rows_filter
 * @param data [Object] Single data object
 *
 * @return [DataTable Rows] DataTable Row result api instance of 1 or more rows (can be empty)
 */
ManagedChildrenSelect.prototype.findRowsByParam = function (dataType, data) {
	var _this = this;
	if(dataType == "rows_filter")
		return _this.table.rows(data);
	else
		return _this.table.rows(function (idx, dt, node) {return dt[dataType] == data[dataType] ? true : false;})
}

/**
 * Finds rows in a DataTable based on multiple data objects and type
 * @param dataType [String] DataType by which to search, e.g. id, scopeAndIdentifier
 * @param data [Object Array] Multiple Data objects which to find based on dataType
 *
 * @return [DataTable Rows] DataTable Row result api instance of 1 or more rows (can be empty)
 */
ManagedChildrenSelect.prototype.findRowsByData = function (dataType, data) {
	var _this = this;
	var indexes = [];

	$.each(data, function (i, e) {
		var rowIndexes;
		if(dataType == "scopeAndIdentifier")
			rowIndexes = _this.table.rows(function (idx, dt, node) { return (dt.scope_id == e.scope_id && dt.scoped_identifier == e.scoped_identifier) ? true : false; }).indexes().toArray();
		else
			rowIndexes = _this.table.rows(function (idx, dt, node) { return dt[dataType] == e[dataType] ? true : false; }).indexes().toArray();

		indexes = indexes.concat(rowIndexes);
	});

	return _this.table.rows(indexes);
}

/**
 * Reverts action UI on error
 * @param indexes [Array] Indexes of rows that are affected
 * @param action [String] select / deselect
 *
 * @return [String] Styled button HTML
 */
ManagedChildrenSelect.prototype.revertAction = function (indexes, action) {
	this.autoSelectMode = true;
	if(action == "add")
		this.table.rows(indexes).deselect();
	else
		this.table.rows(indexes).select();

	this.autoSelectMode = false;
}

/**
 * Generates exclude button HTML
 * @param data [Object] Data object which contains the id property
 *
 * @return [String] Styled button HTML
 */
ManagedChildrenSelect.prototype.excludeBtnHTML = function (data) {
	return "<span class='icon-times text-accent-2 clickable text-tiny exclude ttip' data-id='"+data.id+"'>"+
            "<span class='ttip-text ttip-table left shadow-small text-small text-medium'>"+
              "Exclude item"+
            "</span>"+
          "</span>";
}

/**
 * Generates HTML for version display and update button
 * @param data [Object] Contains the owner, scope_id and scoped_identifier propertie
 *
 * @return [String] Styled version column HTML
 */
ManagedChildrenSelect.prototype.versionHTML = function (data) {
	if (data.owner != null && data.owner.toLowerCase() == "cdisc")
		return data.semantic_version;

	var html = data.semantic_version;
	html += "<span class='icon-edit text-link clickable pick-version text-tiny ttip' data-scope='"+data.scope_id+"' data-identifier='"+data.scoped_identifier+"' style='margin-left: 10px;'>"+
							"<span class='ttip-text ttip-table left shadow-small text-small text-medium'>"+
								"Change version"+
							"</span>"+
					"</span> ";
	return html;
}

/**
 * Generates column layout for different types of items
 * "thCodeList":  Code lists
 * "thOverview": Code lists selection overview
 * add more if needed
 *
 * @return [Array] of column-data objects for the DataTable
 */
ManagedChildrenSelect.prototype.columns = function () {
  var _this = this;
	var columns;

	switch (this.type) {
  	case "thCodeList":
  		columns = [
        {"data": "identifier"},
  			{"data": "notation"},
  			{"data": "preferred_term"},
  			{"data": "synonym"},
  			{"data": "definition"},
  			{"data": "tags",
  				"render": function (data, type, row, meta) {
  					return type == "display" ? colorCodeTagsBadge(data) : data;
				}},
  			{"data": "indicators", "width": "80px",
					"render": function (data, type, row, meta) {
  					return type == "display" ? formatIndicators(data) : formatIndicatorsString(data);
				}}
  		];
  		break;

  	case "thOverview":
  		columns = [
        {"data": "identifier"},
        {"data": "notation"},
        {"data": "preferred_term"},
        {"data": "synonym"},
  			{"data": "tags",
  				"render": function (data, type, row, meta) {
  					return colorCodeTagsBadge(data);
				}},
  			{"data": "semantic_version", "render": function (data, type, row, meta) {
					return type == "display" ? _this.versionHTML(row) : data;
				}},
				{"data": "state"},
				{"data": "indicators", "width": "80px",
					"render": function (data, type, row, meta) {
						return type == "display" ? formatIndicators(data) : formatIndicatorsString(data);
					}},
  			{"render": function (data, type, row, meta) {
					return type == "display" ? _this.excludeBtnHTML(row) : "";
				}}
  		];
  		break;
	}
	return columns;
}
