import TablePanel from 'shared/base/table_panel'

import rsHelper from 'shared/custom/iso_registration_state/rs_history'
import { render as renderMenu } from 'shared/ui/context_menu'
import { $delete } from 'shared/helpers/ajax'
import { $confirm } from 'shared/helpers/confirmable'
import { dtDateTimeColumn, dtIndicatorsColumn, dtContextMenuColumn, dtVersionColumn } from 'shared/helpers/dt/dt_columns'

/**
 * History Panel
 * @description Lists versions + interaction options of a single IsoManaged item.
 * @extends TablePanel class from shared/base/table_panel
 * @requires table [@id = 'history']
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class HistoryPanel extends TablePanel {

  /**
   * Create a History Panel
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table (Optional)
   * @param {string} params.url Url of source data
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {int} params.count Count of items fetched in one request [default = 100]
   * @param {boolean} params.deferLoading Set to true if data load should be deferred. Load data has to be called manually in this case. Optional.
   * @param {boolean} params.cache Specify if the panel data should be cached. Optional.
   */
  constructor({
    selector = "#history-panel #history",
    url,
    param,
    count = 100,
    deferLoading = false,
    cache = true
  }) {
    super({ selector, url, param, count, deferLoading, cache });
    this._initItemSelector()
  }

  /** Private **/

  /**
   * Sets event listeners, handlers
   */
  _setListeners() {

    // Update RS
    this._clickListener({
      target: ".registration-state",
      handler: (e) => rsHelper.updateRS(this._getRowDataFrom$(e.target))
    });

    // Delete
    this._clickListener({
      target: ".context-menu a:contains('Delete')",
      handler: (e) => $confirm({
        dangerous: true,
        callback: () => $delete({
          url: this._getRowDataFrom$(e.target).delete_path,
          done: () => location.reload()
        })
      })
    });

    // Impact Analysis
    this._clickListener({
      target: ".context-menu a:contains('Impact Analysis')",
      handler: (e) => {
        let url = this._getRowDataFrom$(e.target).impact_path;
        new CdiscVersionSelect((date, id) => location.href = url.replace('thId', id), 'impact').open();
      }
    });

    // Clone
    this._clickListener({
      target: ".context-menu a:contains('Clone')",
      handler: (e) => {
        let url = this._getRowDataFrom$(e.target).clone_path;
        $("#newTerminologyModal form#new_thesaurus").attr("action", url);
      }
    });

    // Compare
    this._clickListener({
      target: ".context-menu a:contains('Compare')",
      handler: (e) => {
        let url = this._getRowDataFrom$(e.target).compare_path;
        this.itemSelector.setCallback((s) => location.href = `${url}?${$.param( { thesauri: { thesaurus_id: s.thesauri[0].id } } )}`) // TODO: Fix
        this.itemSelector.show();
      }
    });
  }

  /** Context Menu **/

  /**
   * Builds and renders the context menu of an item
   * @param {Object} data Compatible item data format to be rendered in the DataTable
   * @returns {string} formatted Context Menu HTML
   */
  _buildContextMenu(data, id) {
    const menuId = `con-menu-${id}`,
          menuStyle = { side: "left" },
          menuItems = [];

    // Required menu items common for all iso_managed types
    this._addMenuItems(menuItems, this._commonMenuItems(data));

    // Additional items (add new here)
    this._addMenuItems(menuItems, this._extraMenuItems(data));

    return renderMenu({ menuId, menuItems, menuStyle });
  }

  /**
   * Gets required common menu items for all managed types
   * @param {Object} data Item data
   * @returns {Array} Collection of common menu items
   */
  _commonMenuItems(data) {
    return [
      { url: data.show_path, icon: "icon-view", text: "Show", types: ["all"], required: true },
      { url: data.search_path, icon: "icon-search", text: "Search", types: ["all"], required: true  },
      { url: data.edit_path, icon: "icon-edit", text: "Edit", types: ["all"], required: true  },
      { url: data.status_path, icon: "icon-document", text: "Document control", types: ["all"], required: true  },
      { url: "#", icon: "icon-trash", text: "Delete", disabled: (data.delete_path === ""), types: ["all"], required: true }
    ];
  }

  /**
   * Gets extra history menu items. ** Add new items here **
   * @param {Object} data Item data
   * @returns {Array} Collection of extra menu items
   */
  _extraMenuItems(data) {
    return [
      { url: data.impact_path, target: "#", icon: "icon-impact", text: "Impact Analysis", endOffset: 1, types: ["thesauri"] },
      { url: data.list_cn_path, icon: "icon-note", text: "List Change notes", endOffset: 1, types: ["managed_concept"] },
      { url: data.current_path, icon: "icon-current", text: "Make current", disabled: (data.indicators.current), endOffset: 2, types: ["all"] },
      { url: data.clone_path, target: "#newTerminologyModal", icon: "icon-copy", text: "Clone", endOffset: 2, types: ["thesauri"], dataToggle: "modal" },
      { url: data.compare_path, target: "#", icon: "icon-compare", text: "Compare", dataToggle: "modal", endOffset: 2, types: ["thesauri", "cdisc_term"] },
      { url: data.view_path, icon: "icon-forms", text: "CRF", endOffset: 1, types: ["form"] },
      { url: data.build_path, icon: "icon-build", text: "Build", endOffset: 1, types: ["study"] }
    ]
  }


  /**
   * Adds valid items to the existing menuItems array
   * @param {Array} menuItems Common menu items
   * @param {Array} newItems Collection of new menu items definitions
   */
  _addMenuItems(menuItems, newItems = []) {
    for (const item of newItems) {
      const offset = item.endOffset != null ? menuItems.length - item.endOffset : menuItems.length;
      if(this._isItemValid(item))
        menuItems.splice(offset, 0, item);
    }
  }

  /**
   * Checks if a single menu item is valid. Must have a non-empty url and valid type.
   * @param {Object} item Single menu item
   * @return {boolean} Determines if item should be displayed in the context menu
   */
  _isItemValid(item) {
    if (item.required)
      return true;
    return (item.url) && (item.types.includes(this.param) || item.types.includes("all"));
  }

  /** Initializers and defaults **/

  /**
   * Get default column definitions for IsoManaged items
   * @return {Array} Array of DataTable column definitions
   */
  get _defaultColumns() {
    return [
      dtVersionColumn(),
      dtDateTimeColumn('last_change_date'),
      { data: "has_identifier.has_scope.short_name" },
      { data: "has_identifier.identifier" },
      { data: "label" },
      { data: "has_identifier.version_label" },
      {
        data: "has_state.registration_status",
        render: (data, type, r, m) => type === "display" ? rsHelper.renderRS(r) : data
      },
      dtIndicatorsColumn(),
      dtContextMenuColumn(this._buildContextMenu.bind(this))
    ]
  }

  /**
   * Extend default DataTable init options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {
    const options = super._tableOpts;

    options.columns = [...this._defaultColumns];
    options.language.emptyTable = "No versions found.";

    return options;
  }

  /**
   * Initialize a new ItemsSelector
   */
  _initItemSelector() {
    let requiredIn = ["thesauri", "cdisc_term"];

    if(requiredIn.includes(this.param))
      this.itemSelector = new ItemsSelector({
        id: "1",
        types: { thesauri: true },
        description: "Select one Terminology version with which to compare. " +
                     "It is recommended to select only from other versions of the item you are comparing."
      });
  }

}
