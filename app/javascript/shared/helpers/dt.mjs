/**
 * Removes the "fit" class from a DataTable column header
 * @param {string} name Text which the target column header contains
 * @param {string} tableId Unique table selector
 */
function expandColumn(name, tableId) {
  $(`${tableId} th:contains('${name}')`).removeClass("fit");
};

/**
 * Adds the "fit" class to a DataTable column header
 * @param {string} name Text which the target column header contains
 * @param {string} tableId Unique table selector
 */
function fitColumn(name, tableId) {
  $(`${tableId} th:contains('${name}')`).addClass("fit");
};

export{ 
  expandColumn,
  fitColumn
}
