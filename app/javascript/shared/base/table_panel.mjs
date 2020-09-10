import { $getPaginated, $get } from 'shared/helpers/ajax';
import { renderSpinner } from 'shared/ui/spinners'

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
   * @param {Array} params.extraColumns Additional column definitions
   * @param {boolean} params.deferLoading Set to true if data load should be deferred. Load data has to be called manually in this case
   * @param {boolean} params.cache Specify if the panel data should be cached. Optional.
   * @param {boolean} params.paginated Specify if the loadData call should be paginated. Optional, default = true
   * @param {Array} params.order DataTables deafult ordering specification, optional. Defaults to first column, descending
   * @param {Array} params.buttons DT buttons definitions objects, empty by default
   * @param {function} params.loadCallback Callback to data fully loaded, receives table instance as argument, optional
   * @param {element} params.errorDiv Custom element to display flash errors in, optional
   * @param {Object} args Optional additional arguments for extending classes
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
    errorDiv
  }, args = {}) {
    Object.assign(this, { selector, url, param, count, extraColumns, cache, paginated, order, buttons, loadCallback, errorDiv, ...args });

    this._initTable();
    this._setListeners();

    if (!deferLoading)
      this.loadData();
  }

  /**
   * Clears table, loads and draws data
   * @param {string} url optional, specify data source url
   * @return {self} this instance
   */
  loadData(url) {
    // Set new instance data url if specified
    if (url)
      this.url = url;

    this.clear();
    this._loading(true);

    if (this.paginated)
      this.request = $getPaginated(0, {
        url: this.url,
        count: this.count,
        strictParam: this.param,
        cache: this.cache,
        errorDiv: this.errorDiv,
        pageDone: (data) => this._render(data),
        done: (data) => this.loadCallback(this.table),
        always: () => this._loading(false)
      });
    else
      this.request = $get({
        url: this.url,
        cache: this.cache,
        errorDiv: this.errorDiv,
        done: (data) => {
          this._render(data)
          this.loadCallback(this.table)
        },
        always: () => this._loading(false)
      });

    return this;
  }

  /**
   * Clears table data and filters and kills any running requests
   */
  clear() {
    this.table.search('').clear().draw();
    this.kill();
  }

  /**
   * Refresh (reload) table data
   * @param {string} url optional, specify data source url
   */
  refresh(url) {
    this.loadData(url);
  }

  /**
   * Kill any ongoing loading process
   */
  kill() {
    if ( this.request )
      this.request.abort();
  }

  /** Private **/

  /**
   * Sets event listeners, handlers
   */
  _setListeners() { }

  /**
   * Finds DT row data in which element is present
   * @param {HTML Element} el html element that is contained in the table row
   * @return {Object} DT row data object
   */
  _getRowDataFrom$(el) {
    return this._getRowFrom$(el).data();
  }

  /**
   * Finds DT Row instance in which element is present
   * @param {HTML Element} el html element that is contained in the table row
   * @return {Object} DT Row instance
   */
  _getRowFrom$(el) {
    return this.table.row($(el).closest("tr"));
  }

  /**
   * Finds DT Row instance in which data property equals to the provided value
   * @param {string} propertyName name of the property in row's data object to serach by (e.g. 'id')
   * @param {?} value value to compare the data property by
   * @return {Object} DT Row instance
   */
  _getRowFromData(propertyName, value) {
    return this.table.row( (i, data) => data[propertyName] === value ? true : false );
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
   * @param {boolean} clear Enable clearing the table before rendering, optional, default = false
   */
  _render(data, clear = false) {
    // Clear data first if argument set to true
    if (clear)
      this.clear();

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

    // Show buttons if exist
    if (this.buttons.length)
      this.table.buttons().container()
        .appendTo( $('.col-sm-6:eq(0)', this.table.table().container()) );
  }

  /**
   * DataTable basic options
   * @return {Object} DataTable initialization options object
   */
  get _tableOpts() {
    return {
      order: this.order,
      columns: [...this._defaultColumns, ...this.extraColumns],
      pageLength: pageLength,
      lengthMenu: pageSettings,
      processing: true,
      autoWidth: false,
      language: {
        infoFiltered: "",
        emptyTable: "No data.",
        processing: renderSpinner('small')
      },
      buttons: this.buttons
    }
  }

}
