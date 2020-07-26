import TablePanel from 'shared/base/table_panel'

import { isCDISC } from 'shared/helpers/utils'

/**
 * Base Selectable Panel (Table)
 * @description Extensible Selectable DataTable panel
 * @extends TablePanel class from shared/base/table_panel
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SelectablePanel extends TablePanel {

  /**
   * Create a Selectable Panel
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table
   * @param {string} params.url Url of source data
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {int} params.count Count of items fetched in one request
   * @param {Array} params.extraColumns Additional column definitions
   * @param {boolean} params.deferLoading Set to true if data load should be deferred. Load data has to be called manually in this case
   * @param {boolean} params.cache Specify if the panel data should be cached. Optional.
   * @param {boolean} params.paginated Specify if the loadData call should be paginated. Optional, default = true
   * @param {Array} params.order DataTables deafult ordering specification, optional. Defaults to first column, descending
   * @param {Array} params.buttons DT buttons definitions objects, empty by default
   * @param {function} params.loadCallback Callback to data fully loaded, optional
   * @param {element} params.errorDiv Custom element to display flash errors in, optional
   * @param {boolean} params.multiple Enable / disable selection of multiple rows [default = false]
   * @param {boolean} params.showSelectionInfo Enable / disable selection info on the table
   * @param {boolean} params.ownershipColorBadge Enable / disable showing a color-coded ownership badge
   * @param {function} params.onSelect Callback on row(s) selected, passes selected row instances as argument, optional
   * @param {function} params.onDeselect Callback on row(s) deselected, passes deselected row instances as argument, optional
   * @param {Object} args Optional additional arguments
   */
  constructor({
    selector,
    url,
    param,
    count,
    extraColumns = [],
    deferLoading,
    cache = true,
    paginated = true,
    order = [[0, "desc"]],
    buttons = [],
    loadCallback = () => {},
    errorDiv,
    multiple = false,
    showSelectionInfo = true,
    ownershipColorBadge = false,
    onSelect = () => { },
    onDeselect = () => { }
  }) {
    super({ selector, url, param, count, extraColumns, deferLoading, cache, paginated, order, buttons, loadCallback, errorDiv },
          { multiple, showSelectionInfo, ownershipColorBadge, onSelect, onDeselect });

    Object.assign(this, { skipSelectCallback: false })
  }

  /**
   * Enables row selection for the user
   */
  enableSelect() { 
    if (this.multiple)
      this.table.select.style('multi');
    else
      this.table.select.style('single');
  }

  /**
   * Disables row selection for the user
   */
  disableSelect() { 
    this.table.select.style('api');
  }

  /**
   * Select one or more rows without trigerring the onSelect callback
   * @param {?} rows DT rows selector
   */
  selectWithoutCallback(rows) {
    this.skipSelectCallback = true;
    this.table.rows(rows).select();
    this.skipSelectCallback = false;
  }

  /**
   * Deselect one or more rows without trigerring the onSelect callback
   * @param {?} rows DT rows selector
   */
  deselectWithoutCallback(rows) {
    this.skipSelectCallback = true;
    this.table.rows(rows).deselect();
    this.skipSelectCallback = false;
  }

  /**
   * Get selected rows
   * @return {DataTables Rows} currently selected rows
   */
  get selected() {
    return this.table.rows({selected: true});
  }

  /**
   * Get selected rows' data objects
   * @return {Array} array of data objects of the currently selected rows
   */
  get selectedData() {
    return this.selected.data();
  }


  /** Private **/


  /**
   * Sets event listeners, handlers
   */
  _setListeners() {
    super._setListeners();

    // Row(s) selected
    this.table.on('select', (e, dt, t, indexes) => this._onSelect(indexes));

    // Row(s) deselected
    this.table.on('deselect', (e, dt, t, indexes) => this._onDeselect(indexes));
  }

  /**
   * Called when one or more rows are selected. Calls instance's onSelect by default
   * Override for custom behavior
   * @param {Array} indexes collection of zero-based indexes of the selected rows
   */
  _onSelect(indexes) { 
    if (!this.skipSelectCallback)
      this.onSelect(this.table.rows(indexes));
  }

  /**
   * Called when one or more rows are deselected. Calls instance's onDeselect by default
   * Override for custom behavior
   * @param {Array} indexes collection of zero-based indexes of the deselected rows
   */
  _onDeselect(indexes) {
    if (!this.skipSelectCallback)
      this.onDeselect(this.table.rows(indexes));
  }

  /**
   * Extend default DataTable init options with select options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {
    const options = super._tableOpts;

    options.columns = [...this.extraColumns];
    options.language.emptyTable = "No items found.";
    // Selection settings
    options.select = {
      style: this.multiple ? 'multi' : 'single',
      info: this.showSelectionInfo
    }

    // Row owner styling
    if (this.ownershipColorBadge)
      options.createdRow = (row, data, idx) => {
        $(row).addClass( isCDISC(data) ? 'row-cdisc y' : 'row-sponsor b' );
      }

    return options;
  }
}
