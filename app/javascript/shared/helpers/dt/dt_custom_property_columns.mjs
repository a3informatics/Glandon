import { dtTrueFalseColumn } from 'shared/helpers/dt/dt_columns'

/**
 * Get a column definition function representing the given datatype
 * @param {string} datatype Name of datatype to get the column definition for (allowed: string, integer, float, boolean)
 * @return {function} Column definition function
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
    data: name,
    className: 'custom-prop-column',
    defaultContent: 'N/A',
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

  return dtTrueFalseColumn( name, {
    className: 'text-center custom-prop-column',
    defaultContent: 'N/A',
    ...props
  });

}

export {
  dtTextColumn,
  dtBooleanColumn,
  columnByDataType
}
