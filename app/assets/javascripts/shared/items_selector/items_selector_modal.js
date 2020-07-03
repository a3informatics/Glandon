/*
* Items Selector Modal
* Generic picker for any managed item(s).
*/

/*
* Params
** id [String] id of the modal (must match the id passed to the partial)
** types [Object] {thesauri, cls, clitems, bcs} should specify ones to enable with true/false
** multiple [Boolean] enable/disable multiple item selection
** callback [Function] called when user clicks Submit. User's selection is passed as parameter.
*/

/**
* Items Selector Modal Constructor
*
* @param [Object] user-defined values
* @return [void]
*/
function ItemsSelector(params) {
 this.params = this.paramsDefault(params);
 this.modal = $("#selector-modal-" + this.params.id);
 this.errorDiv = this.modal.find("#selector-modal-error");

 this.setDescription(params.description);
 this.initSelection();
 this.setListeners();
 this.initTabs();
}

/**
 ****** General ******
**/

/**
 * Shows modal
 *
 * @return [void]
 */
ItemsSelector.prototype.show = function(callback) {
  this.modal.modal("show");
}

/**
 * Sets a new description
 *
 * @param text [String] New description string
 * @return [void]
 */
ItemsSelector.prototype.setDescription = function(text) {
  this.modal.find("#im-select-modal-description").text(text);
}

/**
 * Sets a new callback
 *
 * @param callback [Function] New user submission callback
 * @return [void]
 */
ItemsSelector.prototype.setCallback = function(callback) {
  this.params.callback = callback;
}

/**
 * Gets subselection for a tab
 *
 * @param sourceTab [String] name of the tab
 * @return [Array] tab's subselection
 */
ItemsSelector.prototype.getSubselection = function(sourceTab) {
  return this.selection[sourceTab];
}

/**
 * Sets listeners
 *
 * @return [void]
 */
ItemsSelector.prototype.setListeners = function(callback) {
  this.modal.find(".tab-option").on("switch", this.onTabClick.bind(this));

  this.modal.on("shown.bs.modal", this.onModalShow.bind(this));

  this.modal.on("hide.bs.modal", this.onModalClose.bind(this));

  this.modal.find("#clear-selection").on("click", this.clearSelection.bind(this));

  this.modal.find("#view-selection").on("click", this.viewSelection.bind(this));

  this.modal.find("#selector-modal-submit").on("click", this.submit.bind(this));
}

/**
 ****** Events ******
**/

/**
 * Submit selection to callback, reset and hide dialog
 *
 * @return [void]
 */
ItemsSelector.prototype.submit = function() {
  this.params.callback(JSON.parse(JSON.stringify(this.selection)))

  this.reset();
  this.modal.modal("hide");
}

/**
 * Is called by the tabs when their subselection updates. '
 * Manages master selection object
 *
 * @param type [String] name of the tab
 * @param selected [Boolean] true / false - selected / deselected
 * @param data [Object Array] array of data items selected / deselected
 * @return [void]
 */
ItemsSelector.prototype.onPanelSelectionChange = function(type, selected, data) {
  if (this.params.multiple) {
    var subselection = this.selection[type];

    data.each(function(d) {
      var itemInSelection = this.findInSelection(d.id, type);

      if(selected && itemInSelection == null)
        subselection.push(d);
      else if (!selected && itemInSelection != null)
        subselection.splice(itemInSelection.index, 1);

    }.bind(this));
  }
  else {
    if (this.findInSelection(data[0].id, type) != null)
      return;

    $.each(this.tabs, function(name, tab) {
      this.selection[name] = [];
      if (name != type)
        tab.deselectAll();
    }.bind(this))
    this.selection[type] = selected ? [data[0]] : [];
  }

  this.updateUI();
}

/**
 * Tab click event. Shows and refreshes the tab content.
 *
 * @param e [Event] event data
 * @param id [String] clicked tab id
 * @return [void]
 */
ItemsSelector.prototype.onTabClick = function(e, id) {
  id = id.split('-')[1];
  this.tabs[id].show();
  this.tabs[id].refresh();
}

/**
 * Called when modal opened
 *
 * @return [void]
 */
ItemsSelector.prototype.onModalShow = function() {
  this.openDefaultTab();
}

/**
 * Called when modal closed
 *
 * @return [void]
 */
ItemsSelector.prototype.onModalClose = function() {
  this.reset();
}

/**
 * Clears selection, updates UI
 *
 * @return [void]
 */
ItemsSelector.prototype.clearSelection = function() {
  var _this = this;

  $.each(this.selection, function (name, subselection){
    this.splice(0, this.length);
    try { _this.tabs[name].deselectAll(); } catch(e) {};
  });

  this.updateUI();
}

/**
 ****** UI ******
**/

/**
 * Initializes selection type, UI
 *
 * @return [void]
 */
ItemsSelector.prototype.initSelection = function() {
  this.selection = {};

  $.each(this.params.types, function(name, enabled){
      if (enabled)
        this.selection[name] = [];
  }.bind(this));

  if (!this.params.multiple)
    this.modal.find("#view-selection").hide();

  this.updateUI();
}

