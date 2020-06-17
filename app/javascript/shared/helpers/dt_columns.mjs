import { renderHistoryBtn } from 'shared/ui/buttons';

/**
 * Returns column definition for the history column
 * @return {object} DataTables history column definition
 */
function dtHistoryColumn() {
  return {
    render: (data, type, r, m) => renderHistoryBtn(r.history_path)
  }
};

/**
 * Returns column definition for the last change date column
 * @return {object} DataTables last change date column definition
 */
function dtLastChangeDateColumn() {
  return {
    render(data, type, r, m) {
      const date = new Date(r.last_change_date);
      return type === "display" ? dateTimeHTML(date) : date.getTime()
    }
  }
};

/**
 * Returns column definition for the indicators column
 * @return {object} DataTables indicators column definition
 */
function dtIndicatorsColumn() {
  return {
    data: "indicators",
    width: "90px",
    render: (data, type, r, m) => type === "display" ? formatIndicators(data) : formatIndicatorsString(data)
  }
};

/**
 * Returns column definition for the context menu column
 * @param {function} renderer function, that will render the HTML for the context menu from row data
 * @return {object} DataTables context menu column definition
 */
function dtContextMenuColumn(renderer) {
  return {
    className: "text-right",
    render: (data, type, r, m) => type === "display" ? renderer(r, m.row) : ""
  }
};

export {
  dtHistoryColumn,
  dtIndicatorsColumn,
  dtLastChangeDateColumn,
  dtContextMenuColumn
}
