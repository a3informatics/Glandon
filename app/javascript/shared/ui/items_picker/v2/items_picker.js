import ModalView from 'shared/base/modal_view'

import TabsLayout from 'shared/ui/tabs_layout'

import IPHelper from './support/ip_helpers'
import IPRenderer from './support/ip_renderers'


/**
 * Items Picker
 * @description Items Picker for version-based selection of managed/unmanaged item types in the system 
 * @extends ModalView module 
 * @requires _items_picker.html.erb partial rendered in page (with matching id property)
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ItemsPicker extends ModalView {

  /**
   * Create a new Items Picker instance
   * @param {Object} params Instance parameters
   * @param {string} params.id Id of the Items Picker modal, must match the id used in partial render 
   * @param {array} params.types List of item types allowed to be picked from, must be RdfTypesMap entries @see rdf_types.js
   * @param {array} params.buttons List of definition objects for (extra) buttons that will be rendered in the footer, ({ id, css, text onClick })
   * @param {string} params.description Description text, will use default if not specified
   * @param {string} params.submitText Submit button text, will use default if not specified
   * @param {boolean} params.multiple Specifies if selection of multiple items is allowed
   * @param {boolean} params.submitEmpty Specifies if possible to submit an empty selection 
   * @param {boolean} params.hideOnSubmit Specifies if picker will hide on submit
   * @param {function} params.onSubmit Specifies the onSubmit callback, with selection passed as the argument
   * @param {function} params.onShow Specifies the onShow (modal) callback
   * @param {function} params.onShow Specifies the onHide (modal) callback
   */
  constructor({
    id,   
    types,
    buttons = [],
    
    description,
    submitText,

    multiple = false,
    submitEmpty = false,
    hideOnSubmit = true,

    onSubmit = () => {},
    onShow = () => {},
    onHide = () => {}
  }) {

    super({ 
      selector: `#items-picker-${ id }` 
    })

    Object.assign( this, {
      buttons, 
      strings: {
        description: description || this.defaultStrings.description,
        submit: submitText || this.defaultStrings.submit
      },
      options: {
        multiple, submitEmpty, hideOnSubmit 
      },
      events: {
        onSubmit, onShow, onHide 
      },
      _options: {
        rerender: true 
      }
    })

    if ( types )
      this.setTypes( types )

    this._setListeners()

  }


  /*** Actions ***/


  /**
   * Show Items Picker
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  show() {

    super.show()

    return this 

  }

  /**
   * Reset Items Picker - clear selection, data cache
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  reset() {

    // Clear tabs
    // Clear selection 
    return this 

  }

  /**
   * Destroy Items Picker (to initial state)
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  destroy() {

    // Set to state before init 
    this._options.rerender = true
    return this 

  }


  /*** Setters ***/


  /**
   * Set Picker item types 
   * @param {array} newTypes List of item types allowed to be picked from, must be RdfTypesMap entries @see rdf_types.js
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  setTypes(newTypes) {

    if ( newTypes && IPHelper.validateTypes( newTypes ) ) {
      
      this.types = newTypes
      this.destroy()

    }
    else 
      IPHelper.onError({ debugMessage: 'The specified Items Picker types are incorrect.' })

    return this 

  }

  /**
   * Set Picker description text 
   * @param {string} newDescription Description text to be rendered
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  setDescription(newDescription) {

    if ( newDescription ) {
    
      this.strings.description = newDescription
      // Should call renderer
      this.dispatchEvent( 'descriptionChanged', newDescription )

    } 

    return this
    
  }

  /**
   * Set Picker submit button text 
   * @param {string} newSubmitText Button text to be rendered
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  setSubmitText(newSubmitText) {

    if ( newSubmitText ) {
    
      this.strings.submit = newSubmitText
      // Should call renderer
      this.dispatchEvent( 'submitTextChanged', newSubmitText )

    } 

    return this
    
  }

  /**
   * Set Picker submit event handler 
   * @param {function} onSubmit On selection submit event handler, gets selection access object passed as first arg
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  setOnSubmit(onSubmit) {

    if ( onSubmit ) 
      this.events.onSubmit = onSubmit
    
    return this 

  }

  /**
   * Set Picker multiple option
   * @param {boolean} multiple Specifies whether multiple items can be selected in the Picker
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  setMultiple(multiple) {

    this.options.multiple = !!multiple 
    return this 

  }


  /*** Private ***/


  _setListeners() {

    this.modal.on( 'renderComplete', () => {

      TabsLayout.initialize( this.$tabs )
      TabsLayout.onTabSwitch( this.$tabs, tab => console.log('switched ', tab) )

    })

  }


  /**
   * Render all Picker content
   */
  _renderAll() {

    let content = IPRenderer.renderTabs( this.types )

    this.$content.html( content )
    
    this._options.rerender = false
    this.dispatchEvent( 'renderComplete' )

  }


  /*** Events ***/


  /**
   * Dispatches a Picker event (handle by attaching listeners on the modal element)
   * @param {string} eventName Name of the custom event 
   * @param {any} args Any args to pass into the handler 
   */
  dispatchEvent(eventName, ...args) {
    this.modal.trigger( eventName, args )
  }

  /**
   * On Picker show event handler, renders contents if required
   */
  _onShow() {

    if ( this._options.rerender )
      this._renderAll()

    this.events.onShow()

  }


  /*** Elements ***/


  /**
   * Get the content element in which the Picker dynamic content gets rendered
   * @return {JQuery Element} Dynamic content wrapper element 
   */
  get $content() {
    return this.modal.find( '.modal-body' )
  }

  /**
   * Get the Picker tabs element
   * @return {JQuery Element} Picker tabs element
   */
  get $tabs() {
    return this.$content.find( '#items-picker-tabs' )
  }


  /*** Defaults ***/


  /**
   * Get the default values for various prompts in the Picker 
   * @return {object} Default string values
   */
  get defaultStrings() {

    return {
      description: 'To proceed, select one or more items',
      submit: 'Submit and proceed'
    }

  }

}