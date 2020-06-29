import { dtInlineEditColumn, dtIndicatorsColumn, dtTagsColumn, dtTrueFalseColumn } from 'shared/helpers/dt_columns'
import { editIconInline, removeIconInline } from 'shared/ui/buttons'

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
    dtTagsColumn("8%"),
    dtIndicatorsColumn(),
    {
      className: "fit",
      render: (data, type, r, m) => {
        // const editingDisabled = _.isEmpty(r.edit_path);
        // editIconInline({ disabled: editingDisabled })
        const actionIcons = removeIconInline({ ttip: true, ttipText: "Remove item" });

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
    { data: "has_complex_datatype.has_property.label" },
    { data: "has_complex_datatype.has_property.question_text" },
    { data: "has_complex_datatype.has_property.prompt_text" },
    dtTrueFalseColumn("enabled"),
    dtTrueFalseColumn("collect"),
    { data: "has_complex_datatype.label" },
    { data: "has_complex_datatype.has_property.format" },
    { data: "has_complex_datatype.has_property.has_coded_value.[].reference.identifier" }
  ];
};

export { dtCLEditColumns, dtBCShowColumns }
