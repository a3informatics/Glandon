import SHRenderer from './support/sh_renderer'

import InformationDialog from 'shared/ui/dialogs/information_dialog'
import { rdfTypesMap as types } from 'shared/helpers/rdf_types'

/**
 * Selection Handler (Items Picker)
 * @description A module dedicated to rendering and handling Items Picker Selection state 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SelectionHandler {

  /**
   * Create a new Selection Handler instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique selector string of the ItemsPicker in which the SelectionHandler will render 
   * @param {boolean} params.multiple Specifies if selection of multiple items is allowed
   * @param {array} params.types Pickable Type definition objects
   * @param {EventHandler} params.eventHandler Reference to main ItemsPicker Event Handler instance for dispatching and listening to related events 
   */
  constructor({
    selector,
    multiple,
    types,
    eventHandler
  }) {

    const _selector = `${ selector } #items-picker-selection`

    Object.assign( this, {
      selector: _selector,
      options: {
        multiple,
        types
      },
      _config: {
        renderer: new SHRenderer( _selector ),
        eventHandler,
        buildRequired: true 
      }
    })

    this._initialize()

  }

  /**
   * Get Selection array in a specific format 
   * @return {Object} Functions that return selection in formats: asObjects, asIDs
   */
  get selection() {
    return {
      asObjects: () => {
        return this._selection
      },
      asIDs: () => {
        return this._selection.asObjects().map( d => d.id )
      }
    }
  }


  /*** Actions ***/


  /**
   * Add items to Selection 
   * Dispatches selectionChange event with this instance and updatePanels as args 
   * @param {Array | Object} items One or more data objects to be added into the selection
   * @param {Object} params Optional params 
   * @param {boolean} updatePanels Specifies whether the selection of the Panels in the Picker requires updating 
   */
  add(items, { updatePanels = false } = {}) {

    if ( !Array.isArray( items ) )
      items = [ items ]

    this._add( items )
        ._dispatch( 'selectionChange', this, updatePanels )

  }

  /**
   * Remove items from Selection 
   * Dispatches selectionChange event with this instance and updatePanels as args 
   * @param {Array | Object} items One or more data objects to be removed from the selection
   * @param {Object} params Optional params 
   * @param {boolean} updatePanels Specifies whether the selection of the Panels in the Picker requires updating 
   */
  remove(items, { updatePanels = false } = {}) {

    if ( !Array.isArray( items ) )
      items = [ items ]
  
    this._remove( items )
        ._dispatch( 'selectionChange', this, updatePanels )

  }

  /**
   * Clear Selection
   * Dispatches selectionChange event with this instance and updatePanels as args 
   * @param {Object} params Optional params 
   * @param {boolean} updatePanels Specifies whether the selection of the Panels in the Picker requires updating 
   */
  clear({ updatePanels = true } = {}) {

    this._selection = []
    this._dispatch( 'selectionChange', this, updatePanels )

  }

  /**
   * Destroy the Selection Handler instance and set to initial state 
   */
  destroy() {

    this._selection = []
    this._Renderer.empty()
    this._config.buildRequired = true

  }


  /*** Utils ***/


  /**
   * Check if Selection has given item 
   * @param {object} item Data object (must contain unique id of the item)
   * @return {boolean} True if selection contains item
   */
  has(item) {
    return this.indexOf( item ) !== -1
  }

  /**
   * Get index of a given item in Selection
   * @param {object} item Data object (must contain unique id of the item)
   * @return {int} Index of the item in the selection, -1 if not present 
   */
  indexOf(item) {
    return this._selection.findIndex( _item => _item.id === item.id )
  }

  /**
   * Get the count of items in Selection
   * @return {int} Count of items
   */
  get count() {
    return this._selection.length
  }

  /**
   * Check if Selection is empty
   * @return {boolean} True if empty
   */
  get isEmpty() {
    return this.count === 0
  }


  /*** Private ***/

  
  /**
   * Initialize selection, build if required
   */
  _initialize() {

    this._selection = []
  
    if ( this._config.buildRequired )
      this._build()

  }

  /**
   * Render and build the Selection Handler 
   */
  _build() {

    this._Renderer.renderHandler()
    this._renderPreview() 

    this._setListeners()

    this._config.buildRequired = false

  }

  /**
   * Set event listeners & handlers 
   */
  _setListeners() {

    const { eventHandler } = this._config 

    eventHandler
      .on( 'selectionChange', () => this._renderPreview() )

    // Button event handlers 
    $( this.selector ).find( '#clear-selection' )
                      .click( () => this.clear() )

    $( this.selector ).find( '#view-selection' )
                      .click( () => this._showSelectionDialog() )

  }


  /*** Actions ***/



  /**
   * Add items to Selection 
   * @param {Array} items Array of data objects to be added into the selection
   * @return {SelectionHandler} This instance 
   */
  _add(items) {

    for ( const item of items ) {

      if ( !item || this.has( item ) )
        continue

      if ( this.options.multiple )
        this._selection.push( item )
      else 
        this._selection = [ item ]

    }

    return this 

  }

  /**
   * Remove items to Selection 
   * @param {Array} items Array of data objects to be remove from the selection
   * @return {SelectionHandler} This instance 
   */
  _remove(items) {

    for ( const item of items ) {

      if ( item )
        this._selection.splice( this.indexOf(item), 1 )

    }

    return this 

  }

  
  /*** Selection Dialog ***/


  /**
   * Init and show Selection Dialog 
   */
  _showSelectionDialog() {

    new InformationDialog({
      title: 'Current selection',
      target: this.selector,
      subtitle: this._buildSelectionDialog,
      wide: true
    }).show()

  }

  /**
   * Get Selection Dialog contents for rendering
   * @return {JQuery Element} Selection Dialog rendered contents with attached event handler
   */
  get _buildSelectionDialog() {

    return this._Renderer.buildSelectionDialog({
      selection: this._selection, 
      types: this.options.types,
      onItemClick: el => this._onSelectionDialogItemClick(el)
    })

  }

  /**
   * Selection Dialog Item Click event handler, remove matching Item from Selection
   * @param {JQuery Element} element Clicked element 
   */
  _onSelectionDialogItemClick(element) {

    if ( !element )
      return 

    // Remove from selection
    this.remove(
      { id: element.attr('data-id') }, 
      { updatePanels: true }
    ) 
    // Remove label element 
    element.remove() 

  }


  /*** String helpers ***/


  /**
   * Get Selection Preview string (for rendering)
   * @return {string} Selection Preview string - selection count / item reference string   
   */
  get _previewString() {

    const [ selectedItem ] = this._selection

    // Return selection count when multiple option enabled 
    if ( this.options.multiple )
      return this.count.toString() 
    
    // Otherwise return reference string | None
    return selectedItem ? 
      SHRenderer.referenceString( selectedItem ) :
      'None'

  }


  /*** Support ***/


  /**
   * Render the current Selection state in Selection Preview element
   */
  _renderPreview() {
    this._Renderer.renderPreview( this._previewString, this.options )
  }

  /**
   * Dispatches a Selection Handler event
   * @param {string} eventName Name of the custom event 
   * @param {any} args Any args to pass into the handler 
   * @return {SelectionHandler} This instance  
   */
  _dispatch(eventName, ...args) {

    this._config.eventHandler.dispatch( eventName, ...args )
    return this 

  }

  /**
   * Get the current Renderer instance 
   * @return {IPRenderer} 
   */
  get _Renderer() {
    return this._config.renderer
  }

}