import TablePanel from 'shared/base/table_panel'

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
   * @param {boolean} params.multiple Enable / disable selection of multiple rows [default = false]
   * @param {boolean} params.showSelectionInfo Enable / disable selection info on the table
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
    multiple = false,
    showSelectionInfo = true
  }) {
    super({ selector, url, param, count, extraColumns, cache, paginated, order, buttons },
          { multiple, showSelectionInfo });
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
    this.table.on('select', (e, dt, t, indexes) => this.onSelect(indexes));

    // Row(s) deselected
    this.table.on('deselect', (e, dt, t, indexes) => this.onDeselect(indexes));
  }

  /**
   * Called when one or more rows are selected
   * Override for custom behavior
   * @param {Array} indexes collection of zero-based indexes of the selected rows
   */
  _onSelect(indexes) { 

  }

  /**
   * Called when one or more rows are deselected
   * Override for custom behavior
   * @param {Array} indexes collection of zero-based indexes of the deselected rows
   */
  _onDeselect(indexes) {

  }

  /**
   * Extend default DataTable init options with select options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {
    const options = super._tableOpts;

    options.columns = [...this.extraColumns];
    // Selection
    options.select = {
      style: this.multiple ? 'multi' : 'single',
      info: this.showSelectionInfo
    }

    return options;
  }
}
