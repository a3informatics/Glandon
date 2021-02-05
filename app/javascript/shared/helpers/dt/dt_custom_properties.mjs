import { dtTrueFalseColumn, dtInlineEditColumn, dtTrueFalseEditColumn } from 'shared/helpers/dt/dt_columns'


/*** Columns ***/


/**
 * Get a DT column definition function representing the given datatype
 * @param {string} datatype Name of datatype to get the column definition for (allowed: string, integer, float, boolean)
 * @return {function} DT Column definition function
 */
function columnByDataType(datatype) {

  switch( datatype ) {

    case 'string':
    case 'integer':
    case 'float':
      return dtTextColumn;
      break;

    case 'boolean':
      return dtBooleanColumn;
      break;

  }
}

/**
 * DT Column definition for any text and number value column
 * @param {string} name Data property name of the column
 * @param {object} props extra column properties, optional
 * @return {object} Text & number DT column definition
 */
function dtTextColumn(name, props = {}) {

  return {
    data: getName( name ),
    className: 'custom-property',
    defaultContent: '',
    ...props,
  }

}

/**
 * DT Column definition for a boolean value column
 * @param {string} name Data property name of the column
 * @param {object} props extra column properties, optional
 * @return {object} Boolean DT column definition
 */
function dtBooleanColumn(name, props = {}) {

  return dtTrueFalseColumn( getName( name ), {
    className: 'text-center custom-property',
    defaultContent: '',
    ...props
  });

}

/*** Editor Columns ***/


/**
 * Get a DT Edit column definition function representing the given datatype
 * @param {string} datatype Name of datatype to get the column definition for (allowed: string, integer, float, boolean)
 * @return {function} DT Editor Column definition function
 */
function eColumnByDataType(datatype) {

  switch( datatype ) {

    case 'string':
    case 'integer':
    case 'float':
      return (name, props) => dtInlineEditColumn( getName( name ), {
        className: 'editable inline custom-property',
        editField: name,
        ...props
      });
      break;

    case 'boolean':
      return (name, props) => dtTrueFalseEditColumn( getName( name ), {
        className: 'editable inline custom-property text-center',
        editField: name,
        ...props
      });
      break;

  }
}


/*** Fields ***/


/**
 * Get a DT field definition function representing the given datatype
 * @param {string} datatype Name of datatype to get the column definition for (allowed: string, integer, float, boolean)
 * @return {function} DT Field definition function
 */
function fieldByDataType(datatype) {

  switch( datatype ) {

    case 'string':
    case 'integer':
    case 'float':
      return (name, props) => dtField( 'textarea', name, props );
      break;

    case 'boolean':
      return (name, props) => dtField( 'boolean', name, props );
      break;

  }

}

/**
 * DT Field definition object
 * @param {string} type Field property type
 * @param {string} name Data property name of the field
 * @param {object} props extra field properties, optional
 * @return {object} DT field definition
 */
function dtField(type, name, props = {}) {

  return {
    type, name,
    data: getName( name ),
    ...props
  }

}

/**
 * Get data property name with prefix
 * @param {string} name Data property name of the field
 * @return {string} Custom Property data property name
 */
function getName(name) {
  return `custom_properties.${ name }.value`;
}

export {
  dtTextColumn,
  dtBooleanColumn,
  columnByDataType,
  fieldByDataType,
  eColumnByDataType
}