/**
 * Sets the selection's element text to a new value
 *
 * @return [String] Text that the selection info was set to
 */
ItemsSelector.prototype.updateSelectionInfo = function() {
  var selEl = this.modal.find("#selected-info");
  var selText = this.getSelectionInfo();
  selEl.text(selText);

  return selText;
}

/**
 * Calculates the total selection length / builds selection string
 *
 * @return [Integer/String] new selection info value
 */
ItemsSelector.prototype.getSelectionInfo = function() {
  var result;

  if (this.params.multiple) {
    result = 0;
    $.each(this.selection, function(type, values) {
      result += values.length;
    });
  }
  else {
    result = "None";
    $.each(this.selection, function(type, values) {
      if (values.length > 0)
        result = this.selectionItemString(values[0]);
    }.bind(this));
  }

  return result;
}

/**
 * Makes item-data specific string for the selection overview
 *
 * @param item [Object] item data
 * @return [String]
 */
ItemsSelector.prototype.selectionItemString = function(item) {
  // Unmanaged Items
  if (item.parentData != null)
    return item.notation +
      " (Code List: " + (item.parentData.notation || item.parentData.has_identifier.identifier) +
      " v" + item.parentData.has_identifier.semantic_version + ")";

  // Managed Items
  return (item.notation || item.has_identifier.identifier) + " v" + item.has_identifier.semantic_version;
}

/**
 * Updates UI after user action
 *
 * @return [void]
 */
ItemsSelector.prototype.updateUI = function() {
  var selText = this.updateSelectionInfo();
  this.modal.find("#selector-modal-submit").toggleClass("disabled", (selText == "None" || selText == 0))
}

/**
 * Resets modal, selection and all tabs
 *
 * @return [void]
 */
ItemsSelector.prototype.reset = function() {
  this.clearSelection();
  this.updateUI();

  $.each(this.tabs, function(type, tab) {
    tab.reset();
  });
}

/**
 * Shows selection in an InformationDialog. Sets handlers.
 *
 * @return [void]
 */
ItemsSelector.prototype.viewSelection = function() {
  var selectionText = this.viewSelectionHTML();
  var infDialog = new InformationDialog({title: "Current selection", subtitle: selectionText, wide: true}).show();

  $(infDialog.id).on("click", ".removable", this.removeFromSelection.bind(this, infDialog));
}


/**
 * Removes a single item from the selection, updates tab UI
 *
 * @param dialog [InformationDialog] reference to the dialog
 * @param e [Event] original click event
 * @return [void]
 */
ItemsSelector.prototype.removeFromSelection = function(dialog, e) {
  var target = this.findInSelection($(e.target).attr("data-id"));

  if (target != null){
    this.selection[target.type].splice([target.index], 1);
    this.updateUI();
    this.getOpenTab().refresh();
    dialog.setText(this.viewSelectionHTML());
  }
}

/**
 ****** Tabs ******
**/

/**
 * Initializes UI based on params. Removes unused tab elements.
 *
 * @return [void]
 */
ItemsSelector.prototype.initTabs = function(userParams) {
  this.tabs = {};

  $.each(this.params.types, function(tab, enabled){
    if (enabled)
      this.initializeTab(tab);
    else
      this.disableTab(tab);
  }.bind(this));
}

/**
 * Simulates click on the first enabled tab, opening it
 *
 * @return [void]
 */
ItemsSelector.prototype.openDefaultTab = function() {
  var defaultTab = Object.keys(this.params.types)[0];
  defaultTab = this.getTab(defaultTab);

  setTimeout(function() {defaultTab.click(); }, 100);
}

/**
 * Disables a tab, removes content
 *
 * @param tabName [String] Name of the tab
 * @return [void]
 */
ItemsSelector.prototype.disableTab = function(tabName) {
  this.getTab(tabName).remove();
  this.modal.find("#selector-" + tabName).remove();
  delete this.params.types[tabName];
}

/**
 * Gets tab element (tab-header)
 *
 * @param tabName [String] Name of the tab
 * @return [JQuery Element] tab element
 */
ItemsSelector.prototype.getTab = function(tabName) {
  return this.modal.find("#tab-" + tabName);
}

/**
 * Gets currently open tab instance
 *
 * @return [Instance Reference] open tab
 */
ItemsSelector.prototype.getOpenTab = function() {
  var tabName = this.modal.find(".tab-option.active").attr("id").split('-')[1];
  return this.tabs[tabName];
}


/**
 ****** Support ******
**/

/**
 * Finds object's index and type in the selection by ID property
 *
 * @param id [String] id to match by
 * @param subselection [String] subselection name (optional)
 * @return [Object] {type, index} matched object, null if not found
 */
