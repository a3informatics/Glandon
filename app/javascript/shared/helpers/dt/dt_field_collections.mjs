import { compareRefItems } from 'shared/helpers/utils'

/**
 * Editable Field definitions for a Code List Editor table
 * @return {Array} DataTables Code List Edit column definitions collection
 */
function dtCLEditFields() {
  return [
    { name: 'notation', type: 'textarea' },
    { name: 'preferred_term', type: 'textarea' },
    { name: 'synonym', type: 'textarea' },
    { name: 'definition', type: 'textarea' }
  ]
}

/**
 * Editable Field definitions for a Biomedical Concept Editor table
 * @return {Array} DataTables Biomedical Concept Edit column definitions collection
 */
function dtBCEditFields() {
  return [
    { name: 'enabled', type: 'boolean' },
    { name: 'collect', type: 'boolean' },
    { name: 'question_text', data: 'has_complex_datatype.has_property.question_text', type: 'textarea' },
    { name: 'prompt_text', data: 'has_complex_datatype.has_property.prompt_text',  type: 'textarea' },
    { name: 'format', data: 'has_complex_datatype.has_property.format',  type: 'textarea' },
    { name: 'has_coded_value', data: 'has_complex_datatype.has_property.has_coded_value', type: 'picker',
      pickerName: 'termPicker', compare: compareRefItems }
  ]
}

/**
 * Editable Field definitions for a SDTMSD Editor table
 * Field of type 'select' must have options specified 
 * @return {Array} DataTables SDTM SD Edit column definitions collection
 */
function dtSDTMSDEditFields() {
  return [
    { name: 'used', type: 'boolean' },
    { name: 'name', type: 'textarea' },
    { name: 'label', type: 'textarea' },
    _selectField({ name: 'typed_as' }),     
    { name: 'format', type: 'textarea' },
    { name: 'ct_reference', type: 'picker', pickerName: 'refPicker', compare: compareRefItems },
    _selectField({ name: 'classified_as' }),     
    { name: 'description', type: 'textarea' },
    _selectField({ name: 'compliance' }),  
  ]
}


/** Helpers **/


/**
 * Definition object for a Select field 
 * If no options to select from provided, they can be added during runtime via field's update method 
 * @return {object} DataTables Select field definition
 */
function _selectField({
  name, 
  placeholder = 'Select option', 
  labelProp = 'label', 
  valueProp = 'id',
  options = []
}) {
  return { 
    name, placeholder, options, 
    type: 'select',
    data: `${ name }.${ valueProp }`,
    optionsPair: { 
      label: labelProp, 
      value: valueProp 
    }
  }
}

export {
  dtCLEditFields,
  dtBCEditFields,
  dtSDTMSDEditFields
}
