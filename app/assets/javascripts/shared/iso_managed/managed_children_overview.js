/*
 * Selection Overview Table
 *
 * Requires:
 * 1 or more children tables [Table]
 * 1 overview table [Table] this table
 */

/**
 * Managed Children Selection Overview Table Constructor
 * @param urls [Object] urls of data source and updates
 * @param tableId [String] id of the table
 * @param count [Integer] Number of items fetched in one request
 * @param context [Object Instance] reference to the parent (ReleaseSelect.js) object instance
 *
 * @return [void]
 */
function ManagedChildrenSelectOverview(urls, tableId, count, context) {
	this.mcs = new ManagedChildrenSelect(urls.dataUrl, tableId, count, null, "thOverview").init();
	this.urls = urls;
	this.table = this.mcs.table;
	this.context = context;
	this.versionPicker = new ManagedItemVersionPicker("codelist");

	this.table.select.style('api'); // Disable row selection
	this.mcs.loadData(0, this.setListeners.bind(this) );
}

/**
 * Update the Thesaurus selection, extends edit lock
 * @param  params [Object] has properties:
 		'action' [String] (add/remove),
		'context' [Instance] (calling object reference)
		'autoDeselect' [Boolean] optional
		'thisTable' [Boolean] optional
 * @param data [DataTable Row(s) Data] data source
 * @param callback [Function] callback executed on request success
 *
 * @return [void]
 */
 ManagedChildrenSelectOverview.prototype.updateSelection = function (params, data, callback) {
	this.extendLock();
	this.mcs.processing(true, "Updating selection...");

	setTimeout(function(){ this.executeRequest(this.buildRequestParams(params, data), callback) }.bind(this), 0);
}

/**
 * Posts data to server, runs callbacks
 * @param requestParams [Object] request parameters, must contain:
 		url [String],
		data [Object] formatted for the request,
		request type [String]
		context [Instance] calling instance (optional)
 * @param callback [Function] callback executed on request success
 *
 * @return [void]
 */
ManagedChildrenSelectOverview.prototype.executeRequest = function (requestParams, callback) {
	$.ajax({
		url: requestParams.url,
		data: requestParams.data,
		type: requestParams.type,
		dataType: 'json',
		context: this,
		success: function(result){
			this.mcs.processing(false);
			try { callback() } catch(exc) {};
		},
		error: function (xhr, status, error) {
			handleAjaxError(xhr, status, error);
			this.mcs.processing(false);
			try { requestParams.context.processing(false) } catch(exc) {};
		}
	})
}

/**
 * Builds ajax request parameters
 * @param params [Object] has properties:
 		'action' [String] (add/remove/change_version),
		'context' [Instance] (calling object reference)
		'autoDeselect' [Boolean] optional
		'thisTable' [Boolean] optional
 * @param data [DataTable Row(s) Data] data source
 *
 * @return [Object] formatted ajax request parameters required for the executeRequest function
 */
ManagedChildrenSelectOverview.prototype.buildRequestParams = function (params, data) {
	var requestData = {
		"data": this.encodeRequestData(data, params),
		"context": params.context,
	};

	switch (params.action) {
		case "add":
			requestData["type"] = "POST";
			requestData["url"] = this.urls.selectChildrenURL;
			break;
		case "remove":
			requestData["type"] = "PUT";

			if(data.count() == this.mcs.table.page.info().recordsTotal) {
				requestData["url"] = this.urls.deselectAllChildrenUrl;
				requestData["data"] = "";
			}
			else
				requestData["url"] = this.urls.deselectChildrenUrl;
			break;
		case "change_version":
			requestData["type"] = "PUT";
			requestData["url"] = this.urls.changeChildVersionURL;
			break;
	}

	return requestData;
}

/**
 * Encodes DataTables Row(s) Data API to correct data structure to be sent to the server
 *
 * @param data [DataTable Row(s)] data ids to be sent to the server
 * @param params [Object] Request Parameter - must contain property 'action'
 * @return [Object] formatted data structure (array of item ids)
 */
ManagedChildrenSelectOverview.prototype.encodeRequestData = function (data, params) {
	var idArray = [];

	$.each(data, function(i, item){
		var targetItem = (params.action == "remove" ? this.mcs.findRowByParam("scopeAndIdentifier", item).data() : item);
		idArray.push(targetItem.id);
	}.bind(this));

	return {thesauri: {id_set: idArray}};
}

/**
 * Callback to successful server data selection update - updates the local UI
 * @param data [Rows Data] original data from request
 * @param params [Object] original request params
 *
 * @return [void]
 */
