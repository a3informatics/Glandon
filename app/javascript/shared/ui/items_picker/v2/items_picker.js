import ModalView from 'shared/base/modal_view'
import TabsLayout from 'shared/ui/tabs_layout'

import SelectionHandler from './selection_handler'
import IPHelper from './support/ip_helper'
import IPRenderer from './support/ip_renderer'

import { rdfTypesMap } from 'shared/helpers/rdf_types'
import ManagedSelector from './selectors/ip_managed_selector'
import UnmanagedSelector from './selectors/ip_unmanaged_selector'

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
      selectionHandler: new SelectionHandler({ selector: this.selector, multiple }),
      buttons, 
      strings: {
        description: description || IPRenderer.defaults.description,
        submit: submitText || IPRenderer.defaults.submit
      },
      options: {
        multiple, submitEmpty, hideOnSubmit 
      },
      events: {
        onSubmit, onShow, onHide 
      },
      _config: {
        renderer: new IPRenderer( this.selector ),
        buildRequired: true 
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
    this._config.buildRequired = true
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
      IPHelper.onError({ debug: 'The specified Items Picker types are invalid.' })

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
      this._Renderer.renderDescription( newDescription )

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
      this._Renderer.renderSubmitText( newSubmitText )

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


  /**
   * Submit the current selection - call the onSubmit callback, selection accessor passed as first arg
   */
  _submit() {

    // const { submitEmpty, hideOnSubmit } = this.options

    // // Do not submit an empty selection
    // if ( !submitEmpty && this.selectionView.selectionEmpty )
    //   return

    // if ( this.onSubmit )
    //   this.onSubmit( this.selectionView.getSelection() )

    // if ( hideOnSubmit )
    //   this.hide()

  }

  /**
   * Build and render Picker contents (init)
   */
  _build() {

    // Init tabs 
    this._initSelectors()
    this._renderAll()
    this._config.buildRequired = false

  }

  /**
   * Render all Picker contents
   */
  _renderAll() {

    this._Renderer.renderDescription( this.strings.description )
                  .renderSubmitText( this.strings.submit )
                  .renderTabs( this.types )

    this._dispatchEvent( 'renderComplete' )

  }

  /**
   * Set Picker related event listeners & handlers
   */
  _setListeners() {

    this.modal.on( 'renderComplete', () => {

      const tabsLayout = this._Renderer.$tabs

      TabsLayout.initialize( tabsLayout )

      TabsLayout.onTabSwitch( tabsLayout, tab => 
        this._selectors[ IPHelper.idToType(tab) ].show() 
      )

      // Automatically open the first tab in the Picker 
      setTimeout( () => 
        this.modal.find( '.tab-option' )[0].click(),
        10
      )

    })

  }


  /*** Selectors ***/


  /**
   * Clear and initialize the Item Selectors 
   */
  _initSelectors() {
    
    this._selectors = {}

    for ( const type of this.types ) {
      this._selectors[ type.param ] = this._newSelector( type ) 
    }

  }

  /**
   * Creates a new Managed / Unmanaged Selector based on given type
   * @param {Object} params.type Item type definition
   */
  _newSelector(type) {

    if ( type === rdfTypesMap.TH_CLI )
      return new UnmanagedSelector({
        type, 
        options: this.options
      })

    else 
      return new ManagedSelector({
        type,
        options: this.options
      })

  }


  /*** Events ***/


  /**
   * Dispatches a Picker event (handle by attaching listeners on the modal element)
   * @param {string} eventName Name of the custom event 
   * @param {any} args Any args to pass into the handler 
   */
  _dispatchEvent(eventName, ...args) {
    this.modal.trigger( eventName, args )
  }

  /**
   * On Picker show event handler, build if required
   */
  _onShow() {

    if ( this._config.buildRequired )
      this._build()

    this.events.onShow()

  }

  /**
   * On Picker hide event handler
   */
  _onHide() {
    this.events.onHide() 
  }


  /*** Getters ***/

  
  /**
   * Get the current Renderer instance 
   * @return {IPRenderer} 
   */
  get _Renderer() {
    return this._config.renderer
  }

}