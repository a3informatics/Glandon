/**
 * DataTable Export CSV button definition
 * @param {Selector} columns DataTables columns selector (array of indexes / string / function ...)
 * @return {Object} Custom CSV Export button options
 */
 function csvExportBtn(columns = "") {
  return {
    extend: 'csv',
    text: '<span class="icon-document"></span> Export CSV',
    className: 'btn-xs white',
    exportOptions: {
      orthogonal: 'filter',
      columns: columns
    }
  }
}

export {
  csvExportBtn
}
