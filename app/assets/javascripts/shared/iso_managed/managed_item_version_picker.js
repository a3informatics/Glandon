/*
 * Managed Item Version Picker
 *
 * Requires:
 * managed-item-version-picker (modal) [Partial]
 */

/**
 * Managed Item Version Picker Constructor
 *
 * @param type [String] item type ("codelist", "thesaurus")
 * @param callback [Function] called user clicks Submit
 * @return [void]
 */
function ManagedItemVersionPicker(type, callback) {
  this.modalId = "#im-version-picker-modal";
  this.submitId = "#submit-im-version-button";
  this.historyUrl = miVersionPickHistoryUrl;
  this.historyTable = this.init();
  this.count = 20;
  this.type = type;
  this.callback = callback;

  // Load data when modal shown
  $(this.modalId).off('shown.bs.modal').on('shown.bs.modal', function (e) {
    this.loadData(this.makeHistoryUrl(this.item.scoped_identifier, this.item.scope_id), 0);
    $(this.submitId).addClass("disabled");
  }.bind(this));

  this.setListeners();
  return this;
}

/**
 * Shows modal
 *
 * @param item [Object] must contain: scoped_identifier, scope_id
 * @return [void]
 */
ManagedItemVersionPicker.prototype.show = function (item, callback) {
  this.clear();
  this.item = item;
  if(callback != null)
    this.callback = callback;

  $(this.modalId).modal("show");
}

/**
 * Sets listeners
 *
 * @return [void]
 */
ManagedItemVersionPicker.prototype.setListeners = function () {
  var _this = this;

  // History table on select
  this.historyTable.on('select', function (e, dt, type, indexes) {
    $(this.submitId).removeClass("disabled");
  }.bind(this));

  // History table on deselect
  this.historyTable.on('deselect', function (e, dt, type, indexes) {
    $(this.submitId).addClass("disabled");
  }.bind(this));

  // Submit click and hide self
  $(this.modalId + ' ' + this.submitId).on('click', function() {
    var rowSelected = this.historyTable.row({selected: true});
    if (rowSelected.count() == 0) {
      displayAlerts(alertError("You must select a version."));
    }
    else {
      $(this.modalId).modal("hide");
      this.callback(rowSelected.data());
    }
  }.bind(this));

}

/**
 * Loads data into table
 *
 * @param url [String] history data url (with encoded scope_id and identifier)
 * @param offset [Integer] current call data offset
 * @return [void]
 */
ManagedItemVersionPicker.prototype.loadData = function (url, offset) {
  if(offset == 0)
    this.processing(true);

	$.ajax({
		url: url,
		type: 'GET',
		dataType: 'json',
    data: this.loadDataParams(this.count, offset),
		context: this,
		success: function (result) {
			$.each(result.data, function(index, item) {
				this.historyTable.row.add(item);
			}.bind(this));
      this.historyTable.draw();

			if (result.count != null && result.count >= this.count) {
        this.processing(false);
				this.loadData(url, parseInt(result.offset) + this.count)
      }
			else
        this.dataLoaded();
		},
		error: function (xhr, status, error) {
      handleAjaxError(xhr, status, error, $("#im-version-picker-error"));
			this.processing(false);
		}
	});
}

/**
 * Initializes history table
 *
 * @return [void]
 */
ManagedItemVersionPicker.prototype.init = function () {
  return $(this.modalId + " #history").DataTable({
    "order": [[0, "desc"]],
		"columns": this.columns(),
    "pageLength": pageLength,
		"lengthMenu": pageSettings,
		"processing": true,
    "scrollY": 400,
    "scrollCollapse": true,
    "autoWidth": false,
    "select": {
      "info": false,
      "style": "single",
    },
		"paging": true,
		"language": {
			"infoFiltered": "",
			"emptyTable": "No versions were found.",
			"processing": generateSpinner("small")
		}
  });
}

/**
 * Clears table data
 *
 * @return [void]
 */
ManagedItemVersionPicker.prototype.clear = function () {
  this.historyTable.rows().remove().draw();
}

/**
 * Called when data loaded
 *
 * @return [void]
 */
ManagedItemVersionPicker.prototype.dataLoaded = function () {
  this.processing(false);
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
ManagedItemVersionPicker.prototype.makeHistoryUrl = function (identifier, scopeId) {
  return this.historyUrl.replace("miHistoryId", identifier).replace("miScopeId", scopeId);
}

/**
 * Enables or disables processing within the modal table
 *
 * @param enable [Boolean] Processing enable / disable == true / false
 * @return [void]
 */
ManagedItemVersionPicker.prototype.processing = function (enable) {
  this.historyTable.processing(enable);
  toggleTableActive(this.modalId + " #history", !enable);
}

/**
 * Generates parameters for request for fetching data
 *
 * @param [Int] Data Count
 * @param [Int] Data Offset
 * @return [Object] formatted data object
 */
ManagedItemVersionPicker.prototype.loadDataParams = function(c, o){
	var data = {};
  var param;

  if (this.type == "codelist")
	  param = "managed_concept";
  else if (this.type == "thesaurus")
    param = "thesauri";

	data[param] = { count: c, offset: o }

	return data;
}

/**
 * Columns defs
 *
 * @return [Object Array] Column definitions for table
 */
ManagedItemVersionPicker.prototype.columns = function () {
    return [
      {"render" : function (data, type, row, meta) {
        return (type == 'display' ? row.has_identifier.semantic_version : row.has_identifier.version);
      }},
      {"render" : function (data, type, row, meta) {
        var date = new Date(row.last_change_date);
        return type == 'display' ? dateTimeHTML(date) : date.getTime();
      }},
      {"data" : "has_identifier.has_scope.short_name"},
      {"data" : "has_identifier.identifier"},
      {"data" : "label"},
      {"data" : "has_identifier.version_label"},
      {"data" : "has_state.registration_status"},
      {"data" : "indicators", "orderable": false, "render": function (data, type, row, meta) {
        return (type == "display" ? formatIndicators(data) : formatIndicatorsString(data));
      }},
    ];
}
