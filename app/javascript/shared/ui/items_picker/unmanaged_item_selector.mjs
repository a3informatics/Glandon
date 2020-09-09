import ManagedItemSelector from 'shared/ui/items_picker/managed_item_selector'

import IPPanel from 'shared/ui/items_picker/ip_panel'
import { makeMCChildrenUrl } from 'shared/helpers/urls'
import { tableInteraction } from 'shared/helpers/utils'
import { conceptRef } from 'shared/ui/strings'

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
   * Create an Unmanaged Item Selector instance
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
    errorDiv,
  }) {
    super({ selector, urls, param, multiple, selectionView });
  }

  /**
   * Resets all panels and clears instance's cache, UI toggle to index panel
   */
  clear() {
    super.clear();
    this.childrenPanel.clear();
    this._clearItemRef();

    this._togglePanels('index');
  }


  /** Private **/


  /**
   * Calls super's initialize, alters History panel instance and adds the Children panel
   */
  _initialize() {
    super._initialize();

    // Extend indexPanel's onSelect and onDeselect callbacks
    this.indexPanel.onSelect = () => {
      this._loadHistoryData();
      this._showItemRef();
    }
    this.indexPanel.onDeselect = () => {
      this.historyPanel.clear();
      this._clearItemRef();
    }
    // Modify selection type of history panel
    this.historyPanel.table.select.style('single');
    // Reset history panel's draw callback
    this.historyPanel.drawCallback = () => { }
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
      param: this._realParam,
      count: 10000,
      extraColumns: this._childrenColumns,
      showSelectionInfo: false,
      multiple: this.multiple,
      errorDiv: this.errorDiv,
      onSelect: (dtRows) => this._onItemSelect(dtRows),
      onDeselect: (dtRows) => this._onItemDeselect(dtRows),
      loadCallback: (t) => {
        this._cacheItemChildren( t.rows().data().toArray() );
        this._toggleInteractivity(true);
      }
    });

  }

  /**
   * Set Selector event listeners and handlers
   */
  _setListeners() {
    // Children Panel draw event, auto-update row selection
    this.childrenPanel.table.on('draw', () => this._updateRowSelection(this.childrenPanel));

    // Selection change event, auto-update row selection
    this.selectionView.div.on('selection-change', (e, type) => this._updateRowSelection(this.childrenPanel, type));
  }

  /**
   * Called when one or more items get selected by user, adds them to selectionView
   * @param {DataTable Rows} dtRows references to the selected row object(s)
   */
  _onItemSelect(dtRows) {
    const data = dtRows.data().toArray();

    // Find parent data and add to the selected child data object (required to create item reference string)
    const parentData = this.historyPanel.selectedData[0]
    data.forEach( (d) => Object.assign(d, {context: parentData}) );

    this.selectionView.add(data);
  }


  /** Cache **/


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


  /** Concept reference  **/

  /**
   * Show picked item reference in UI placeholder
   */
  _showItemRef() {
    const selectedItem = this.indexPanel.selectedData[0];
    $(this.selector).find('.item-placeholder')
                    .text( conceptRef(selectedItem) );
  }

  /**
   * Clear picked item reference in UI placeholder
   */
  _clearItemRef() {
    $(this.selector).find('.item-placeholder')
                    .text('');
  }


  /** Helpers and getters **/


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
    $(`${this.selector} table#${target}`).closest(".card").show();

    switch (target) {
      case "children":
        $(`${this.selector} table#index`).closest(".card").hide();
        break;
      case "index":
        $(`${this.selector} table#children`).closest(".card").hide();
        break;
    }
  }

  /**
   * Get DT Children panel column definitions for instance's 'param' type
   * @return {Array} DT History panel column definitions
   */
  get _childrenColumns() {
    switch (this._realParam) {
      case 'managed_concept':
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

  /**
   * Get the real controller param name, modify / override for different behaviours
   * @return {string} real controller param name
   */
  get _realParam() {
    return 'managed_concept';
  }

}
