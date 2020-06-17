/*
* History Panel *** DEPRECATED ***
*
* Requires:
* history [Table] the managed item table
*/

/**
 * History Panel Panel Constructor
 *
 * @return [void]
 */
function HistoryPanel(url, strict_params, identifier, scope_id, count, itemSelector) {
  var _this = this;

  var counter = 0;

  var loading_html = generateSpinner("medium");

  this.url = url;
  this.strict_params = strict_params;
  this.identifier = identifier;
  this.scope_id = scope_id;
  this.count = count;
  this.itemSelector = itemSelector;
	this.historyTable = $('#history').DataTable( {
    "order": [[ 0, "desc" ]],
    "columns": [
      {"render" : function (data, type, row, meta) {
        if (type == 'display')
          return row.has_identifier.semantic_version;
        else
          return row.has_identifier.version;
        }
      },
      {"render" : function (data, type, row, meta) {
        var date = new Date(row.last_change_date);
        if (type == 'display') {
          return dateTimeHTML(date);
        } else {
          return date.getTime();
        }}
      },
      {"data" : "has_identifier.has_scope.short_name"},
      {"data" : "has_identifier.identifier"},
      {"data" : "label"},
      {"data" : "has_identifier.version_label"},
      {"data" : "has_state.registration_status", "render": function (data, type, row, meta){
        if (type == "display")
          return _this.registrationStatesHTML(row);
        else return data;
      }},
      {"data" : "indicators", "render": function (data, type, row, meta) {
        if (type == "display") return formatIndicators(data);
        else return formatIndicatorsString(data);
      }},
      {className: "text-right", "render" : function (data, type, row, meta) {
        return _this.contextMenuHTML(row, counter++);
        }
      },
    ],
    "pageLength": pageLength, // Gloabl setting
    "lengthMenu": pageSettings, // Gloabl setting
    "processing": true,
    "autoWidth": false,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No changes.",
      "processing": loading_html
    },
    "drawCallback": function(){
      // Context menu on the left if not enough space to be on the right
      if($('#history').offset().left + $('#history').outerWidth() + $('#history').find(".context-menu").outerWidth() > $(document).width()-100){
        $('#history').find(".context-menu").addClass("left");
      }
    },
  });
  this.add(0);
}


/**
 * Add item to table
 *
 * @param [String] uri the uri of the item being added
 * @param [Integer] key a unique reference
 * @return [void]
 */
HistoryPanel.prototype.add = function (offset) {
  var _this = this;
  if (offset === 0) {
    _this.historyTable.processing(true);
  }
  var data = {}
  data[_this.strict_params] = {"identifier": _this.identifier, "scope_id": _this.scope_id, "count": _this.count, "offset": offset}
  $.ajax({
    url: _this.url,
    data: data,
    type: 'GET',
    dataType: 'json',
    cache: false,
    success: function(result) {
    	for (i=0; i<result.data.length; i++) {
        var row = _this.historyTable.row.add(result.data[i]);
      }
      _this.historyTable.draw();
      _this.setListeners();

      if (result.count >= _this.count) {
        _this.historyTable.processing(false);
       _this.add(result.offset + _this.count)
      } else
        _this.historyTable.processing(false);
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      _this.historyTable.processing(false);
    }
  });
}

/**
 * Generates HTML for registration state
 * @param [Object] row item data
 *
 * @return [String] HTML of the item to be displayed in the table
 */
HistoryPanel.prototype.registrationStatesHTML = function (data) {
  var state = data.has_state.registration_status.toLowerCase();
  if ((state == "not_set" || state == "recorded" || state == "qualified") && data.edit_path != "") {
    if (data.has_state.multiple_edit)
      return "<span class='clickable registration-state ttip'><span class='ttip-text ttip-left text-small shadow-small'>Disable multiple edits</span><span class='icon-lock-open text-secondary-clr text-small'></span> "+ data.has_state.registration_status +"</span>";
    else
      return "<span class='clickable registration-state ttip'><span class='ttip-text ttip-left text-small shadow-small'>Enable multiple edits</span><span class='icon-lock text-accent-2 text-small'></span> "+ data.has_state.registration_status +"</span>";
  }
  else return data.has_state.registration_status;
}

/**
 * Generates HTML for context menu
 * @param [Object] row item data
 *
 * @return [String] HTML of the item to be displayed in the table
 */
