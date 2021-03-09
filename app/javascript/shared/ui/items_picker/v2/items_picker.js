import ModalView from 'shared/base/modal_view'
import TabsLayout from 'shared/ui/tabs_layout'

import SelectionHandler from './selection_handler'
import IPHelper from './support/ip_helper'
import IPRenderer from './support/ip_renderer'
import EventHandler from 'shared/helpers/event_handler' 

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
   * @param {array} params.buttons List of definition objects for (extra) buttons that will be rendered in the footer, ({ id, css, text, onClick })
   * @param {string} params.description Description text, will use default if not specified
   * @param {string} params.submitText Submit button text, will use default if not specified
   * @param {boolean} params.multiple Specifies if selection of multiple items is allowed
   * @param {boolean} params.submitEmpty Specifies if possible to submit an empty selection 
   * @param {boolean} params.hideOnSubmit Specifies if picker will hide on submit
   * @param {function} params.onSubmit Specifies the onSubmit callback, with selection passed as the argument
   * @param {function} params.onShow Specifies the onShow (modal) callback
   * @param {function} params.onHide Specifies the onHide (modal) callback
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
        eventHandler: new EventHandler({ 
          selector: this.selector,
          namespace: 'ItemsPicker' 
        }),
        buildRequired: true 
      }
    })

    if ( types )
      this.setTypes( types )

  }


  /*** Actions ***/


  /**
   * Manually build the Picker Instance (use to init and render before the Picker opens)
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  initialize() {

    if ( this._config.buildRequired )
      this._build()

    return this 

  }

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
   * @param {boolean} clearCache Specifies if Panel caches should be cleared
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  reset(clearCache = false) {

    this.selectionHandler?.clear()
    this._eachSelector( selector => selector.reset( clearCache ) )  

    return this 

  }

  /**
   * Destroy Items Picker (to initial state)
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  destroy() {

    this.selectionHandler?.destroy()
    this._selectors && Object.values( this._selectors )
                             .forEach( selector => selector?.destroy() )

    this._EventHandler.unbindAll()
    this._Renderer.empty()

    this.types = undefined

    this._config.buildRequired = true
    return this 

  }

  /**
   * Set ItemsPicker properties to default 
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  setDefaults() {

    this.setOnSubmit( () => {} )
        .setMultiple( false )
        .setDescription( IPRenderer.defaults.description )
        .setSubmitText( IPRenderer.defaults.submit )
        .setButtons([])
    
    return this 

  }


  /*** Setters ***/


  /**
   * Set Picker item types 
   * @param {array} newTypes List of item types allowed to be picked from, must be RdfTypesMap entries @see rdf_types.js
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  setTypes(newTypes) {

    if ( IPHelper.validateTypes( newTypes ) ) {

      // If types are already set, and newTypes are different than current, destroy instance 
      if ( this.types && IPHelper.typesDiffer( this.types, newTypes ) )
        this.destroy()
      
      this.types = newTypes

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

    multiple = !!multiple 

    this.options.multiple = multiple 
    this.selectionHandler?.setMultiple( multiple )
    this._eachSelector( selector => selector.setMultiple( multiple ) )  

    return this 

  }

  /**
   * Set Custom Picker buttons
   * @param {array} buttons Collection of Button definitions (props: id, cssClasses, text, onClick) 
   * @return {ItemsPicker} This ItemsPicker instance (for chaining)
   */
  setButtons(buttons) {

    if ( buttons )
      this.buttons = buttons 
    
    return this 

  }


  /*** Getters ***/


  /**
   * Get reference to RDF Types map
   * @return {Object} Rdf Types Map object reference 
   * @static 
   */
  static get allTypes() {
    return rdfTypesMap
  }

  /**
   * Check if confitions to Submit Selection are fulfilled
   * @return {boolean} True if Selection can be Submitted 
   */
  get canSubmit() {
    return this.options.submitEmpty || !this.selectionHandler?.isEmpty
  }

  /**
   * Get Selection from SelectionHandler instance
   * @return {object | undefined} Selection accessor object / undefined if selectionHandler not available 
   */
  get selection() {
    return this.selectionHandler?.selection
  }


  /*** Private ***/


  /**
   * Submit the current selection - call the onSubmit callback, selection accessor passed as first arg
   */
  _submit() {

    // Do not submit an empty selection
    if ( !this.canSubmit )
      return

    if ( this.events.onSubmit )
      this.events.onSubmit( this.selection )

    if ( this.options.hideOnSubmit )
      this.hide()

  }

  /**
   * Build and render Picker contents (init)
   */
  _build() {

    if ( !this.types ) {
      
      IPHelper.onError({ debug: 'Cannot initialize Picker. No Types have been set' })
      return

    }

    this._setListeners()
    this._initSelectionHandler()
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
                  .renderButtons( this.buttons )
                  .renderTabs( this.types )

    this._dispatch( 'renderComplete' )

  }

  /**
   * Set Picker related event listeners & handlers
   */
  _setListeners() {

    // Render complete handler
    this._EventHandler.on( 'renderComplete', () => this._onRender() )
                      .on( 'selectionChange', () => this._onSelectionChange() ) 

    // Submit Button click handler
    this._Renderer.submitBtn.off('click')   
                            .click( () => this._submit() )

  }


  /*** Selectors ***/


  /**
   * Clear and initialize the Item Selectors 
   */
  _initSelectors() {
    
    this._selectors = {}

    if ( !this.types || !this.types.length ) {

      IPHelper.onError({ debug: 'No Picker types are specified.' })
      return

    }

    for ( const type of this.types ) {
      this._selectors[ type.param ] = this._newSelector( type ) 
    }

  }

  /**
   * Creates a new Managed / Unmanaged Selector based on given type
   * @param {Object} params.type Item type definition
   */
  _newSelector(type) {

    const params = {
      type, 
      options: this.options,
      selectionHandler: this.selectionHandler,
      eventHandler: this._EventHandler
    }

    if ( type === rdfTypesMap.TH_CLI )
      return new UnmanagedSelector( params )

    else 
      return new ManagedSelector( params )

  }


  /*** Selection Handler ***/


  /**
   * Initialize a new SelectionHandler instance 
   */
  _initSelectionHandler() {
  
    this.selectionHandler?.destroy() 

    this.selectionHandler = new SelectionHandler({ 
      selector: this.selector, 
      multiple: this.options.multiple,
      types: this.types,
      eventHandler: this._EventHandler
    })
  
  }


  /*** Events ***/


  /**
   * Dispatches a Picker event
   * @param {string} eventName Name of the custom event 
   * @param {any} args Any args to pass into the handler 
   */
  _dispatch(eventName, ...args) {
    this._config.eventHandler.dispatch( eventName, args )
  }

  /**
   * On Picker show event handler, build if required
   */
  _onShow() {

    if ( this._config.buildRequired )
      this._build()

    if ( this.events.onShow )
      this.events.onShow()

  }

  /**
   * On Picker hide complete event handler
   */
  _onHideComplete() {

    this.reset()

    if ( this.events.onHide )
      this.events.onHide() 
  
  }

  /**
   * On full Render event, initialze TabsLayout and auto-open the first tab 
   */
  _onRender() {

    const tabsLayout = this._Renderer.tabs

    // Init Tabs layout 
    TabsLayout.initialize( tabsLayout )

    // Set a custom handler to tabSwitch event to show() the clicked tab's Selector
    TabsLayout.onTabSwitch( tabsLayout, tab => 
      this._selectors[ IPHelper.idToType(tab) ].show() 
    )

    // Automatically open the first tab in the Picker 
    const tab = this.modal.find( '.tab-option' )
                          .get(0)

    setTimeout( () => tab?.click(), 10 )

    this._Renderer.toggleSubmit( this.canSubmit )

  }

  /**
   * On selection change event, handle UI updates
   */
  _onSelectionChange() {

    // Update Submit button 
    this._Renderer.toggleSubmit( this.canSubmit )

  }


  /*** Support ***/


  /**
   * Iterate over all Selector instances
   * @param {function} action Action to execute for each Selector instance 
   */
  _eachSelector(action = () => {}) {

    if ( !this._selectors )
      return 

    for ( const selector of Object.values( this._selectors ) ) {
      selector && action( selector )
    }

  }


  /*** Getters ***/

  
  /**
   * Get the current Renderer instance 
   * @return {IPRenderer} 
   */
  get _Renderer() {
    return this._config.renderer
  }

  /**
   * Get the current EventHandler instance 
   * @return {EventHandler} 
   */
  get _EventHandler() {
    return this._config.eventHandler
  }

}