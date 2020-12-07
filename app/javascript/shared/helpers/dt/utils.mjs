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
  csvExportBtn,
  excelExportBtn,
  selectAllBtn,
  deselectAllBtn,
  customBtn
}
