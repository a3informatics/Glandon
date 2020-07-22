import ManagedItemSelector from 'shared/ui/items_picker/managed_item_selector'

import IPPanel from 'shared/ui/items_picker/ip_panel'
import { makeMCChildrenUrl } from 'shared/helpers/urls'
import { tableInteraction } from 'shared/helpers/utils'

/**
 * Unmanaged Item Selector
 * @description Allows for a selection of a specific Unmanaged Item within a version of a Managed Item
 * @requires index HTML table
 * @requires history HTML table
 * @requires children HTML table
 * @extends ManagedItemSelector module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class UnmanagedItemSelector extends ManagedItemSelector {

  /**
   * Create a Managed Item Selector
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table
   * @param {Object} params.urls Object containing the history and index data url bases
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {boolean} params.multiple Enable / disable selection of multiple rows [default = false]
   * @param {function} params.onSelect Callback on row(s) selected, optional
   * @param {function} params.onDeselect Callback on row(s) deselected, optional
   */
  constructor({
    selector,
    urls,
    param,
    multiple = false,
    onSelect = () => { },
    onDeselect = () => { }
  }) {
    super({ selector, urls, param, multiple, onSelect, onDeselect });
  }

  /**
   * Refreshes the selector to its initial state
   */
  refresh() {
    super.refresh();
    this.childrenPanel.clear();
  }


  /** Private **/


  /**
   * Calls super's initialize, modified History panel and adds the Children panel
   */
  _initialize() {
    super._initialize();

    // Modify selection type of history panel to is
    this.historyPanel.table.select.style('single');
    // Override historyPanel's onSelect function to load childrenPanel data
    this.historyPanel.onSelect = () => {
      this._togglePanels('children');
      this._loadChildrenData();
    }
    // Override historyPanel's onDeselect function to clear childrenPanel
    this.historyPanel.onDeselect = () => {
      this.childrenPanel.clear();
      this._togglePanels('index');
    }

    // Initializes Selectable Children Panel
    this.childrenPanel = new IPPanel({
      selector: `${this.selector} table#children`,
      param: this.param,
      count: 10000,
      extraColumns: this._childrenColumns,
      showSelectionInfo: false,
      multiple: this.multiple,
      loadCallback: (t) => {
        this._cacheItemChildren( t.rows().data().toArray() );
        this._toggleInteractivity(true);
      }
    });

  }

  /**
   * Generates a cache key and saves the Children data into the local cache
   * @param {Array} data Table item data array to be cached
   */
  _cacheItemChildren(data) {
    // Generate cache key from the currently selected row in the History panel
    const cacheKey = this.historyPanel.selectedData[0].id;

    // Store current state of Children panel in the cache
    this._saveToCache( cacheKey , data )
  }

  /**
   * Loads and renders Children data for item selected in History panel
   */
  _loadChildrenData() {
    const selectedItem = this.historyPanel.selectedData[0];
    // Generate cache key from the currently selected row in the Index panel
    const cacheKey = selectedItem.id;

    // Try loading data from the cache
    if (this._getFromCache(cacheKey) !== null)
      this.childrenPanel._render( this._getFromCache(cacheKey), true );

    // Otherwise load from the server
    else {
      this._toggleInteractivity(false);
      this.childrenPanel.loadData( makeMCChildrenUrl (this.urls.children, selectedItem) );
    }
  }

  /**
   * Toggles interactivity on instance's panels
   * @param {boolean} enable Set to true to enable interactivity, false to disable it
   */
  _toggleInteractivity(enable) {
    super._toggleInteractivity(enable);

    if (enable) 
      tableInteraction.enable(this.childrenPanel.selector);
    else
      tableInteraction.disable(this.childrenPanel.selector);
  }

  /**
   * Toggles panel cards visiblity
   * @param {string} target Table id to show
   */
  _togglePanels(target) {
    $(`${this.selector} table#${target}`).closest(".card").hide();

    switch (target) {
      case "children":
        $(`${this.selector} table#children`).closest(".card").show();
        break;
      case "index":
        $(`${this.selector} table#index`).closest(".card").show();
        break;
    }
  }

  /**
   * Get DT Children panel column definitions for instance's 'param' type
   * @return {Array} DT History panel column definitions
   */
  get _childrenColumns() {
    switch (this.param) {
      case "managed_concept":
        return [
          {"data" : "identifier"},
          {"data" : "notation"},
          {"data" : "preferred_term"}
        ]
        break;
      default:
        return []
        break;
    }
  }

}
