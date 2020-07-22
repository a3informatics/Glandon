import Cacheable from 'shared/base/cacheable'

import IPPanel from 'shared/ui/items_picker/ip_panel'
import { makeHistoryUrl } from 'shared/helpers/urls'
import { tableInteraction } from 'shared/helpers/utils'
import { dtIndexColumns, dtSimpleHistoryColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtIndicatorsColumn } from 'shared/helpers/dt/dt_columns'

/**
 * Managed Item Selector
 * @description Allows for a selection of a specific version of a Managed Item
 * @requires index HTML table
 * @requires history HTML table
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ManagedItemSelector extends Cacheable {

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
    super();

    Object.assign(this, { selector, urls: urls[param], param, multiple, onSelect, onDeselect })
    this._initialize();
    this._loadIndexData();
  }

  /**
   * Refreshes the selector to its initial state
   */
  refresh() {
    this.indexPanel.refresh();
    this.historyPanel.clear();
  }


  /** Private **/


  /**
   * Initializes the required panels for Selector type
   */
  _initialize() {

    // Initializes Selectable Index Panel
    this.indexPanel = new IPPanel({
      url: this.urls.index,
      selector: `${this.selector} table#index`,
      param: this.param,
      count: 500,
      extraColumns: this._indexColumns,
      showSelectionInfo: false,
      ownershipColorBadge: true,
      onSelect: () => this._loadHistoryData(),
      onDeselect: () => this.historyPanel.clear(),
      loadCallback: () => this._toggleInteractivity(true)
    });

    // Initializes Selectable History Panel
    this.historyPanel = new IPPanel({
      selector: `${this.selector} table#history`,
      param: this.param,
      count: 100,
      extraColumns: this._historyColumns,
      multiple: this.multiple,
      loadCallback: (t) => {
        this._cacheItemHistory( t.rows().data().toArray() );
        this._toggleInteractivity(true);
      }
    });

  }

  /**
   * Generates a cache key and saves the History data into the local cache
   * @param {Array} data Table item data array to be cached
   */
  _cacheItemHistory(data) {
    // Generate cache key from the currently selected row in the Index panel
    const cacheKey = this._makeCacheKey(this.indexPanel.selectedData[0]);

    // Store current state of History panel in the cache
    this._saveToCache( cacheKey , data )
  }

  /**
   * Loads and renders Index data
   */
  _loadIndexData() {
    this._toggleInteractivity(false);
    this.indexPanel.loadData();
  }

  /**
   * Loads and renders History data for item selected in Index panel
   */
  _loadHistoryData() {
    const selectedItem = this.indexPanel.selectedData[0];
    // Generate cache key from the currently selected row in the Index panel
    const cacheKey = this._makeCacheKey(selectedItem);

    // Try loading data from the cache
    if (this._getFromCache(cacheKey) !== null)
      this.historyPanel._render( this._getFromCache(cacheKey), true );

    // Otherwise load from the server
    else {
      this._toggleInteractivity(false);
      this.historyPanel.loadData( makeHistoryUrl(this.urls.history, selectedItem) );
    }
  }

  /**
   * Generates a unique cache key from item data
   * @param {Object} data Item's data object containing identifier and scope_id
   * @return {string} cache key dependent on data argument
   */
  _makeCacheKey(data) {
    return `${data.identifier}:${data.scope_id}`;
  }

  /**
   * Toggles interactivity on instance's panels
   * @param {boolean} enable Set to true to enable interactivity, false to disable it
   */
  _toggleInteractivity(enable) {
    // Make tables selector
    const targets = `${this.indexPanel.selector}, ${this.historyPanel.selector}`;

    if (enable) 
      tableInteraction.enable(targets);
    else
      tableInteraction.disable(targets);
  }

  /**
   * Get DT Index panel column definitions for instance's 'param' type
   * @return {Array} DT Index panel column definitions
   */
  get _indexColumns() {
    switch (this.param) {
      case "managed_concept":
        return [...dtIndexColumns(), { data: "notation" }, dtIndicatorsColumn()];
        break;
      default:
        return dtIndexColumns();
        break;
    }
  }

  /**
   * Get DT History panel column definitions for instance's 'param' type
   * @return {Array} DT History panel column definitions
   */
  get _historyColumns() {
    switch (this.param) {
      default:
        return dtSimpleHistoryColumns();
        break;
    }
  }

}
