import SHRenderer from './support/sh_renderer'

import { rdfTypesMap as types } from 'shared/helpers/rdf_types'
import { unmanagedItemRef, managedItemRef } from 'shared/ui/strings'

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
   * @param {EventHandler} params.eventHandler Reference to main ItemsPicker Event Handler instance for dispatching and listening to related events 
   */
  constructor({
    selector,
    multiple,
    eventHandler
  }) {

    const _selector = `${ selector } #items-picker-selection`

    Object.assign( this, {
      selector: _selector,
      options: {
        multiple
      },
      _config: {
        renderer: new SHRenderer( _selector ),
        eventHandler,
        buildRequired: true 
      }
    })

    this._initialize()

  }


  /*** Actions ***/


  /**
   * Add items to Selection 
   * @param {Array | Object} items One or more data objects to be added into the selection
   */
  add(items) {

    if ( !Array.isArray( items ) )
      items = [ items ]

    this._add( items )
        ._dispatch( 'selectionChange' )

  }

  /**
   * Remove items from Selection 
   * @param {Array | Object} items One or more data objects to be removed from the selection
   */
  remove(items) {

    if ( !Array.isArray( items ) )
      items = [ items ]
  
    this._remove( items )
        ._dispatch( 'selectionChange' )

  }

  /**
   * Clear the Selection
   */
  clear() {

    this.selection = []
    this._dispatch( 'selectionChange' )

  }

  /**
   * Destroy the Selection Handler instance and set to initial state 
   */
  destroy() {
    delete this.selection 
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
    return this.selection.findIndex( _item => _item.id === item.id )
  }

  /**
   * Get the count of items in Selection
   * @return {int} Count of items
   */
  get count() {
    return this.selection.length
  }


  /*** Private ***/

  
  /**
   * Initialize selection, build if required
   */
  _initialize() {

    this.selection = []
  
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
        this.selection.push( item )
      else 
        this.selection = [ item ]

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
        this.selection.splice( this.indexOf(item), 1 )

    }

    return this 

  }


  /*** String helpers ***/


  /**
   * Get Selection Preview string (for rendering)
   * @return {string} Selection Preview string - selection count / item reference string   
   */
  get _previewString() {

    const [ selectedItem ] = this.selection

    // Return selection count when multiple option enabled 
    if ( this.options.multiple )
      return this.count.toString() 
    
    // Otherwise return reference string | None
    return selectedItem ? 
      this._referenceString( selectedItem ) :
      'None'

  }

  /**
   * Get Item Reference string (for rendering)
   * @param {Object} item Reference item data object 
   * @return {string} Standard Reference string based on item type    
   */
  _referenceString(item) {

    if ( item.rdf_type === types.TH_CLI.rdfType )
      return unmanagedItemRef( item, item._context )

    return managedItemRef( item )
  
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

    this._config.eventHandler.dispatch( eventName, args )
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