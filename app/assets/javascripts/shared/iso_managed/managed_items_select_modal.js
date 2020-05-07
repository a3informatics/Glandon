/*
 * Managed Item Icon Table
 *
 * Requires:
 * managed-items-select-modal [Partial]
 */

/**
 * Managed Item Icon Table Constructor
 *
 * @return [void]
 */
function ManagedItemsSelect(callback) {
  this.modalId = "#im-select-modal";
  this.type = miType;
  this.urls = {
    thesauri: { historyUrl: miHistoryThesauriUrl, indexUrl: miIndexThesauriUrl },
    code_lists: { historyUrl: miHistoryClUrl, indexUrl: miIndexClUrl }
  }
  this.selectMultiple = selectMultiple;
  this.indexTable = this.initIndex();
  this.historyTable = this.initHistory();
  this.initialized = false;
  this.cache = {};
  this.selection = [];
  this.callback = callback;

  // Load data when modal shown
  $(this.modalId).off('shown.bs.modal').on('shown.bs.modal', function (e) {
    if(!this.initialized)
      this.loadData(this.urls[this.type].indexUrl, this.indexTable, 0);
  }.bind(this));

  this.setListeners();
}

/**
 * Shows modal
 *
 * @return [void]
 */
ManagedItemsSelect.prototype.show = function () {
  $(this.modalId).modal("show");
}

/**
 * Updates Description Text
 *
 * @param newDescription [String] new description value
 * @return [void]
 */
ManagedItemsSelect.prototype.setDescription = function (newDescription) {
  $(this.modalId + " #im-select-modal-description").text(newDescription);
}

/**
 * Sets listeners
 *
 * @return [void]
 */
ManagedItemsSelect.prototype.setListeners = function () {
  var _this = this;

  // Index table on select
  this.indexTable.on('select', function (e, dt, type, indexes) {
    var item = this.indexTable.row(indexes[0]).data();
    this.loadHistory(item);
  }.bind(this));

  // Index table on deselect
  this.indexTable.on('deselect', function (e, dt, type, indexes) {
    this.clear(this.historyTable);
  }.bind(this));

  // History table on select
  this.historyTable.on('select', function (e, dt, type, indexes) {
    this.handleSelect(this.historyTable.row(indexes[0]).data(), true);
  }.bind(this));

  // History table on deselect
  this.historyTable.on('deselect', function (e, dt, type, indexes) {
    this.handleSelect(this.historyTable.row(indexes[0]).data(), false);
  }.bind(this));

  // Clear button click
  $(this.modalId + ' #clear-selection').on('click', function() {
    this.selection = [];
    this.historyTable.rows({selected: true}).deselect();
    this.updateSelectionCount();
  }.bind(this));

  // Check / uncheck Select current / Select latest
  $(this.modalId + ' .checkbox-opt input').on('change', function(){
    if(this.checked) {
      $(_this.modalId + ' .checkbox-opt input').not(this).prop('checked', false);
      $(_this.modalId + ' #clear-selection').click();
      toggleTableActive('#index', false);
      toggleTableActive('#history', false);
      $(_this.modalId + " #submit-im-select-button").removeClass("disabled");
    }
    else {
      toggleTableActive('#index', true);
      toggleTableActive('#history', true);
      $(_this.modalId + ' #submit-im-select-button').addClass('disabled');
    }
  });

  // Submit click and hide self
  $(this.modalId + ' #submit-im-select-button').on('click', function(){
    var value;
    if ($('#select-all-current').prop('checked') == true)
      value = "current";
    else if ($('#select-all-latest').prop('checked') == true)
      value = "latest";
    else
      value = this.selection;

    $(this.modalId).modal("hide");
    this.callback(value);

  }.bind(this));

}

/**
 * When item version is selected / deselected. Handles action and updates UI
 *
 * @param item [Object] item selected in the history table - must have id
 * @param selected [Boolean] item selected / deselected ~ true / false
 * @return [void]
 */
ManagedItemsSelect.prototype.handleSelect = function (item, selected) {
  if (this.selectMultiple == true) {
    var index = this.selection.indexOf(item.id);

    if (selected && index == -1)
      this.selection.push(item.id);
    else if(!selected)
      this.selection.splice(index, 1);

    this.updateSelectionCount();
  }
  else {
    this.selection = (selected == true ? [item.id] : []);
    var name = this.indexTable.row({selected: true}).data().identifier + " v" + item.has_identifier.semantic_version;
    this.updateSelectionCount(name);
  }
}

/**
 * Displays data in history page - loads from server or cache
 *
 * @param item [Object] item selected in the index table - must contain fields
    identifier and scope_id
 * @return [void]
 */
ManagedItemsSelect.prototype.loadHistory = function (item) {
  var key = item.identifier + item.scope_id;

  if (this.cache[key] != null) {
    this.clear(this.historyTable);

    $.each(this.cache[key], function(index, d) {
      this.historyTable.row.add(d);
    }.bind(this));

    this.updateUI();
  }
  else
    this.loadData(this.makeHistoryUrl(item.identifier, item.scope_id), this.historyTable, 0);
}

/**
 * Loads data into tables
 *
 * @return [void]
 */
ManagedItemsSelect.prototype.loadData = function (url, target, offset) {
  var count = this.getItemCount(target);

  if(url == null)
    throw new Exception("Type must be specific!");

  if(offset == 0) {
    this.clear(target);
    this.processing(true);
  }

	$.ajax({
		url: url,
		type: 'GET',
		dataType: 'json',
    data: this.loadDataParams(count, offset),
		context: this,
		success: function (result) {
			$.each(result.data, function(index, item) {
				target.row.add(item);
			});
      target.draw();

			if (result.count != null && result.count >= count) {
        this.processing(false);
        toggleTableActive("#index", false);
				this.loadData(url, target, parseInt(result.offset) + count)
      }
			else
        this.dataLoaded(target);
		},
		error: function (xhr, status, error) {
      handleAjaxError(xhr, status, error, $("#im-select-modal-error"));
			this.processing(false);
		}
	});
}

