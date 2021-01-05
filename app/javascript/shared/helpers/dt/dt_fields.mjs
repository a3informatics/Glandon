import { icons } from 'shared/ui/icons'
import { termReferences } from 'shared/ui/collections'

/**
 * Map referencing field-types to their definitions (add more as needed)
 * These fields must be first initialized with the dtFieldsInit before use
 */
const fieldsMap = {
  'truefalse': dtTrueFalseField,
  'picker': dtPickerField
}

/**
 * Initializes and adds custom field types to the DataTables Editor
 * @param {array} fields array of field names that reference field definitions as keys in @see fieldsMap
 */
function dtFieldsInit(fields = []) {
  const DataTable = $.fn.dataTable;

  if ( !DataTable.ext.editorFields )
    DataTable.ext.editorFields = {}

  for (const fieldName of fields) {
    DataTable.ext.editorFields[fieldName] = fieldsMap[fieldName]();
  }
}


/***** Custom Fields Implementations *****/


/**
 * Custom Editable Field for True/False value selection
 * @return {Object} object containing defined field methods for create, set, and get
 */
function dtTrueFalseField() {
  let iconTrue = '.icon-sel-filled',
      iconFalse = '.icon-times-circle',
      icon = 'span.clickable',
      iconSelected = 'span.selected';

  return {

    /**
     * Prepare the truefalse field's input structure and set event listeners and handlers
     * @param {Object} conf DT field configuration object
     * @return {JQuery Element} Field's input element to be appended to the edited cell
     */
    create(conf) {
      conf._enabled = true;
      
      // Render the true / false icons
      conf._input = $(
        `<div>` +
          icons.checkMarkIcon(true, 'text-light clickable in-line', true) +
          icons.checkMarkIcon(false, 'text-light clickable in-line', true) +
        `</div>`)

      // Set new value when one of the icons gains focus
      $(icon, conf._input).on('focus', (e) => {

        if ( conf._enabled ) {

          let value = $(e.target).hasClass( iconTrue.replace('.','') )
          this.set( conf.name, value );

        }

      })

      // Submit value on double click
      $(icon, conf._input).on('dblclick', (e) => {

        if ( conf._enabled )
          this.submit();

      })

      // Change value on left / right key press, submit on enter press
      $(icon, conf._input).on('keydown', (e) => {

        if ( !conf._enabled )
          return;

        switch ( e.which ) {
          case 37:
          case 39:
            $(e.currentTarget).siblings().get(0).focus()
            break;
          case 13:
            this.submit();
            break;
        }

      });

      // Gain focus when editor opens
      $(this).on('open', () => {

        if ( conf._enabled )
          $(iconSelected, conf._input).get(0).focus();
        
        $(icon, conf._input).toggleClass( 'disabled', !conf._enabled );

      });

      return conf._input;
    },

    /**
     * Get the current value of the truefalse field
     * @param {Object} conf DT field configuration object
     * @return {boolean} Currently set value
     */
    get(conf) {
      return $( iconSelected, conf._input ).hasClass( iconTrue.replace('.','') )
    },

    /**
     * Set a new value to the truefalse field and render
     * @param {Object} conf DT field configuration object
     * @param {boolean} value New truefalse field value to be set
     */
    set(conf, value) {

      // Clear styles from selected icon
      $(iconSelected, conf._input).removeClass('selected text-link text-accent-2');

      // Set styles based on value
      if (value === true || value === 'true')
        $(iconTrue, conf._input).addClass('selected text-link')
      else
        $(iconFalse, conf._input).addClass('selected text-accent-2')
    },

    /**
     * Disable field
     * @param {Object} conf DT field configuration object
     */
    disable(conf) {
      conf._enabled = false
    },

    /**
     * Enable field
     * @param {Object} conf DT field configuration object
     */
    enable(conf) {
      conf._enabled = true
    }

  }
};


/**
 * Custom Editable Field for an Items Picker selection
 * @return {Object} object containing defined field methods for create, set, and get
 */
function dtPickerField() {


  /** Helper functions **/

  /**
   * Map the selection object from the Picker to a references data object for the table
   * @param {Object} sel Reference to the SelectionView's getSelection object
   * @return {Array} Remapped data for the Term References column
   */
  function _mapSelectionToColumn(sel) {
    return sel.asObjectsArray()
              .map((d) => Object.assign({}, {
                reference: d,
                context: d.context,
                show_path: d.show_path
              }));
  }

  /**
   * Map the references data object from the table to a references selection array for the Picker
   * @param {Array} data Term References data array
   * @return {Array} Remapped data for the Items Picker
   */
  function _mapColumnToSelection(data) {
    return data.map( (d) => Object.assign({}, d.reference, { context: d.context }));
  }


  /** Field Implementation **/


  return {
    /**
     * Prepare the picker field's input structure and set event listeners and handlers
     * @param {Object} conf DT field configuration object
     * @return {JQuery Element} Field's input element to be appended to the edited cell
     */
    create(conf) {
      conf._safeId = $.fn.dataTable.Editor.safeId( conf.id );

      // Render parent div for the item references
      conf._input = $( `<div id='${conf._safeId}'></div>` );

      // Editor Opened event - set submit callback and show picker
      $(this).on('open', () => {

        // Get current field
        let field = this.field( this.displayed()[0] );

        // Check field pickerName matches this instance's configuration
        if ( field.s.opts.pickerName === conf.pickerName ) {

          // Set the Picker's onSubmit handler to submit the selection in the Editor
          this.pickers[conf.pickerName].onSubmit = (s) => {
            this.set(conf.name, _mapSelectionToColumn(s));
            this.submit();
          }

          // Show Items Picker
          this.pickers[conf.pickerName].show();

        }

      });

      return conf._input;
    },

    /**
     * Get the current values of the picker field
     * @param {Object} conf DT field configuration object
     * @return {Array} Currently set values
     */
    get(conf) {

      // Check Picker instance exists
      if ( !this.pickers[conf.pickerName] )
        return []

      // Return the Items Picker's selection
      return _mapSelectionToColumn( this.pickers[conf.pickerName].selectionView.getSelection() );

    },

    /**
     * Set new values to the picker field and render
     * @param {Object} conf DT field configuration object
     * @param {boolean} data New picker field Term Reference values to be set
     */
    set(conf, data) {

      // Render references in HTML
      $(conf._input).html( termReferences(data, 'display') );

      // Check Picker instance exists
      if ( !this.pickers[conf.pickerName] )
        return;

      // Clear Picker
      this.pickers[conf.pickerName].reset();
      // Append initial selection
      this.pickers[conf.pickerName].selectionView.add(_mapColumnToSelection(data));

    },

    /**
     * Specifies whether the field is allowed to Submit on Return key press
     * @param {Object} conf DT field configuration object
     * @param {JQuery Element} n Field node
     * @return {boolean} always false to disable Submit on Return key press
     */
    canReturnSubmit(conf, n) {
      return false;
    },

    /**
     * Specifies whether a click on a node outside the field should cancel the editing
     * @param {Object} conf DT field configuration object
     * @param {JQuery Element} n Clicked node
     * @return {boolean} Returns true if click detected within the picker
     */
    owns(conf, n) {
      if ( !this.pickers[conf.pickerName] )
        return false;

      return this.pickers[conf.pickerName].modal.find(n).length > 0
    }

  }
}


export {
  dtFieldsInit
}
