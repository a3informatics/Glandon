import { itemReferences } from 'shared/ui/collections'

/**
 * Custom Editable Field for an Items Picker selection
 * @return {Object} object containing defined field methods for create, set, and get
 */
export default function DTPickerField() {

  return {

    /**
     * Prepare the picker field's input structure and set event listeners and handlers
     * @param {Object} conf DT field configuration object
     * @return {JQuery Element} Field's input element to be appended to the edited cell
     */
    create(conf) {

      conf._enabled = true
      conf._safeId = $.fn.dataTable.Editor.safeId( conf.id )

      // Render parent div for the item references
      conf._input = $('<div>').attr( 'id', conf._safeId )

      // Editor Opened event - set submit callback and show picker
      $(this).on( 'open', () => {

        // Get current field and picker name 
        const field = this.field( this.displayed()[0] ),
              pickerName = field.s.opts.pickerName
      
        // Check field enabled and pickerName matches this instance's configuration
        if ( pickerName !== conf.pickerName || !conf._enabled )
          return

        // Set the Picker's onSubmit handler to submit the selection in the Editor
        this.pickers[ pickerName ].onSubmit = s => {

          this.set( conf.name, _mapSelectionToColumn(s) )
          this.submit()

        }

        // Show Picker
        this.pickers[ pickerName ].show()

      })

      return conf._input

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
      const selection = this.pickers[conf.pickerName]
                              .selectionView
                              .getSelection()

      return _mapSelectionToColumn( selection )

    },

    /**
     * Set new values to the picker field and render
     * @param {Object} conf DT field configuration object
     * @param {boolean} data New picker field Term Reference values to be set
     */
    set(conf, data) {

      const pickerInstance = this.pickers[conf.pickerName]

      // Render references in HTML
      $( conf._input ).html( itemReferences( data, 'display' ) )

      // Check Picker instance exists
      if ( !pickerInstance )
        return

      // Clear Picker
      pickerInstance.reset()
      // Add data from column to picker selection
      pickerInstance.selectionView.add( _mapColumnToSelection(data) )

    },

    /**
     * Specifies whether the field is allowed to Submit on Return key press
     * @param {Object} conf DT field configuration object
     * @param {JQuery Element} n Field node
     * @return {boolean} always false to disable Submit on Return key press
     */
    canReturnSubmit(conf, n) {
      return false
    },

    /**
     * Specifies whether a click on a node outside the field should cancel the editing
     * @param {Object} conf DT field configuration object
     * @param {JQuery Element} n Clicked node
     * @return {boolean} Returns true if click detected within the picker
     */
    owns(conf, n) {

      if ( !this.pickers[conf.pickerName] )
        return false

      return this.pickers[conf.pickerName].modal.find(n).length > 0

    },

    /**
     * Disable field
     * @param {Object} conf DT field configuration object
     */
    disable(conf) {
      
      conf._enabled = false
      const disabledMsg = $( '<div>' ).addClass( 'field-disabled-msg' )
                                      .text( 'Not Editable' )
      $( conf._input ).append( disabledMsg )

    },

    /**
     * Enable field
     * @param {Object} conf DT field configuration object
     */
    enable(conf) {

      conf._enabled = true
      $( conf._input ).find( '.field-disabled-msg' )
                      .remove()

    }

  }

}


/** Helper functions **/


/**
 * Map the selection object from the Picker to a references data object for the table
 * @param {Object} sel Reference to the SelectionView's getSelection object
 * @return {Array} Remapped data for the Term References column
 */
function _mapSelectionToColumn(sel) {

  return sel.asObjectsArray()
            .map( d => Object.assign({}, {
              reference: d,
              context: d.context,
              show_path: d.show_path
            }))

}

/**
 * Map the references data object from the table to a references selection array for the Picker
 * @param {Array} data Term References data array
 * @return {Array} Remapped data for the Items Picker
 */
function _mapColumnToSelection(data) {

  return data.map( d => 
    Object.assign({}, d.reference, { context: d.context }) 
  )

}
