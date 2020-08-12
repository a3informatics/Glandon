import { dtInlineEditColumn, dtIndicatorsColumn, dtTagsColumn, dtTrueFalseColumn } from 'shared/helpers/dt/dt_columns'
import { iconsInline } from 'shared/ui/icons'
import { termReferences } from 'shared/ui/collections'
import { showBtn } from 'shared/ui/buttons'


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

/**
 * Column definitions for SDTM Class show
 * @return {Array} DataTables  SDTM Class show column definitions collection
 */
function dtSDTMClassShowColumns() {
  return [
    { data: "ordinal" },
    { data: "name" },
    { data: "label" },
    { data: "typed_as" },
    { data: "description" },
    { data: "classified_as" },
    { data: "classified_as" }
  ];
};

/**
 * Column definitions for SDTM Model and IG show
 * @return {Array} DataTables  SDTM Model and IG show column definitions collection
 */
function dtSDTMShowColumns() {
  return [
    { data: "has_identifier.identifier" },
    { data: "label" },
    { data: "has_identifier.has_scope.short_name" },
    { data: "has_identifier.version" },
    { data: "has_identifier.version_label" },
    {
      data: "show_path",
      render: (data, type, r, m) => showBtn(data)
    }
  ];
};

/**
 * Column definitions for SDTM IG Domain show
 * @return {Array} DataTables  SDTM IG Domain show column definitions collection
 */
function dtSDTMIGDomainShowColumns() {
  return [
    { data: "ordinal" },
    { data: "name" },
    { data: "label" },
    { data: "datatype_label" },
    { data: "format" },
    { data: "classification_label" },
    { data: "sub_classification_label" }
    { data: "notes" }
    { data: "compliance_label" }
  ];
};

export { dtCLEditColumns, dtBCShowColumns, dtFormShowColumns, dtSDTMClassShowColumns, dtSDTMShowColumns, dtSDTMIGDomainShowColumns  }
