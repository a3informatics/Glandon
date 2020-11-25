import { dtTrueFalseColumn, dtInlineEditColumn, dtTrueFalseEditColumn } from 'shared/helpers/dt/dt_columns'
import { dtFieldsInit } from 'shared/helpers/dt/dt_fields'


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
    className: 'custom-prop-column',
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
    className: 'text-center custom-prop-column',
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
        className: 'editable inline',
        ...props
      });
      break;

    case 'boolean':
      return (name, props) => dtTrueFalseEditColumn( getName( name ), {
        className: 'editable inline text-center',
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
      return (name, props) => dtField( 'textarea', getName( name ), props );
      break;

    case 'boolean':
      return (name, props) => dtField( 'truefalse', getName( name ), props );
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
    name, type,
    ...props
  }

}

/**
 * Get data property name with prefix
 * @param {string} name Data property name of the field
 * @return {string} Custom Property data property name 
 */
function getName(name) {
  return `customProps.${ name }`;
}

export {
  dtTextColumn,
  dtBooleanColumn,
  columnByDataType,
  fieldByDataType,
  eColumnByDataType
}