/**
 * Initializes index table
 *
 * @return [void]
 */
ManagedItemsSelect.prototype.initIndex = function () {
  return $(this.modalId + " #index").DataTable({
    "order": [[0, "desc"]],
		"columns": this.columns("index"),
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
 * Initializes index table
 *
 * @return [void]
 */
ManagedItemsSelect.prototype.initHistory = function () {
  return $(this.modalId + " #history").DataTable({
    "order": [[0, "desc"]],
		"columns": this.columns("history"),
		"pageLength": 10,
    "lengthChange": false,
		"processing": true,
    "scrollY": 400,
    "scrollCollapse": true,
    "select": (this.selectMultiple == true ? "multi" : "single"),
		"paging": true,
    "autoWidth": false,
		"language": {
			"infoFiltered": "",
			"emptyTable": "No items were found.",
			"processing": generateSpinner("small")
		}
  });
}

/**
 * Saves currently loaded data to cache
 *
 * @return [void]
 */
ManagedItemsSelect.prototype.cacheThis = function (target) {
  if(target == this.historyTable) {
    var item = this.indexTable.rows({selected: true}).data()[0]
    var key = item.identifier + item.scope_id;
    if (this.cache[key] == null)
      this.cache[key] = this.historyTable.rows().data();
  }
}

/**
 * Updates selection count
 *
 * @return [void]
 */
ManagedItemsSelect.prototype.updateSelectionCount = function (name) {
  if(name == null)
    $(this.modalId + " #number-selected").text(this.selection.length);
  else
    $(this.modalId + " #number-selected").text(name);

  if(this.selection.length == 0)
    $(this.modalId + " #submit-im-select-button").addClass("disabled");
  else
    $(this.modalId + " #submit-im-select-button").removeClass("disabled");
}

/**
 * Clears both tables' data
 *
 * @return [void]
 */
ManagedItemsSelect.prototype.clear = function (target) {
  target.rows().remove().draw();
}

/**
 * Called when data loaded
 *
 * @return [void]
 */
ManagedItemsSelect.prototype.dataLoaded = function (target) {
  this.processing(false);
  this.initialized = true;
  this.cacheThis(target);
  this.updateUI();
}

/**
 * Updates UI
 *
 * @return [void]
 */
ManagedItemsSelect.prototype.updateUI = function () {

  $.each(this.selection, function(i, e){
    var item = this.findRowByParam(this.historyTable, "id", e);
    try {
      item.select();
    }catch(e){}
  }.bind(this));

  this.indexTable.draw();
  this.indexTable.columns.adjust();
  this.historyTable.draw();
  this.historyTable.columns.adjust();
}

/**
 * Generates history url
 *
 * @param identifier [String] Item identifier
 * @param scopeId [String] Scope Id
 * @return [String] history url
 */
ManagedItemsSelect.prototype.makeHistoryUrl = function (identifier, scopeId) {
  return this.urls[this.type].historyUrl.replace("miHistoryId", identifier).replace("miScopeId", scopeId);
}

/**
 * Enables or disables processing within the modal tables
 *
 * @param enable [Boolean] Processing enable / disable == true / false
 * @return [void]
 */
ManagedItemsSelect.prototype.processing = function (enable) {
  this.indexTable.processing(enable);
  this.historyTable.processing(enable);
  toggleTableActive("#index", !enable);
  toggleTableActive("#history", !enable);
}

/**
 * Generates parameters for request for fetching data
 *
 * @return [Int] Item count for specific type
 */
ManagedItemsSelect.prototype.getItemCount = function(target){
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
ManagedItemsSelect.prototype.findRowByParam = function (table, dataType, data) {
	return table.row(function (idx, dt, node) {
		return dt[dataType] == data ? true : false;
	});
}

/**
 * Generates parameters for request for fetching data
 *
 * @param [Int] Data Count
 * @param [Int] Data Offset
 * @return [Object] formatted data object
 */
ManagedItemsSelect.prototype.loadDataParams = function(c, o){
	var data = {};
  var param;

  if (this.type == "code_lists")
	  param = "managed_concept";
  else if (this.type == "thesauri")
    param = "thesauri";

	data[param] = { count: c, offset: o }

  if (this.type == "code_lists")
    data[param].type = "all";

	return data;
}

/**
 * Columns defs
 *
 * @param table [String] Table type
 * @return [Object Array] Column definitions for specific table type
 */
ManagedItemsSelect.prototype.columns = function (table) {
  switch (table) {
    case "index":
      return [
        {"data" : "owner"},
        {"data" : "identifier"},
        {"render" : function (data, type, row, meta) {
            return row.label || row.preferred_term;
        }},
        {"data": "indicators", "orderable": false, "render" : function (data, type, row, meta) {
            return (type == "display" ? formatIndicators(data) : formatIndicatorsString(data));
        }},
      ];
    case "history":
      return [
        {"render" : function (data, type, row, meta) {
          return (type == 'display' ? row.has_identifier.semantic_version : row.has_identifier.version);
        }},
        {"data" : "has_identifier.version_label"},
        {"data" : "has_state.registration_status"},
        {"data" : "indicators", "orderable": false, "render": function (data, type, row, meta) {
          return (type == "display" ? formatIndicators(data) : formatIndicatorsString(data));
        }},
      ];
  }
}
