import { iconsInline } from 'shared/ui/icons'
import { termReferences } from 'shared/ui/collections'

import { dtButtonColumn, dtInlineEditColumn, dtIndicatorsColumn, dtTagsColumn, dtTrueFalseColumn,
         dtVersionColumn, dtTrueFalseEditColumn, dtExternalEditColumn } from 'shared/helpers/dt/dt_columns'


/*** Index ***/


/**
 * Column definitions for an Index panel
 * @return {Array} DataTables Index panel column definitions collection
 */
function dtIndexColumns() {
  return [
    { data : "owner" },
    { data : "identifier" },
    { data : "label" },
    dtIndicatorsColumn()
  ];
};

/**
 * Column definitions for a Code List Index panel
 * @return {Array} DataTables Code List Index panel column definitions collection
 */
function dtCLIndexColumns() {
  const indexColumns = [...dtIndexColumns()];
  indexColumns.splice( 3, 0, { data: "notation" } );

  return indexColumns;
};


/*** History ***/


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


/*** Children ***/


/**
 * Column definitions for a Children panel
 * @return {Array} DataTables Children panel column definitions collection
 */
function dtChildrenColumns() {
  return [
    { data: 'identifier' },
    { data: 'notation' },
    { data: 'preferred_term' },
    { data: 'synonym' },
    {
      width: '50%',
      data: 'definition'
    },
    dtTagsColumn()
  ];
};


/*** Edit ***/


/**
 * Column definitions for a Code List Editor table
 * @return {Array} DataTables Code List Edit column definitions collection
 */
function dtCLEditColumns() {
  return [
    { data: 'identifier' },
    dtInlineEditColumn('notation', '', '16%'),
    dtInlineEditColumn('preferred_term', '', '18%'),
    dtInlineEditColumn('synonym', '', '18%'),
    dtInlineEditColumn('definition', '', '40%'),
    dtTagsColumn('8%', 'editable external edit-tags'),
    dtIndicatorsColumn(),
    {
      className: 'fit',
      render: (data, type, r, m) => {
        // const editingDisabled = _.isEmpty(r.edit_path);
        // iconsInline.editIcon({ disabled: editingDisabled })
        const actionIcons = iconsInline.removeIcon({ ttip: true, ttipText: 'Remove / unlink item' });

        return type === 'display' ? actionIcons : '';
      }
    }
  ];
};

/**
 * Column definitions for Biomedical Concept Instance show
 * @return {Array} DataTables Biomedical Concept Instance show column definitions collection
 */
function dtBCEditColumns() {
  return [
    dtTrueFalseEditColumn('enabled'),
    dtTrueFalseEditColumn('collect'),
    {
      data: 'has_complex_datatype.has_property.alias',
      width: '18%'
    },
    dtInlineEditColumn('has_complex_datatype.has_property.question_text', 'question_text', '25%'),
    dtInlineEditColumn('has_complex_datatype.has_property.prompt_text', 'prompt_text', '25%'),
    { data: "has_complex_datatype.label" },
    dtInlineEditColumn('has_complex_datatype.has_property.format', 'format'),

    // Items Picker column
    {
      className: 'editable inline pickable termPicker',
      data: 'has_complex_datatype.has_property.has_coded_value',
      width: '30%',
      editField: 'has_coded_value',
      render: (data, type, r, m) => termReferences(data, type, true)
    }
  ];
};


/*** Show ***/


/**
 * Column definitions for Biomedical Concept Instance show
 * @return {Array} DataTables  Biomedical Concept Instance show column definitions collection
 */
function dtBCShowColumns() {
  return [
    dtTrueFalseColumn("enabled"),
    dtTrueFalseColumn("collect"),
    { data: "has_complex_datatype.has_property.alias" },
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
    { data: "sub_classified_as" }
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
    dtButtonColumn('show')
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
    { data: "typed_as" },
    { data: "format" },
    { data: "classified_as" },
    { data: "sub_classified_as" },
    { data: "description" },
    { data: "compliance" }
  ];
};

/**
 * Column definitions for ADaM IG Dataset show
 * @return {Array} DataTables  ADaM IG Dataset show column definitions collection
 */
function dtADaMIGDatasetShowColumns() {
  return [
    { data: "ordinal" },
    { data: "name" },
    { data: "label" },
    { data: "typed_as" }, //datatype_label
    { data: "ct" },
    { data: "notes" },
    { data: "compliance" }
  ];
};

export {
  dtIndexColumns,
  dtSimpleHistoryColumns,
  dtCLIndexColumns,
  dtChildrenColumns,
  dtCLEditColumns,
  dtBCShowColumns,
  dtBCEditColumns,
  dtFormShowColumns,
  dtSDTMClassShowColumns,
  dtSDTMShowColumns,
  dtSDTMIGDomainShowColumns,
  dtADaMIGDatasetShowColumns
}
