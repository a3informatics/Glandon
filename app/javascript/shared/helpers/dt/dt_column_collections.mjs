import { dtInlineEditColumn, dtIndicatorsColumn, dtTagsColumn, dtTrueFalseColumn, dtVersionColumn } from 'shared/helpers/dt/dt_columns'
import { iconsInline } from 'shared/ui/icons'
import { termReferences } from 'shared/ui/collections'

/**
 * Column definitions for an Index panel
 * @return {Array} DataTables Index panel column definitions collection
 */
function dtIndexColumns() {
  return [
    {data : "owner"},
    {data : "identifier"},
    {data : "label"}
  ];
};

/**
 * Column definitions for a simplified History panel with indicators
 * @return {Array} DataTables simplified History panel column definitions collection
 */
function dtSimpleHistoryColumns() {
  return [
    dtVersionColumn(),
    { data: "has_identifier.version_label" },
    { data: "has_state.registration_status" },
    dtIndicatorsColumn()
  ];
};

/**
 * Column definitions for a Code List Editor table
 * @return {Array} DataTables Code List Edit column definitions collection
 */
function dtCLEditColumns() {
  return [
    { data: "identifier" },
    dtInlineEditColumn("notation", "notation", "16%"),
    dtInlineEditColumn("preferred_term", "preferred_term", "18%"),
    dtInlineEditColumn("synonym", "synonym", "18%"),
    dtInlineEditColumn("definition", "definition", "40%"),
    dtTagsColumn("8%", 'editable edit-tags'),
    dtIndicatorsColumn(),
    {
      className: "fit",
      render: (data, type, r, m) => {
        // const editingDisabled = _.isEmpty(r.edit_path);
        // iconsInline.editIcon({ disabled: editingDisabled })
        const actionIcons = iconsInline.removeIcon({ ttip: true, ttipText: "Remove / unlink item" });

        return type === 'display' ? actionIcons : '';
      }
    }
  ];
};

/**
 * Column definitions for Biomedical Concept Instance show
 * @return {Array} DataTables  Biomedical Concept Instance show column definitions collection
 */
function dtBCShowColumns() {
  return [
    dtTrueFalseColumn("enabled"),
    dtTrueFalseColumn("collect"),
    { data: "has_complex_datatype.has_property.label" },
    { data: "has_complex_datatype.has_property.question_text" },
    { data: "has_complex_datatype.has_property.prompt_text" },
    { data: "has_complex_datatype.label" },
    { data: "has_complex_datatype.has_property.format" },
    {
      data: "has_complex_datatype.has_property.has_coded_value",
      width: "30%",
      render: (data, type, r, m) => termReferences(data, type)
    }
  ];
};

/**
 * Column definitions for Form show
 * @return {Array} DataTables  Form show column definitions collection
 */
function dtFormShowColumns() {
  return [
    { data: "order_index" },
    { data: "ordinal" },
    { data: "label" },
    { render: (data, type, r, m) => r.question_text || r.free_text },
    { data: "datatype" },
    { data: "format" },
    { data: "mapping" },
    { data: "completion" },
    { data: "note" },
    {
      data: "has_coded_value",
      width: "30%",
      render: (data, type, r, m) => termReferences(data, type)
    }
  ];
};

export {
  dtIndexColumns,
  dtSimpleHistoryColumns,
  dtCLEditColumns,
  dtBCShowColumns,
  dtFormShowColumns
}
