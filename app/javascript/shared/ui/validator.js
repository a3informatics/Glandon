/**
 * Form Inputs Validator
 * @description Allows validation of form fields with error handling
 * @author Samuel Banas <sab@s-cubed.dk>
 * @static
 */

 /**
  * Rules format
  * Object containing the input *name* of each field as its keys
  * and the values are each an object, which contains the the *attribute* to validate as the key
  * and the value is the rule itself (rule must be included in the map below, @see Validator.allRules )
  * @example: { label: { value: 'not-empty', ... }, ... }
  * @example: { code-list-reference: { data-id: 'not-empty', value: 'not-empty' } }
  */

export default class Validator {

  /**
   * Validate a form by a collection of rules
   * @param {(JQuery Element | string )} form reference to the form element to validate
   * @param {Object} rules object containing rules for all of the form fields to validate
   * @return {boolean} value representing validation success, only returns true if all checks pass
   * @static
   */
  static validate(form, rules) {

    // Clear all errors in form
    Validator._clear(form);

    let success = true;

    Validator._eachField( form, rules, ( field, fieldRules ) => {

      // Field did not pass all validation checks
      if ( !Validator.validateField( field, fieldRules ) )
        success = false;

    });

    return success;

  }

  /**
   * Validate a single field by a set of field rules
   * @param {JQuery Element} field reference to the field element to validate
   * @param {Object} fieldRules object containing rules for the respective field to validate
   * @return {boolean} value representing field validation success, only returns true if all checks pass
   * @static
   */
  static validateField(field, fieldRules) {

    let success = true;

    Validator._eachRule( fieldRules, ( attr, rule ) => {

      // Rule validation did not pass
      if( !Validator.validateFieldRule( field, attr, rule ) ) {

        // Regular error message
        if ( this.allRules[rule] )
          Validator._renderError( field, this.allRules[rule].message )

        // Error message with parameter
        else if ( this.allRules[attr] )
          Validator._renderError( field, this.allRules[attr].message.replace( 'XXX', rule ) )

        success = false;

      }

    });

    return success;

  }

  /**
   * Validate a field by one rule
   * Add more special cases when needed
   * @param {JQuery Element} field reference to the field element to validate
   * @param {string} attribute field attribute to validate (e.g. value, data-something)
   * @param {string} rule rule name in the rules map (e.g. not-empty), @see Validator.allRules
   * @return {boolean} value representing field passing the rule test
   * @static
   */
  static validateFieldRule(field, attribute, rule) {

    switch ( attribute ) {
      case 'val':
      case 'value':
        return Validator.allRules[rule]
                        .regex
                        .test( $( field ).val() );
        break;

      case 'max-length':
        return $( field ).val().length <= rule;
        break;

      default:
        return Validator.allRules[rule]
                        .regex
                        .test( $( field ).attr( attribute ) );
    }

  }


  /** Private Helpers **/


  /**
   * Iterate over a collection of fields per form, executing an action for each
   * @param {JQuery Element} form reference to the form element containing the fields
   * @param {Object} rules object containing rules for all of the form fields to validate
   * @param {function} action called for each field, passes field element and field rules as arguments
   * @static
   */
  static _eachField(form, rules, action) {

    for ( const[ fieldName, fieldRules ] of Object.entries( rules ) ) {

      let field = $( form ).find( `[name='${ fieldName }']` );

      if ( field.length )
        action( field, fieldRules );

    }

  }

  /**
   * Iterate over a collection of rules per field, executing an action for each
   * @param {Object} fieldRules object containing rules for the respective field to validate
   * @param {function} action called for each rule, passes attribute name and rule value as arguments
   * @static
   */
  static _eachRule(fieldRules, action) {

    for ( const[ attribute, rule ] of Object.entries( fieldRules ) ) {
      action( attribute, rule );
    }

  }

  /**
   * Render an error message in a field
   * @param {(JQuery Element | string)} field reference to the field element
   * @param {string} error text to add as error
   * @static
   */
  static _renderError(field, error) {

    // Remove any present field errors
    Validator._clearFieldErrors( field );

    Validator._getParent( field )
             .addClass( 'has-error' )
             .append( `<span class='help-block'>${ error }</span>` );

  }

  /**
   * Check if field contains an error message
   * @param {(JQuery Element | string)} field reference to the field element
   * @param {string} error text to check
   * @return {boolean} value representing whether field contains the specified text
   * @static
   */
  static _fieldHasError(field, error) {

    return Validator._getParent( field )
                    .text()
                    .includes( error );

  }

  /**
   * Clears any error styling and error text from a field
   * @param {(JQuery Element | string)} field reference to the field element
   * @static
   */
  static _clearFieldErrors(field) {

    Validator._getParent( field )
             .removeClass( 'has-error' )
             .find( '.help-block' )
             .remove();

  }

  /**
   * Clears any error styling and error text from a form
   * @param {(JQuery Element | string)} form reference to the form element
   * @static
   */
  static _clear(form) {
    Validator._clearFieldErrors( $( form ).find( '.has-error' ) );
  }

  /**
   * Get .form-group parent element of a form input field element
   * @param {(JQuery Element | string)} field reference to the field element
   * @return {JQuery Element} closest .form-group parent element containing the field
   * @static
   */
  static _getParent(field) {
    return $( field ).closest( '.form-group' );
  }

  /**
   * Master rules map containing rule name, error text and regex validation
   * Add more rules as needed
   * @return {Object} master validation rules map
   * @static
   */
  static get allRules() {

    return { 
      'not-empty': {
          regex: /^(?!\s*$).+/,
          message: "Field cannot be empty"
      },
      'max-length': {
        message: "String too long, max XXX characters"
      }
    }

  }
}
