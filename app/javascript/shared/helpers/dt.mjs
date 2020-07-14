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

export{ 
  expandColumn,
  fitColumn
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

export {
  csvExportBtn,
  excelExportBtn,
  expandColumn,
  fitColumn
}