ManagedChildrenSelectOverview.prototype.updateSelectionCallback = function (data, params) {
	switch(params.action){
		case "add":
			// this.addItems(data, params);
			this.refresh(params.context.processing.bind(params.context, false));
			break;
		case "remove":
			this.removeItems(data, params);
			try { params.context.processing(false) } catch(exc) {};
			break;
		case "change_version":
			this.refresh();
		break;
	}
}

/**
 * Adds item(s) to the Thesaurus selection (local UI callback) DEPRECATED
 * @param [Rows Data] original data from request
 * @param [Object] original request params
 *
 * @return [void]
 */
ManagedChildrenSelectOverview.prototype.addItems = function (data, params) {
	// $.each(data, function (i, e) {
	// 	e["sourceInfo"] = {index: params.context.findRowByParam("id", e).index(), tableId: params.context.tableId};
	// });
	//
	// this.table.rows.add(data);
	// this.redraw();
}

/**
 * Removes item(s) to the Thesaurus selection (local UI callback)
 * @param data [Rows Data] original data from request
 * @param params [Object] original request params
 *
 * @return [void]
 */
ManagedChildrenSelectOverview.prototype.removeItems = function (data, params) {
	if (params.thisTable)
		params.rows.remove();
	else
		this.mcs.findRowsByData("scopeAndIdentifier", data).remove();

	if (params.autoDeselect)
		this.context.autoDeselectAllTabs(data);

	this.table.draw();
}

/**
 * Update the version of a Code List in the thesaurus
 *
 * @param data [Object Array] [0]: old version item object, [1] new version item object
 * @return [void]
 */
 ManagedChildrenSelectOverview.prototype.updateVersion = function (data) {
	this.extendLock();
	this.mcs.processing(true, "Updating item version...");

	var params = {action: "change_version", context: this}
	var callback = this.updateSelectionCallback.bind(this, null, params);

	setTimeout(function(){ this.executeRequest(this.buildRequestParams(params, data), callback) }.bind(this), 0);
}

/**
 * Removes (excludes) all items filtered by the table search in bulk, updates UI
 *
 * @return [void]
 */
ManagedChildrenSelectOverview.prototype.bulkRemove = function () {
	setTimeout(function () {
		var rows = this.mcs.findRowsByParam("rows_filter", {search: 'applied'});
		var params = { context: this, action: "remove", autoDeselect: true, thisTable: true, rows: rows };
		var data = rows.data();
		var callback = this.updateSelectionCallback.bind(this, data, params);
		this.updateSelection(params, data, callback);
	}.bind(this), 0);
}

/**
 * Sets the event listeners for: bulk-deselect, exclude buttons, pick version
 *
 * @return [void]
 */
ManagedChildrenSelectOverview.prototype.setListeners = function () {
	var _this = this;

	// Exclude all click event handler
	$(_this.mcs.tableId + "-bulk-deselect").off("click").on("click", function () {
		new ConfirmationDialog(_this.bulkRemove.bind(_this), {dangerous: true}).show();
	});

	// Exclude item button click event handler
	$(_this.mcs.tableId + " tbody").off("click", ".exclude").on("click", ".exclude", function ()  {
		var item = _this.table.rows($(this).parents("tr:first")).data();
		var params = { action: "remove", context: _this, autoDeselect: true };
		var callback = _this.updateSelectionCallback.bind(_this, item, params);

		_this.updateSelection(params, item, callback);
	});

	// Change version icon click event handler
	$(_this.mcs.tableId + " tbody").off("click", ".pick-version").on("click", ".pick-version", function() {
		var item = _this.table.row($(this).parents("tr:first")).data();
		var callback = function (itemSelected) { _this.updateVersion([item, itemSelected]); }

		_this.versionPicker.show(item, callback);
	});
}

/**
 * Clears and re-loads the overview table data
 *
 * @param callback [Function] called when refresh completes, optional
 * @return [void]
 */
ManagedChildrenSelectOverview.prototype.refresh = function (callback) {
	this.mcs.table.rows().remove().draw();

	this.mcs.loadData(0, function() {
		if(callback != null)
			try { callback() }catch(e){ }

		this.setListeners();
	}.bind(this));
}

/**
 * Redraws the table, re-sets the listeners
 *
 * @return [void]
 */
ManagedChildrenSelectOverview.prototype.redraw = function () {
	this.mcs.redraw();
	this.setListeners();
}

/**
 * Extend lock call
 *
 * @return [void]
 */
ManagedChildrenSelectOverview.prototype.extendLock = function () {
 if(!this.context.timer.expired)
	 this.context.timer.extendLock();
}
