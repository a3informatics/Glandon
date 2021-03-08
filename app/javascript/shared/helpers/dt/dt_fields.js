import DTBooleanField from './custom_fields/boolean_field'
import DTPickerField from './custom_fields/picker_field'

/**
 * Map referencing field-types to their definitions (add more as needed)
 * These fields must be first initialized with the dtFieldsInit before use
 */
const fieldsMap = {
  'boolean': DTBooleanField,
  'picker': DTPickerField
}

/**
 * Initializes and adds custom field types to the DataTables Editor
 * @param {array} fields array of field names that reference field definitions as keys in @see fieldsMap
 */
function dtFieldsInit(fields = []) {

  const DataTable = $.fn.dataTable

  if ( !DataTable.ext.editorFields )
    DataTable.ext.editorFields = {}

  for ( const fieldName of fields ) {
    DataTable.ext.editorFields[fieldName] = fieldsMap[fieldName]()
  }
  
}

export {
  dtFieldsInit
}
