import { historyBtn } from 'shared/ui/buttons'
import { checkMarkIcon } from 'shared/ui/icons'
import { renderIndicators } from 'shared/ui/indicators'

/**
 * Returns column definition for the history column
 * @return {object} DataTables history column definition
 */
function dtHistoryColumn() {
  return {
    render: (data, type, r, m) => historyBtn(r.history_path)
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
 * Returns column definition for the tags column
 * @param {string} width Column width string, optional
 * @param {string} className Custom classname, optional
 * @return {object} DataTables indicators column definition
 */
function dtTagsColumn(width = '', className = '') {
  return {
    data: "tags",
    className,
    width: width,
    render: (data, type, r, m) => type === "display" ? colorCodeTagsBadge(data) : data
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
    render: (data, type, r, m) => renderIndicators(data, type)
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

/**
 * Returns column definition for a true/false icon column
 * @param {string} name data property name
 * @return {object} DataTables true/false icon column definition
 */
function dtTrueFalseColumn(name) {
  return {
    className: "text-center",
    data: name,
    render: (data, type, r, m) => type === "display" ? checkMarkIcon(data) : data
  }
};

/**
 * Returns column definition for a generic inline editable column
 * @param {string} field editField name
 * @param {string} name data property name
 * @param {string} width width of column in %
 * @return {object} DataTables inline editable column definition
 */
function dtInlineEditColumn(field, name, width) {
  return {
    className: "editable inline",
    data: name,
    editField: field,
    width: width
  }
};

export {
  dtHistoryColumn,
  dtIndicatorsColumn,
  dtTagsColumn,
  dtLastChangeDateColumn,
  dtContextMenuColumn,
  dtInlineEditColumn,
  dtTrueFalseColumn
}
