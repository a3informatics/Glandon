import { historyBtn, showBtn } from 'shared/ui/buttons'
import { icons } from 'shared/ui/icons'
import { renderIndicators } from 'shared/ui/indicators'
import { renderTagsInline } from 'shared/ui/tags'

/**
 * Returns column definition for the history column
 * @param {string} name name of the button (options: history, show)
 * @return {object} DataTables history column definition
 */
function dtButtonColumn(name) {
  return {
    orderable: false,
    className: 'text-right',
    render: (data, type, r, m) => {
      switch (name) {
        case 'show':
          return showBtn(r.show_path);
          break;
        case 'history':
          return historyBtn(r.history_path);
          break;
      }
    }
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
 * Returns column definition for item version / semantic version column
 * @return {object} DataTables item version column definition
 */
function dtVersionColumn() {
  return {
    render: (data, type, r, m) => type === "display" ? r.has_identifier.semantic_version : r.has_identifier.version
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
    render: (data, type, r, m) => type === "display" ? renderTagsInline(data) : data
  }
};

/**
 * Returns column definition for the indicators column
 * @return {object} DataTables indicators column definition
 */
function dtIndicatorsColumn() {
  return {
    data: "indicators",
    // width: "90px",
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
    render: (data, type, r, m) => type === "display" ? icons.checkMarkIcon(data) : data
  }
};

/**
 * Returns column definition for a true/false editable column
 * @param {string} field editField name
 * @param {string} name data property name
 * @return {object} DataTables true/false editable column definition
 */
function dtTrueFalseEditColumn(field, name) {
  let inlineEditColumn = dtInlineEditColumn(field, name);

  inlineEditColumn.className += " text-center"
  inlineEditColumn.render = dtTrueFalseColumn().render

  return inlineEditColumn;
};

/**
 * Returns column definition for a generic inline editable column
 * @param {string} field editField name
 * @param {string} name data property name
 * @param {string} width width of column in %
 * @return {object} DataTables inline editable column definition
 */
function dtInlineEditColumn(name, field, width) {
  return {
    className: "editable inline",
    data: name,
    editField: (field || name),
    width: width
  }
};

/**
 * Returns column definition for an externally editable column
 * @param {string} field editField name
 * @param {string} name data property name
 * @param {string} width width of column in %
 * @return {object} DataTables externally editable column definition
 */
function dtExternalEditColumn(name, field, width) {
  let definition = dtInlineEditColumn(name, field, width);
  definition.className = "editable external"

  return definition;
};

export {
  dtButtonColumn,
  dtIndicatorsColumn,
  dtTagsColumn,
  dtLastChangeDateColumn,
  dtVersionColumn,
  dtContextMenuColumn,
  dtTrueFalseColumn,
  // Editable columns
  dtTrueFalseEditColumn,
  dtInlineEditColumn,
  dtExternalEditColumn
}
