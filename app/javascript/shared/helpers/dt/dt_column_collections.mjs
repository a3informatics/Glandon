import { itemReferences } from 'shared/ui/collections'

import { dtButtonColumn, dtInlineEditColumn, dtIndicatorsColumn, dtTagsColumn, dtBooleanColumn,
         dtItemTypeColumn, dtVersionColumn, dtBooleanEditColumn, dtPickerEditColumn, dtSelectEditColumn, dtRowRemoveColumn } 
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
  ]

}

/**
 * Column definitions for a Code List Index panel
 * @return {Array} DataTables Code List Index panel column definitions collection
 */
function dtCLIndexColumns() {
  
  const indexColumns = [...dtIndexColumns()]
  indexColumns.splice( 3, 0, { data: "notation" } )

  return indexColumns

}


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
  ]
  
}


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
  ]

}


/*** Iso Managed ***/


/**
 * Column definitions for a Managed Items panel
 * @param {object} opts Additional column options
 * @param {boolean} typeColumn Set to true to inlcude type icon column 
 * @param {boolean} ownerColumn Set to true to inlcude owner column
 * @return {Array} DataTables Managed Items panel column definitions collection
 */
function dtManagedItemsColumns(opts = {}, typeColumn = false, ownerColumn = false) {
  
  const columns = [
    { ...opts, render: (dt, t, r) => r.version || r.semantic_version },
    { data: 'identifier', ...opts },
    { data: 'label', ...opts },
    { data: 'version_label', ...opts }
  ]

  if ( ownerColumn )
    columns.splice( 0, 0, { data: 'owner', ...opts })

  if ( typeColumn )
    columns.splice( 0, 0, dtItemTypeColumn() )

  return columns 

}


/*** Show ***/


/**
 * Column definitions for Biomedical Concept Instance show
 * @return {Array} DataTables Biomedical Concept Instance show column definitions collection
 */
function dtBCShowColumns() {

  return [
    dtBooleanColumn("enabled"),
    dtBooleanColumn("collect"),
    { data: "has_complex_datatype.has_property.alias" },
    { data: "has_complex_datatype.has_property.question_text" },
    { data: "has_complex_datatype.has_property.prompt_text" },
    { data: "has_complex_datatype.label" },
    { data: "has_complex_datatype.has_property.format" },
    {
      data: "has_complex_datatype.has_property.has_coded_value",
      width: "30%",
      render: (data, type, r, m) => itemReferences(data, type)
    }
  ]

}

/**
 * Column definitions for Form show
 * @return {Array} DataTables Form show column definitions collection
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
      render: (data, type, r, m) => itemReferences(data, type)
    }
  ]

}

/**
 * Column definitions for generic SDTM show (shared SDTM IG, SDTM Model)
 * @return {Array} DataTables SDTM show column definitions collection
 */
function dtSDTMShowColumns() {

  return [
    { data: "has_identifier.identifier" },
    { data: "label" },
    { data: "has_identifier.has_scope.short_name" },
    { data: "has_identifier.version" },
    { data: "has_identifier.version_label" },
    dtButtonColumn('show')
  ]

}

/**
 * Column definitions for SDTM Class show
 * @return {Array} DataTables SDTM Class show column definitions collection
 */
function dtSDTMClassShowColumns() {

  return [
    { data: "ordinal" },
    { data: "name" },
    { data: "label" },
    { data: "typed_as" },
    { data: "description" },
    { data: "classified_as" }
  ]

}

/**
 * Column definitions for SDTM IG Domain show
 * @return {Array} DataTables SDTM IG Domain show column definitions collection
 */
function dtSDTMIGDomainShowColumns() {

  return [
    { data: "ordinal" },
    { data: "name" },
    { data: "label" },
    { data: "typed_as.label" },
    { data: "format" },
    { data: "ct_and_format" },
    {
      data: "ct_reference",
      width: 150,
      render: (data, type, r, m) => itemReferences(data, type)
    },
    { data: "classified_as.label" },
    { data: "description" },
    { data: "compliance.label" }
  ]

}

/**
 * Column definitions for SDTM SD Domain show
 * @return {Array} DataTables SDTM SD Domain show column definitions collection
 */
function dtSDTMSDDomainShowColumns() {

  return [
    { data: "ordinal" },
    { data: "name" },
    { data: "label" },
    { data: "typed_as.label" },
    { data: "format" },
    { data: "ct_and_format" },
    {
      data: "ct_reference",
      width: 150,
      render: (data, type, r, m) => itemReferences(data, type)
    },
    { data: "classified_as.label" },
    { data: "description" },
    { data: "comment" },
    { data: "compliance.label" },
    { data: "method" }
  ]

}

/**
 * Column definitions for ADaM IG show (identical to SDTM Show columns)
 * @return {Array} DataTables ADaM IG show column definitions collection
 */
function dtADaMIGShowColumns() {
  return dtSDTMShowColumns()
}

/**
 * Column definitions for ADaM IG Dataset show
 * @return {Array} DataTables ADaM IG Dataset show column definitions collection
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
  ]

}


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
  ]

}

/**
 * Column definitions for Biomedical Concept Instance show
 * @return {Array} DataTables Biomedical Concept Instance show column definitions collection
 */
function dtBCEditColumns() {

  return [
    dtBooleanEditColumn('enabled'),
    dtBooleanEditColumn('collect'),

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

    dtPickerEditColumn('has_complex_datatype.has_property.has_coded_value', {
      pickerName: 'refPicker',
      newTab: true,
      opts: {
        width: '30%',
        editField: 'has_coded_value'
      }
    })
  ]

}

/**
 * Column definitions for SDTM SD Domain edit
 * @return {Array} DataTables SDTM SD Domain edit column definitions collection
 */
function dtSDTMSDDomainEditColumns() {

  return [
    { data: "ordinal" },
    dtBooleanEditColumn( 'used' ),
    dtInlineEditColumn( 'name' ),
    dtInlineEditColumn( 'label' ),
    dtSelectEditColumn( 'typed_as' ),
    dtInlineEditColumn( 'format' ),

    dtPickerEditColumn('ct_reference', {
      pickerName: 'refPicker',
      newTab: true,
      opts: {
        width: 200,
      }
    }),

    dtSelectEditColumn( 'classified_as' ),
    dtInlineEditColumn( 'description' ),
    dtInlineEditColumn( 'comment' ),
    dtSelectEditColumn( 'compliance' ),
    dtInlineEditColumn( 'method' )
  ]

}

export {
  // Index, history columns
  dtIndexColumns,
  dtSimpleHistoryColumns,
  dtCLIndexColumns,
  dtChildrenColumns,
  dtManagedItemsColumns,
  
  // Show columns
  dtFormShowColumns,
  dtSDTMShowColumns,
  dtSDTMClassShowColumns,
  dtSDTMIGDomainShowColumns,
  dtSDTMSDDomainShowColumns,
  dtADaMIGDatasetShowColumns,
  dtADaMIGShowColumns,

   // Edit columns
   dtCLEditColumns,
   dtBCShowColumns,
   dtBCEditColumns,
   dtSDTMSDDomainEditColumns,
}