ItemsSelector.prototype.findInSelection = function(id, subselection) {
  var result = null;

  if (subselection != null) {
    $.each(this.selection[subselection], function(index, data) {
        if (data.id == id) {
          result = {type: subselection, index: index};
          return false;
        }
    });
  }
  else {
    $.each(this.selection, function(name, values) {
      $.each(values, function(index) {
        if (this.id == id) {
          result = {type: name, index: index};
          return false;
        }
      });

      return result == null;
    });
  }

  return result;
}

/**
 * Builds HTML for view selection
 *
 * @return [String] formatted HTML text
 */
ItemsSelector.prototype.viewSelectionHTML = function() {
  var _this = this;
  var selInfo = this.getSelectionInfo();

  if (selInfo == 0 || selInfo == "None")
    return "Selection is empty";

  var html = "<i>Click on an item to remove it from the selection.</i><br/>";

  $.each(this.selection, function(name, values) {
    html += "<span class='label-styled label-w-margin'>" + _this.getTab(name).text() + " </span><br/>";

    if(values.length == 0)
      html += "<i class='label-w-margin'>None</i>";
    else
      $.each(values, function() {
        html += "<span class='bg-label label-w-margin removable' data-id='" + this.id + "'>" + _this.selectionItemString(this) + "</span>";
      });

    html += "<br/>";
  });
  return html;
}

/**
 * Columns defs
 *
 * @param table [String] Table type
 * @param type [String] Tab type name
 * @return [Object Array] Column definitions for specific table type
 */
ItemsSelector.prototype.columns = function (table, type) {
  var columns;

  switch(table) {
    case "index":
      columns = [
        {"data" : "owner"},
        {"data" : "identifier"},
        {"render" : function (data, type, row, meta) {
            return row.label || row.preferred_term;
        }},
        {"data": "indicators", "orderable": false, "render" : function (data, type, row, meta) {
            return (type == "display" ? formatIndicators(data) : formatIndicatorsString(data));
        }},
      ];
      break;
    case "history":
      columns = [
        {"render" : function (data, type, row, meta) {
          return (type == 'display' ? row.has_identifier.semantic_version : row.has_identifier.version);
        }},
        {"data" : "has_identifier.version_label"},
        {"data" : "has_state.registration_status"},
        {"data" : "indicators", "orderable": false, "render": function (data, type, row, meta) {
          return (type == "display" ? formatIndicators(data) : formatIndicatorsString(data));
        }},
      ];
      break;
    case "children":
      columns = [
        {"data" : "identifier"},
        {"data" : "notation"},
        {"data" : "preferred_term"}
      ];
      break;
  }

  switch(type) {
    case "bcs":
      // Remove Indicators column for BCs
      columns[3] = {visible: false, "render" : function (data, type, row, meta) {return "" }}
      break;
    case "clitems":
    case "cls":
      // Add Submission Value column to index tables for CLs and CLItems
      if(table == "index"){
        this.modal.find(".tab-wrap[data-tab='tab-"+type+"']").find("#index thead th:eq(2)").after("<th>Submission Value</th>");
        columns.splice(3, 0, {"data": "notation"});
      }
      break;

  }

  return columns;
}

/**
 * Initializes a tab selector instance
 *
 * @param tabName [String] Name of the tab
 * @return [void]
 */
ItemsSelector.prototype.initializeTab = function(tabName) {
  switch (tabName) {
    case "thesauri":
      this.tabs[tabName] = new MISelector(
        {
          type: tabName,
          multiple: this.params.multiple,
          columns: this.columns.bind(this),
          parentPanel: this,
          errorDiv: this.errorDiv,
          urls: {history: miHistoryThesauriUrl, index: miIndexThesauriUrl},
        });
      break;
    case "cls":
      this.tabs[tabName] = new MISelector(
        {
          type: tabName,
          multiple: this.params.multiple,
          columns: this.columns.bind(this),
          parentPanel: this,
          errorDiv: this.errorDiv,
          urls: {history: miHistoryClUrl, index: miIndexClUrl},
        });
      break;
    case "clitems":
      this.tabs[tabName] = new UMISelector(
        {
          type: tabName,
          multiple: this.params.multiple,
          columns: this.columns.bind(this),
          parentPanel: this,
          errorDiv: this.errorDiv,
          urls: {history: miHistoryClUrl, index: miIndexClUrl, children: miChildrenClUrl},
        });
      break;
    case "bcs":
      this.tabs[tabName] = new MISelector(
        {
          type: tabName,
          multiple: this.params.multiple,
          columns: this.columns.bind(this),
          parentPanel: this,
          errorDiv: this.errorDiv,
          urls: {history: miHistoryBcUrl, index: miIndexBcUrl},
        });
      break;
  }
}

/**
 * Merges user parameters with default values in missing fields
 *
 * @param userParams [Object] user-defined values
 * @return [Object] parameters with default values in missing fields
 */
ItemsSelector.prototype.paramsDefault = function(userParams) {
  userParams.types = _.defaults(userParams.types,
    {
      thesauri: false,
      cls: false,
      clitems: false,
      bcs: false
    });

  return _.defaults(userParams,
    {
      id: "",
      multiple: false,
      callback: null,
      description: "To proceed, select one or more items.",
    });
}
