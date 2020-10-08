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
   * @return {DataTable} initialized DataTable instance
   */
  static initTable({
    selector = '#main',
    order = [0, 'asc']
  } = {} ) {

    return $( selector ).DataTable({
      columnDefs: [],
      pageLength: pageLength,     // Global variable
      lengthMenu: pageSettings,   // Global variable
      autoWidth: false,
      order: order
    });

  }

}
