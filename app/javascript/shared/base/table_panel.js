import { $getPaginated, $get } from 'shared/helpers/ajax'
import { renderSpinner } from 'shared/ui/spinners'
import { setOnErrorHandler } from 'shared/helpers/dt/utils'

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
   * @param {Object} params.tableOptions Custom DT options object, will be merged with this instance's _tableOpts, optional
   * @param {function} params.loadCallback Callback to data fully loaded, receives table instance as argument, optional
   * @param {boolean} params.autoHeight Specifies whether the height of the table should match the window size, and add a horizontal scroll, optional
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
    tableOptions = {},
    loadCallback = () => {},
    autoHeight = false,
    errorDiv
  }, args = {}) {

    Object.assign(this, {
      selector, url, param, count, extraColumns, deferLoading, cache,
      paginated, order, buttons, tableOptions, loadCallback, autoHeight,
      errorDiv, ...args
    });

    this.initialize( deferLoading );
    this._setListeners();

  }

  /**
   * Clears table, loads and draws data
   * @param {string} url optional, specify data source url
   * @return {self} this instance
   */
  loadData(url) {

    // Set new instance data url if specified
    if ( url )
      this.url = url;

    this.clear( false );
    this._loading( true );

    if ( this.paginated )
      this._loadDataPaginated();

    else
      this._loadData();

    return this;

  }

  /**
   * Clears table data and filters and kills any running requests
   * @param {boolean} draw Specifies whether the table should redraw on clear, optional [default=true]
   */
  clear(draw = true) {

    this.table.search('')
              .clear()

    this.kill();

    if ( draw )
      this.table.draw();

  }

  /**
   * Refresh (reload) table data
   * @param {string} url optional, specify data source url
   */
  refresh(url) {
    this.loadData( url );
  }

  /**
   * Kill any ongoing loading process
   */
  kill() {

    if ( this.request )
      this.request.abort();

  }

  /**
   * Get current table rows data as an Array
   * @return {array} Array of all row data objects
   */
  get rowDataToArray() {
    return this.table.rows().data().toArray();
  }

  /**
   * Initialize the Table Panel and listeners
   */
  initialize() {

    this._initTable();
    this._setTableListeners();

    if ( !this.deferLoading )
      this.loadData();

  }

  /**
   * Destroy the DataTable instance in the Panel
   */
  destroy() {

    this.table.destroy();
    // Unbind all event handlers
    $( this.selector ).unbind();
    $(`${ this.selector } tbody`).unbind()
                                 .empty();

  }


  /** Private **/


  /**
   * Sets event listeners, handlers
   * Used for non-table related listeners only!
   */
  _setListeners() { }

  /**
   * Sets event listeners, handlers
   * Used for table related listeners only!
   */
  _setTableListeners() { }

  /**
   * Fetch data in a single request, handle loading and updates
   */
  _loadData() {

    this.request = $get({
      url: this.url,
      cache: this.cache,
      errorDiv: this.errorDiv,
      done: data => {

        this._render( data );
        this._onDataLoaded( this.table );

      },
      always: () => this._loading( false )
    });

  }

  /**
   * Fetch data in a paginated request, handle loading and updates
   */
  _loadDataPaginated() {

    this.request = $getPaginated(0, {
      url: this.url,
      count: this.count,
      strictParam: this.param,
      cache: this.cache,
      errorDiv: this.errorDiv,
      pageDone: data => {

        this._render( data )
        this._loadingExtra( true ); // Show non-intrusive loading-extra animation

      },
      done: data => {

        this._loadingExtra( false );  // Hide loading-extra animation
        this._onDataLoaded( this.table );

      },
      always: () => this._loading( false )
    });

  }


  /** Rows **/


  /**
   * Finds DT row data in which element is present
   * @param {HTML Element} el html element that is contained in the table row
   * @return {Object} DT row data object
   */
  _getRowDataFrom$(el) {
    return this._getRowFrom$( el ).data();
  }

  /**
   * Finds DT Row instance in which element is present
   * @param {HTML Element} el html element that is contained in the table row
   * @return {Object} DT Row instance
   */
  _getRowFrom$(el) {
    return this.table.row( $( el ).closest( 'tr' ) );
  }

  /**
   * Finds DT Row instance in which data property equals to the provided value
   * @param {string} propertyName name of the property in row's data object to serach by (e.g. 'id')
   * @param {?} value value to compare the data property by
   * @return {Object} DT Row instance
   */
  _getRowFromData(propertyName, value) {
    return this.table.row( ( i, data ) => data[ propertyName ] === value ? true : false );
  }


  /** Render **/


  /**
   * Add data into table and draw
   * @param {Array} data Sequence of items containing data to be added to the table
   * @param {boolean} clear Enable clearing the table before rendering, optional, default = false
   * @param {boolean | string} drawType Draw type, optional, see DataTables documentation
   */
  _render(data, clear = false, drawType) {

    // Clear data first if argument set to true
    if ( clear )
      this.clear( false );

    for( let item of data ) {
      this.table.row.add( item );
    }

    this.table.draw( drawType )
    this.table.columns.adjust();

  }


  /** Events **/


  /**
   * Executed when table data fully loaded, calls loadCallback with current table instance as argument
   */
  _onDataLoaded() {

    // Update processing flag so that loadCallback can refer to the correct processing state
    this.isProcessing = false;

    if ( this.loadCallback )
      this.loadCallback( this.table );

  }

  /**
   * Sets click listener and handler
   * @param {string} target JQuery selector of target element
   * @param {function} handler Function to be executed on click
   */
  _clickListener( { target, handler } ) {
    $( `${ this.selector } tbody` ).on( 'click', target, handler );
  }


  /** Support **/


  /**
   * Change panel's loading state and update the isProcessing instance variable
   * @param {boolean} enable value corresponding to the desired loading state on/off
   */
  _loading(enable) {

    this.isProcessing = enable;
    this.table.processing( enable );

  }

  /**
   * Change panel's unintrusive loading animation used for indication of extra data load, pagination
   * @param {boolean} enable value corresponding to the desired loading state on/off
   */
  _loadingExtra(enable) {

    this.isProcessing = enable;
    this.$wrapper.find( '.dataTables_info' )
                 .toggleClass( 'el-loading', enable );

  }

  /**
   * Get the wrapper element of the table instance
   * @return {JQuery Element} Table wrapper div
   */
  get $wrapper() {
    return $( `${ this.selector }_wrapper` );
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

    this.table = $( this.selector ).DataTable( this._tableOpts );

    // Generic table error handler
    setOnErrorHandler( this.table );

    // Append buttons to DOM if any defined
    if ( this._tableOpts.buttons.length )
      this.table.buttons()
                .container()
                .appendTo( $( '.col-sm-6:eq(0)', this.table.table().container() ) );

  }

  /**
   * Set of DT options for a horizontally scrollable table with height that fits in the current window
   * @return {Object} DataTable options object
   */
  get _autoHeightOpts() {

    let minHeight = 300,
        docHeight = $( document ).innerHeight(),
        yHeight = Math.max( docHeight - 200, minHeight );

    return {
      autoWidth: true,
      scrollCollapse: true,
      scrollY: yHeight,
      scrollX: true
    }

  }

  /**
   * DataTable basic options
   * @return {Object} DataTable initialization options object
   */
  get _tableOpts() {

    let opts =  {
      order: this.order,
      columns: [
        ...this._defaultColumns,
        ...this.extraColumns
      ],
      pageLength: pageLength,
      lengthMenu: pageSettings,
      processing: true,
      autoWidth: false,
      language: {
        emptyTable: 'No data.'
      },
      buttons: [...this.buttons]
    }

    if ( this.autoHeight )
      Object.assign( opts, this._autoHeightOpts );

    if ( this.tableOptions ) // Merge with custom options
      Object.assign( opts, this.tableOptions );

    // Language options that cannot be overridden 
    Object.assign( opts.language, {
      infoFiltered: '',
      processing: renderSpinner( 'small' )
    })

    return opts;

  }

}
