import { $getPaginated } from 'shared/helpers/ajax';

/**
 * Base Table Panel
 * @description Extensible Base for a DataTable panel
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TablePanel {

  /**
   * Create a Panel
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table
   * @param {string} params.url Url of source data
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {int} params.count Count of items fetched in one request
   * @param {Array} params.extraColumns - Additional column definitions
   * @param {boolean} params.deferLoading - Set to true if data load should be deferred. Load data has to be called manually in this case
   * @param {boolean} params.cache - Specify if the panel data should be cached. Optional.
   */
  constructor({
    selector,
    url,
    param,
    count,
    extraColumns = [],
    deferLoading,
    cache = true
  }) {
    Object.assign(this, { selector, url, param, count, extraColumns, cache });
    this._initTable();
    this._setListeners();

    if (!deferLoading)
      this.loadData();
  }

  /**
   * Clears table, loads and draws data
   * @return {self} this instance
   */
  loadData() {
    this.table.clear().draw();
    this._loading(true);

    $getPaginated(0, {
      url: this.url,
      count: this.count,
      strictParam: this.param,
      cache: this.cache,
      pageDone: (data) => this._renderPage(data),
      done: () => this._loading(false),
      always: () => {}
    });

    return this;
  }

  /** Private **/

  /**
   * Sets event listeners, handlers
   */
  _setListeners() { }

  /**
   * Finds DT row data in which element is present
   * @return {Object} DT row data object
   */
  _getRowData(el) {
    return this.table.row($(el).closest("tr")).data();
  }

  /**
   * Sets click listener and handler
   * @param {string} target JQuery selector of target element
   * @param {function} handler Function to be executed on click
   */
  _clickListener( { target, handler } ) {
    $(`${this.selector} tbody`).on("click", target, handler);
  }

  /**
   * Add data into table and draw
   * @param {Array} data Sequence of items containing data to be added to the table
   */
  _renderPage(data) {
    for(let item of data) {
      this.table.row.add(item);
    }

    this.table.draw();
    this.table.columns.adjust();
  }

  /**
   * Change panel's loading state
   * @param {boolean} enable value corresponding to the desired loading state on/off
   */
  _loading(enable) {
    this.table.processing(enable);
  }

  /**
   * Get default column definitions for IsoManaged items
   * @return {Array} Array of DataTable column definitions
   */
  get _defaultColumns() {
    return [];
  }

  /**
   * Initialize a new DataTable
   * @return {DataTable instance} An initialized table panel
   */
  _initTable() {
    this.table = $(this.selector).DataTable(this._tableOpts);
  }

  /**
   * DataTable basic options
   * @return {Object} DataTable initialization options object
   */
  get _tableOpts() {
    return {
      order: [[0, "desc"]],
      columns: [...this._defaultColumns, ...this.extraColumns],
      pageLength: pageLength,
      lengthMenu: pageSettings,
      processing: true,
      autoWidth: false,
      language: {
        infoFiltered: "",
        emptyTable: "No data.",
        processing: generateSpinner("small")
      }
    }
  }

}
