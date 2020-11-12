/**
 * Simple DataTable initializer
 * @description Initializes a DataTable pre-filled with data in HTML (no data fetching)
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TableInitializer {

  /**
   * Initialize a single DataTable instance by given selector
   * @static
   * @param {string} selector Data table selector [default = '#main']
   * @param {array} order Data table order [default = [0, 'asc']]
   * @param {Object} tableOpts Extra DataTable options, optional
   * @return {DataTable} initialized DataTable instance
   */
  static initTable({
    selector = '#main',
    order = [0, 'asc'],
    tableOpts = {}
  } = {} ) {

    return $( selector ).DataTable(
      Object.assign( TableInitializer._defaultOpts, tableOpts, order )
    );

  }


  static get _defaultOpts() {

    return {
      columnDefs: [],
      pageLength: pageLength,     // Global variable
      lengthMenu: pageSettings,   // Global variable
      autoWidth: false,
      language: {
        emptyTable: 'No data available'
      }
    }

  }

}
