import Cacheable from 'shared/base/cacheable'

import IPPanel from 'shared/ui/items_picker/ip_panel'
import { makeHistoryUrl } from 'shared/helpers/urls'
import { tableInteraction } from 'shared/helpers/utils'
import { dtIndexColumns, dtCLIndexColumns, dtSimpleHistoryColumns } from 'shared/helpers/dt/dt_column_collections'

/**
 * Managed Item Selector
 * @description Allows for a selection of a specific version of a Managed Item
 * @requires index HTML table
 * @requires history HTML table
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ManagedItemSelector extends Cacheable {

  /**
   * Create a Managed Item Selector instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table
   * @param {Object} params.urls Object containing the all item types' history and index data url bases
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {boolean} params.multiple Enable / disable selection of multiple rows [default = false]
   * @param {SelectionView} params.selectionView Selection View instance reference of the Item Picker
   * @param {element} params.errorDiv Custom element to display flash errors in, optional
   */
  constructor({
    selector,
    urls,
    param,
    multiple = false,
    selectionView,
    errorDiv
  }) {
    super();

    Object.assign(this, { selector, param, multiple, selectionView, errorDiv });
    this.urls = urls[this._realParam];

    this._initialize();
    this._setListeners();
  }

  /**
   * Resets all panels and clears instance's cache
   */
  clear() {
    this.dataLoaded = false;

    this.indexPanel.clear();
    this.historyPanel.clear();
    this._clearCache();
  }

  /**
   * Loads and renders Index panel data
   */
  load() {
    if (this.dataLoaded)
      return;

    this._toggleInteractivity(false);
    this.indexPanel.loadData();
    this.dataLoaded = true;
  }


  /** Private **/


  /**
   * Initializes the required panels for Selector type
   */
  _initialize() {

    // Throws error when param name not present in the url object
    if (!this.urls)
      throw new Error(`Wrong param name '${this.param}' specified.`)

    // Initializes Selectable Index Panel
    this.indexPanel = new IPPanel({
      url: this.urls.index,
      selector: `${this.selector} table#index`,
      param: this._realParam,
      count: 500,
      extraColumns: this._indexColumns,
      showSelectionInfo: false,
      ownershipColorBadge: true,
      errorDiv: this.errorDiv,
      onSelect: () => this._loadHistoryData(),
      onDeselect: () => this.historyPanel.clear(),
      loadCallback: () => this._toggleInteractivity(true)
    });

    // Initializes Selectable History Panel
    this.historyPanel = new IPPanel({
      selector: `${this.selector} table#history`,
      param: this._realParam,
      count: 100,
      extraColumns: this._historyColumns,
      multiple: this.multiple,
      errorDiv: this.errorDiv,
      onSelect: (dtRows) => this._onItemSelect(dtRows),
      onDeselect: (dtRows) => this._onItemDeselect(dtRows),
      loadCallback: (t) => {
        this._cacheItemHistory( t.rows().data().toArray() );
        this._toggleInteractivity(true);
      },
    });
  }

  /**
   * Set Selector event listeners and handlers
   */
  _setListeners() {
    // History Panel draw event, auto-update row selection
    this.historyPanel.table.on('draw', () => this._updateRowSelection(this.historyPanel));

    // Selection change event, auto-update row selection
    this.selectionView.div.on('selection-change', (e, type) => this._updateRowSelection(this.historyPanel, type));
  }

  /**
   * Automatically selects/deselect panel rows to match the items in contained in selectionView without invoking onSelect / onDeselect callbacks
   * @param {IPPanel} panel the panel to update row selection in
   * @param {string} type value representing the type of update, can be 'removed' or 'added', optional
   */
  _updateRowSelection(panel, type = '') {
    // Deselect all rows if removed
    if (type === 'removed')
      panel.deselectWithoutCallback('');

    // Match selected rows with selection
    for (const selectedItem of this.selectionView.selection) {
      const row = panel._getRowFromData('id', selectedItem.id);

      if (row.length)
        panel.selectWithoutCallback(row);
    }
  }

  /**
   * Called when one or more items get selected by user, adds them to selectionView
   * @param {DataTable Rows} dtRows references to the selected row object(s)
   */
  _onItemSelect(dtRows) {
    const data = dtRows.data().toArray();

    this.selectionView.add(data);
  }

  /**
   * Called when one or more items get deselected by user, removes them from selectionView
   * @param {DataTable Rows} dtRows references to the deselected row object(s)
   */
  _onItemDeselect(dtRows) {
    const ids = dtRows.data().toArray().map((d) => d.id);

    this.selectionView.removeById(ids);
  }


  /** Cache **/


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


  /** Helpers and getters **/


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
    switch (this._realParam) {
      case 'managed_concept':
        return dtCLIndexColumns();
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
    switch (this._realParam) {
      default:
        return dtSimpleHistoryColumns();
        break;
    }
  }

  /**
   * Get the real controller param name, modify / override for different behaviours
   * @return {string} real controller param name
   */
  get _realParam() {
    return this.param;
  }

}
