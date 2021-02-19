import ModalView from 'shared/base/modal_view'

// import SelectionView from 'shared/ui/items_picker/selection_view'
// import TabsLayout from 'shared/ui/tabs_layout'
// import UnmanagedItemSelector from 'shared/ui/items_picker/unmanaged_item_selector'
// import ManagedItemSelector from 'shared/ui/items_picker/managed_item_selector'

// import { rdfTypesMap } from 'shared/helpers/rdf_types'
import IPRenderer from './items_picker_renderers'


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
   * @param {array} params.types List of item types allowed to be picked from - strings, which match the key names in the RdfTypesMap @see rdf_types.js
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
    types = [],
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
      types, 
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

  }

  /*** Actions ***/


  show() {

    super.show()

    return this 

  }

  reset() {

    // Clear tabs
    // Clear selection 
    return this 

  }

  destroy() {

    // Set to state before init 
    this._options.rerender = true
    return this 

  }


  /*** Setters ***/


  setTypes(newTypes) {

    if ( newTypes ) {
      
      this.types = newTypes
      this.destroy()

    }

    return this 

  }

  setDescription(newDescription) {

    if ( newDescription ) {
    
      this.strings.description = newDescription
      this.dispatchEvent( 'descriptionChanged', newDescription )

    } 

    return this
    
  }

  setSubmitText(newSubmitText) {

    if ( newSubmitText ) {
    
      this.strings.submit = newSubmitText
      this.dispatchEvent( 'submitTextChanged', newSubmitText )

    } 

    return this
    
  }

  setOnSubmit(onSubmit) {

    if ( onSubmit ) 
      this.events.onSubmit = onSubmit
    
    return this 

  }

  setMultiple(multiple) {

    this.options.multiple = !!multiple 
    return this 

  }


  /*** Private ***/


  /*** Elements ***/


  get $content() {
    return this.modal.find( '.modal-body' )
  }


  /*** Events ***/


  dispatchEvent(eventName, ...args) {
    this.modal.trigger( eventName, args )
  }


  /*** Defaults ***/


  get defaultStrings() {

    return {
      description: 'To proceed, select one or more items',
      submit: 'Submit and proceed'
    }

  }

}