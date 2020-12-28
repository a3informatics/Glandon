import { iconsInLine } from 'shared/ui/icons'
import { termReferences } from 'shared/ui/collections'

import { dtButtonColumn, dtInlineEditColumn, dtIndicatorsColumn, dtTagsColumn, dtTrueFalseColumn,
         dtItemTypeColumn, dtVersionColumn, dtTrueFalseEditColumn, dtExternalEditColumn, dtSelectEditColumn, dtRowRemoveColumn } 
  from 'shared/helpers/dt/dt_columns'


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
 * @param {object} opts Additional column options
 * @return {Array} DataTables Children panel column definitions collection
 */
function dtChildrenColumns(opts = {}) {
  return [
    { data: 'identifier', ...opts },
    { data: 'notation', ...opts },
    { data: 'preferred_term', ...opts },
    { data: 'synonym', ...opts },
    { data: 'definition', ...opts },
    dtTagsColumn(opts)
  ];
};


/*** Iso Managed ***/


/**
 * Column definitions for a Managed Items panel
 * @param {object} opts Additional column options
 * @param {boolean} withIcons Set to true to inlcude type icon column as the first one
 * @return {Array} DataTables Managed Items panel column definitions collection
 */
function dtManagedItemsColumns(opts = {}, withIcons = false) {
  
  const columns = [
    { data: 'identifier', ...opts },
    { ...opts, render: (dt, t, r) => r.version || r.semantic_version },
    { data: 'label', ...opts },
    { data: 'version_label', ...opts } 
  ];

  if ( withIcons )
    columns.splice( 0, 0, dtItemTypeColumn() );
  
  return columns; 

};


/*** Edit ***/


/**
 * Column definitions for a Code List Editor table
 * @return {Array} DataTables Code List Edit column definitions collection
 */
function dtCLEditColumns() {
  return [
    { data: 'identifier' },
    dtInlineEditColumn('notation', {
      width: '16%'
    }),
    dtInlineEditColumn('preferred_term', {
      width: '18%'
    }),
    dtInlineEditColumn('synonym', { width: '18%' }),
    dtInlineEditColumn('definition', {
      width: '40%'
    }),
    dtTagsColumn({
      width: '8%',
      className: 'editable external edit-tags'
    }),
    dtIndicatorsColumn(),
    // Remove / unlink button
    dtRowRemoveColumn( 'Remove/unlink item' )
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

    dtInlineEditColumn('has_complex_datatype.has_property.question_text', {
      editField: 'question_text',
      width: '25%'
    }),

    dtInlineEditColumn('has_complex_datatype.has_property.prompt_text', {
      editField: 'prompt_text',
      width: '25%'
    }),
    { data: "has_complex_datatype.label" },

    dtInlineEditColumn('has_complex_datatype.has_property.format', {
      editField: 'format'
    }),

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

/**
 * Column definitions for SDTM IG Domain edit
 * @return {Array} DataTables SDTM IG Domain edit column definitions collection
 */
function dtSDTMIGDomainEditColumns() {

  return [
    { data: "ordinal" },
    dtTrueFalseEditColumn( 'used' ),
    dtInlineEditColumn( 'name' ),
    dtInlineEditColumn( 'label' ),
    dtSelectEditColumn( 'typed_as' ),
    dtInlineEditColumn( 'format' ),
    dtSelectEditColumn( 'classified_as' ),
    dtInlineEditColumn( 'description' ),
    dtSelectEditColumn( 'compliance' )
  ]

}


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
    { data: "typed_as.label" },
    { data: "format" },
    { data: "classified_as.label" },
    { data: "description" },
    { data: "compliance.label" }
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
  dtManagedItemsColumns,
  dtCLEditColumns,
  dtBCShowColumns,
  dtBCEditColumns,
  dtFormShowColumns,
  dtSDTMClassShowColumns,
  dtSDTMIGDomainEditColumns,
  dtSDTMShowColumns,
  dtSDTMIGDomainShowColumns,
  dtADaMIGDatasetShowColumns
}
