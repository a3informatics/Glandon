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
  ];
};

/**
 * Editable Field definitions for a Biomedical Concept Editor table
 * @return {Array} DataTables Biomedical Concept Edit column definitions collection
 */
function dtBCEditFields() {
  return [
    { name: 'enabled', type: 'truefalse' },
    { name: 'collect', type: 'truefalse' },
    { name: 'question_text', data: 'has_complex_datatype.has_property.question_text', type: 'textarea' },
    { name: 'prompt_text', data: 'has_complex_datatype.has_property.prompt_text',  type: 'textarea' },
    { name: 'format', data: 'has_complex_datatype.has_property.format',  type: 'textarea' },
    { name: 'has_coded_value', data: 'has_complex_datatype.has_property.has_coded_value', type: 'picker',
      pickerName: 'termPicker', compare: compareRefItems }
  ];
};

export {
  dtCLEditFields,
  dtBCEditFields
}