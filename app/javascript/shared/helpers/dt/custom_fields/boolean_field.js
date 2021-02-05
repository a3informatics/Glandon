import { icons } from 'shared/ui/icons'

/**
 * Custom Editable Field for True/False value selection
 * @return {Object} object containing defined field methods for create, set, and get
 */
export default function DTBooleanField() {

  let iconTrue = '.icon-sel-filled',
      iconFalse = '.icon-times-circle',
      icon = 'span.clickable',
      iconSelected = 'span.selected'

  return {

    /**
     * Prepare the truefalse field's input structure and set event listeners and handlers
     * @param {Object} conf DT field configuration object
     * @return {JQuery Element} Field's input element to be appended to the edited cell
     */
    create(conf) {
      conf._enabled = true
      
      // Render the true / false icons
      conf._input = $('<div>').append( icons.checkMarkIcon( true, 'text-light clickable in-line', true ) )
                              .append( icons.checkMarkIcon( false, 'text-light clickable in-line', true ) )

      // Set new value when one of the icons gains focus
      $( icon, conf._input ).on( 'focus', e => {

        if ( conf._enabled ) {
          let value = $(e.target).hasClass( iconTrue.replace('.','') )
          this.set( conf.name, value )
        }

      })

      // Submit value on double click
      $( icon, conf._input ).on( 'dblclick', e => {

        if ( conf._enabled )
          this.submit()

      })

      // Change value on left / right key press, submit on enter press
      $( icon, conf._input ).on( 'keydown', e => {

        if ( !conf._enabled )
          return

        switch ( e.which ) {
          // Focus on sibling on Arrow key
          case 37:
          case 39:
            $(e.currentTarget).siblings().get(0).focus()
            break;
          // Submit on Enter 
          case 13:
            this.submit()
            break;
        }

      })

      // Gain focus when editor opens
      $( this ).on( 'open', () => {

        if ( conf._enabled )
          $( iconSelected, conf._input ).get(0).focus()
        
        $( icon, conf._input ).toggleClass( 'disabled', !conf._enabled )

      })

      return conf._input
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
      $( iconSelected, conf._input ).removeClass( 'selected text-link text-accent-2' )

      // Set styles based on value
      if ( value === true || value === 'true' )
        $( iconTrue, conf._input ).addClass( 'selected text-link' )
      else
        $( iconFalse, conf._input ).addClass( 'selected text-accent-2' )

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
}