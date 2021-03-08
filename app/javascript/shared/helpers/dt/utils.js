import { alerts } from 'shared/ui/alerts'

/**
 * Set a generic error handler to a DataTable instance 
 * @param {DataTable} table Table to attach error handler to
 */
function setOnErrorHandler(table) {

  table.on( 'error.dt', ( e, settings, techNote, message ) => 
    alerts.error( 'An error has occurred while processing table data. Please report it to the system administrators.' )
  );

}

/**
 * Removes the "fit" class from a DataTable column header
 * @param {string} name Text which the target column header contains
 * @param {string} tableId Unique table selector
 */
function expandColumn(name, tableId) {
  $(`${tableId} th:contains('${name}')`).removeClass("fit");
}

/**
 * Adds the "fit" class to a DataTable column header
 * @param {string} name Text which the target column header contains
 * @param {string} tableId Unique table selector
 */
function fitColumn(name, tableId) {
  $(`${tableId} th:contains('${name}')`).addClass("fit");
}

/**
 * Check if table element contains a specific column header
 * @param {string} selector Unique selector of the table (or its  wrapper)
 * @param {string} colName Column header name to check for 
 * @return {boolean} True if table contains header with given name 
 */
function hasColumn(selector, colName) {
  return $( selector ).find( `th:contains("${ colName }")` ).length > 0; 
}

/**
 * Jump to the page containing the given row 
 * @param {DataTable} table Target table instance
 * @param {object} rowData Target row data object
 * @return {TablePanel} This instance
 */
function jumpToRow(table, rowData) {

  const pos = table.rows({ order:'applied' })
                   .data()
                   .indexOf( rowData )

  if ( pos >= 0 ) {
      const page = Math.floor( pos / table.page.info().length );
      table.page( page ).draw( false );
  }
  
}

/**
 * Highlight a single row in table and scroll it into view (row must exist on current page)
 * @param {DataTable} table Target table instance
 * @param {string | int | function} rowSelector DataTables compatible unique row selector 
 * @param {boolean} blink Specify whether the highlight should be taken off after a timeout, [default=true]
 * @param {boolean} blinkTimeoutMs Blink timeout duration in milliseconds, optional [default=1000] 
 * @return {TablePanel} This instance
 */
function highlightRow(table, rowSelector, blink = true, blinkTimeoutMs = 1000) {

  const row = table.row( rowSelector ).node();

  $(row).addClass('row-highlight')

  // Unhighlight after a timeout elapses if blink true 
  blink && setTimeout( () => 
    $(row).removeClass('row-highlight'), blinkTimeoutMs 
  )

  // Scroll row into view
  row.scrollIntoView()

}


/*** Buttons ***/


/**
 * DataTable Export CSV button definition
 * @param {Selector} columns DataTables columns selector (array of indexes / string / function ...)
 * @return {Object} Custom CSV Export button options
 */
 function csvExportBtn(columns = "") {
  return {
    extend: 'csv',
    text: '<span class="icon-download"></span> CSV',
    className: 'btn-xs white',
    exportOptions: {
      orthogonal: 'filter',
      columns: columns
    }
  }
}

/**
 * DataTable Export Excel button definition
 * @param {Selector} columns DataTables columns selector (array of indexes / string / function ...)
 * @return {Object} Custom Excel Export button options
 */
 function excelExportBtn(columns = "") {
  return {
    extend: 'excel',
    text: '<span class="icon-download"></span> Excel',
    className: 'btn-xs white',
    exportOptions: {
      orthogonal: 'filter',
      columns: columns
    }
  }
}

/**
 * DataTable Select All button definition
 * @param {function} action Custom action to execute on button click, optional
 * @param {boject} filter Custom filter to apply to DT rows scope, optional, defaults to search: applied
 * @return {Object} Custom Select All button options
 */
 function selectAllBtn(action, filter = { search: 'applied' }) {
  return {
    text: 'Select All',
    className: 'btn-xs white',
    action: action ? action : (e, dt, node, conf) => dt.rows({ selected: false, ...filter }).select()
  }
}

/**
 * DataTable Select All button definition
 * @param {function} action Custom action to execute on button click, optional
 * @param {boject} filter Custom filter to apply to DT rows scope, optional, defaults to search: applied
 * @return {Object} Custom Select All button options
 */
 function deselectAllBtn(action, filter = { search: 'applied' }) {
  return {
    text: 'Deselect All',
    className: 'btn-xs white',
    action: action ? action : (e, dt, node, conf) => dt.rows({ selected: true, ...filter }).deselect()
  }
}

/**
 * DataTable Custom button definition
 * @param {string} text Custom button text
 * @param {function} action Custom action to execute on button click
 * @param {string} cssClasses Custom button css class list, optional
 * @return {Object} Custom Select All button options
 */
 function customBtn({ text, action, cssClasses = 'btn-xs white' }) {
  return {
    text,
    className: cssClasses,
    action
  }
}

export {
  setOnErrorHandler,
  expandColumn,
  fitColumn,
  hasColumn,
  jumpToRow,
  highlightRow,
  csvExportBtn,
  excelExportBtn,
  selectAllBtn,
  deselectAllBtn,
  customBtn
}
