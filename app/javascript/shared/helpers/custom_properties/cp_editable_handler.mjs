import CustomPropsHandler from 'shared/helpers/custom_properties/cp_handler'

import { fieldByDataType, eColumnByDataType } from 'shared/helpers/dt/dt_custom_properties'
import { dtFieldsInit } from 'shared/helpers/dt/dt_fields'

/**
 * Custom Properties Editable Handler module
 * @description Custom-property edit related functionality for an EditablePanel-based module
 * @extends CustomPropsHandler
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CustomPropsEditableHandler extends CustomPropsHandler {

  /**
   * Create a Custom Properties Editable Handler instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique Table selector (which includes the target table id denoted by #)
   * @param {boolean} params.enabled Enables or disables Custom Properties functionality [default = true]
   * @param {integer} params.afterColumn Column index to insert Custom Property columns after
   * @param {function} params.onColumnsToggle Function to execute when the CP columns are toggled, visibility boolean passed as the first argument
   */
  constructor({
    selector,
    enabled = true,
    afterColumn,
    onColumnsToggle = () => {}
  }) {

    super({
      selector, enabled, afterColumn, onColumnsToggle
    });

  }


  /*** Data ***/


  /**
   * Merge Custom Property fields with Editor fields
   * @param {Array} oFields Original DT fields
   * @return {Array} Merged fields collection
   */
  mergeFields(oFields) {

    if ( !this.hasData )
      return;

    // Map CP definitions to DT columns
    let fields = this.customProps.definitions.map( def =>
      fieldByDataType( def.datatype )( def.name )
    );

    return [ ...oFields, ...fields ];

  }


  /*** Events ***/


  /**
   * Process and render data on CP data, executed on CP data fetch
   * @param {object} result Raw data result object with definitions and data properties
   */
  _onDataLoaded(result) {

    Object.assign( this, {
      customProps: result
    });

    if ( this.customProps ) {
      let fieldsToInit = new Set();

      this.customProps.definitions.forEach(def => {
        if ( def.datatype === 'boolean' )
          fieldsToInit.add('truefalse')
      });

      dtFieldsInit( Array.from(fieldsToInit) );
    }

    super._onDataLoaded( result );

  }


  /*** Support ***/


  /**
   * Get Custom Property column definitions (mapped from CP definitions)
   * @return {Array} Custom Property DT column definitions
   */
  get _columns() {

    return this.customProps.definitions.map( def =>
      eColumnByDataType( def.datatype )( def.name )
    );

  }

}