HistoryPanel.prototype.contextMenuHTML = function (row, c) {
  var id = "con-menu-" + c;
  var menu_items =
  [ { link_path: row.show_path, disabled: row.show_path == "" ? "true":"false", icon: "icon-view", text: "Show"},
    { link_path: row.search_path, disabled: row.search_path == "" ? "true":"false", icon: "icon-search", text: "Search"},
    { link_path: row.edit_path, disabled: row.edit_path == "" ? "true":"false", icon: "icon-edit", text: "Edit"},
    { link_path: row.status_path, disabled: row.status_path == "" ? "true":"false", icon: "icon-document", text: "Document control"},
    { link_path: "#", disabled: row.delete_path == "" ? "true":"false", icon: "icon-trash", text: "Delete"}];

  if(row.impact_path != null && row.impact_path != "")
    menu_items.splice(menu_items.length - 1, 0, { link_path: "#", disabled: "false", icon: "icon-impact", text: "Impact Analysis"});
  if(row.list_cn_path != null && row.list_cn_path != "")
    menu_items.splice(menu_items.length - 1, 0, { link_path: row.list_cn_path, disabled: "false", icon: "icon-note", text: "List Change notes"});
  if(row.current_path != null && row.current_path != "")
    menu_items.splice(menu_items.length - 2, 0, { link_path: row.current_path, disabled: row.indicators.current ? "true":"false", icon: "icon-current", text: "Make current"});
  if(row.clone_path != null && row.clone_path != "")
    menu_items.splice(menu_items.length - 2, 0, { link_path: "#newTerminologyModal", disabled: "false", icon: "icon-copy", text: "Clone", dt_toggle: "modal"});
  if(row.compare_path != null && row.compare_path != "")
    menu_items.splice(menu_items.length - 2, 0, { link_path: "#im-version-picker-modal", disabled: "false", icon: "icon-compare", text: "Compare", dt_toggle: "modal"});
  return generateContextMenu(id, menu_items);
}

/**
 * Sets event listeners for table items - multi-edit lock update, remove item
 *
 * @return [void]
 */
HistoryPanel.prototype.setListeners = function () {
  var _this = this;

  $("#history tbody").off("click", ".registration-state").on("click", ".registration-state", function() {
    var data = _this.historyTable.row($(this).parents("tr:first")).data();
    _this.updateRegistrationState(data);
  });

  $("#history tbody").off("click", ".context-menu a:contains('Delete')").on("click", ".context-menu a:contains('Delete')", function() {
    var data = _this.historyTable.row($(this).parents("tr:first")).data();
    _this.removeItem(data);
  });

  $("#history tbody").off("click", ".context-menu a:contains('Impact Analysis')").on("click", ".context-menu a:contains('Impact Analysis')", function() {
    var data = _this.historyTable.row($(this).parents("tr:first")).data();
    var callback = function(date, id){ location.href = data.impact_path.replace("thId", id); }
    new CdiscVersionSelect(callback, "impact").open();
  });

  $("#history tbody").off("click", ".context-menu a:contains('Clone')").on("click", ".context-menu a:contains('Clone')", function() {
    var item = _this.historyTable.row($(this).parents("tr:first")).data();
    $("#newTerminologyModal form#new_thesaurus").attr("action", item.clone_path);
  });

  $("#history tbody").off("click", ".context-menu a:contains('Compare')").on("click", ".context-menu a:contains('Compare')", function() {
    var item = _this.historyTable.row($(this).parents("tr:first")).data();
    _this.itemSelector.callback = function(selected){
      location.href = item.compare_path + '?' + $.param({thesauri: {thesaurus_id: selected[0]}});
    };
    $(_this.itemSelector.modalId).modal("show");
  });
}

/**
 * Ajax call to update the multiple edit lock
 * @param [Object] row item data
 *
 * @return [void]
 */
HistoryPanel.prototype.updateRegistrationState = function (data) {
  var _this = this;
  url_rs_path = url_rs_path.replace("rs_id", data.id);
  var current_status = data.has_state.multiple_edit;

  var requestData = { "iso_registration_state": { "multiple_edit": !current_status} };
  $.ajax({
    url: url_rs_path,
    type: 'PUT',
    dataType: 'json',
    data: JSON.stringify( requestData ),
    contentType: 'application/json',
    error: function (xhr, status, error) {
      var html = alertError("An error has occurred updating multiple edit flag.");
      displayAlerts(html);
    },
    success: function(result){
      location.reload();
    }
  });
}

/**
 * Opens a confirmation dialog, makes ajax call to remove item when user confirms
 * @param [Object] row item data
 *
 * @return [void]
 */
HistoryPanel.prototype.removeItem = function (data) {
  new ConfirmationDialog(function(){
    var _this = this;
    $.ajax({
      url: data.delete_path,
      type: "DELETE",
      success: function(result){
        location.reload();
      },
      error: function (xhr, status, error) {
        var html = alertError("An error has occurred deleting the item.");
        displayAlerts(html);
      },
    })
  }, {dangerous: true}).show();
}
