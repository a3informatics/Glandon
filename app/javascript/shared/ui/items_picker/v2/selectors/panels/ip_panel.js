import Cacheable from 'shared/base/cacheable'
import SelectablePanel from 'shared/base/selectable_panel'

import PickerPanelHelper from '../support/ip_panel_helper'
import IPSRenderer from '../support/ip_selector_renderer'
import EventHandler from 'shared/helpers/event_handler' 

import { customBtn } from 'shared/helpers/dt/utils'
import { tableInteraction } from 'shared/helpers/utils'

/**
 * Selectable Items Picker Panel 
 * @description Wrapping class for a Selectable Panel with custom Items Picker related features  
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class PickerPanel extends Cacheable {

  /**
   * Create a new Picker Panel instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique selector string of the wrapping element 
   * @param {Object} params.type Selector type, must an entry be from the RdfTypesMap
   * @param {string} params.id Specifies the id of the table - index / history / children  
   * @param {IPSRenderer} params._Renderer IP Selector Renderer instance reference   
   */
  constructor({
    selector, 
    type,
    id,
    _Renderer
  }) {

    super()

    const _selector = `${ selector } #${ id }`

    Object.assign( this, {
      selector: _selector,
      options: {
        type, id 
      },
      _config: {
        renderer: _Renderer,
        eventHandler: new EventHandler({ 
          selector: _selector, 
          namespace: 'PickerPanel' 
        })
      }
    })

    this._initialize()

  }


  /*** Actions ***/


  /**
   * Load data in panel 
   * @return {PickerPanel} this instance (for chaining)
   */
  load() {

    if ( this._canFetch ) {
    
      const cached = this._getFromCache( this._cacheKey )

      // Render data from cache 
      if ( cached )
        this.sp._render( cached, true )

      // Load data from server  
      else  {

        this._toggleInteraction( false )
        this.sp.loadData( this._url )

      }

    }

    return this 

  }

  /**
   * Clear panel cache and reload data 
   * @return {PickerPanel} this instance (for chaining)
   */
  refresh() {

    if ( this._canFetch ) {

      // Remove current item data from cache 
      this._removeFromCache( this._cacheKey )
      // Reload data from the server 
      this.load()
          .dispatch( 'refresh' )
    
    }

    return this 

  }

  /**
   * Clear (empty) panel
   * @param {boolean} clearCache Specify if cache should be cleared too, optional
   * @return {PickerPanel} this instance (for chaining)
   */
  clear(clearCache = false) {

    // Empty table and remove data reference 
    this.sp.clear()
    this.data = undefined 

    // Empty the subtitle text as no item currently shown 
    this._setSubtitle('')

    // Clear all cache if flag set to true 
    if ( clearCache )
      this._clearCache()

    return this 

  }

  /**
   * Set current data source (used for history, children types)
   * @param {object} data Current data source depending on table type  
   * @return {PickerPanel} this instance (for chaining)
   */
  setData(data) {

    if ( data ) {
      this.data = data
      this._setSubtitle( data )
    }
    
    return this 

  }

  /**
   * Set the Multiple select allowed option
   * @param {boolean} multiple Option value 
   */
  setMultiple(multiple) {

    // Set panel multiple option
    this.sp.setMultiple( multiple )

    // Hide / show buttons in table depending on the multiple option value
    if ( this.options.id === 'children' )
      this._tableButtons([ 'select-all:name', 'deselect-all:name' ])
        .nodes()
        .toggle( multiple )

    return this 
    
  }

  /**
   * Destroy Picker Panel instance
   */
  destroy() {

    this._config.eventHandler.unbindAll()
    this.sp.destroy()

  }

  /**
   * Get data of currently selected items in Panel
   * @return {Array} Array of data objects of selected items  
   */
  get selected() {
    return this.sp.selected.data().toArray()
  }


  /*** Events ***/


  /**
   * Dispatches a custom Panel event 
   * @param {string} eventName Name of the custom event 
   * @param {any} args Any args to pass into the handler 
   */
  dispatch(eventName, ...args) {

    this._config.eventHandler.dispatch( eventName, ...args )
    return this 

  }

  /**
   * Add a custom event listener to the panel
   * @param {string} eventName Name of custom event. Available events: selected, deselected, dataLoaded, interactionStateChanged, refresh
   * @param {function} handler Event handler function
   * @return {PickerPanel} this instance (for chaining)
   */
  on(eventName, handler = () => {}) {

    this._config.eventHandler.on( eventName, handler )
    return this 

  }


  /*** Private ***/


  /**
   * Initialize a new SelectablePanel instance with properties dependent on Picker Panel type 
   */
  _initialize() {

    const params = PickerPanelHelper.panelParams( 
      this.options, 
      {
        selector: this.selector, 
        buttons: [ this._dtRefreshButton ],
        onLoad: () => this._onDataLoaded(),
        onError: () => this._toggleInteraction( true ),
        onSelect: s => this.dispatch( 'selected', s.data().toArray() ),
        onDeselect: d => this.dispatch( 'deselected', d.data().toArray() )
      }
    )

    this.sp = new SelectablePanel( params )

  }

  /**
   * Render the subtitle text as item reference in this instance's card 
   * @param {object | undefined} data Data to render in subtitle 
   */
  _setSubtitle(data) {
    this._config.renderer.renderSubtitle( this.options.id, data )
  }


  /*** Events ***/

 
  /**
   * On data loaded callback, caches fetched data 
   */
  _onDataLoaded() {

    // Cache loaded data
    this._saveToCache( 
      this._cacheKey, 
      this.sp.rowDataToArray, 
      true 
    )

    // Update loading state
    this._toggleInteraction( true )

    // Data loaded event
    this.dispatch( 'dataLoaded' )

  }


  /*** Getters ***/


  /**
   * Get data url for this Picker Panel type 
   * @return {string | undefined} data load request url, undefined if data not in correct format  
   */
  get _url() {
    return PickerPanelHelper.dataUrl( this.options, this.data )
  }

  /**
   * Check if panel data can be fetched - validates if required data is set 
   * @return {boolean} True if data can be safely fetched  
   */
  get _canFetch() {

    if ( this.sp.isProcessing )
      return false 

    return !!this._url // Fetch is safe only when url is defined 

  }

  /**
   * Get a unique cache key for the currently set item data reference 
   * @return {string} Unique data cache key equal to the current data url value
   */
  get _cacheKey() {
    return this._url
  }

  /**
   * Get the custom DT button definition for data refresh
   * @return {object} DT Button definition 
   */
  get _dtRefreshButton() {

    return customBtn({
      text: 'Refresh',
      name: 'refresh',
      action: () => this.refresh()
    })

  }


  /*** Support ***/


  /**
   * Shorthand to get the reference to this panel's table buttons
   * @param {any} selector Valid DT Buttons selector, optional
   * @return {DT Buttons} DataTables Buttons selection 
   */
  _tableButtons(selector) {
    return this.sp.table.buttons( selector )
  }

  /**
   * Set the Panel's interactable state 
   * Does not control the table loading animation
   * @param {boolean} enable Target interactable state
   */
  _toggleInteraction(enable) {

    if ( enable ) {

      tableInteraction.enable( this.selector )
      this._tableButtons().enable()
      
    }
    else { 

      tableInteraction.disable( this.selector )
      this._tableButtons().disable()

    }
    
    // Interaction state changed event
    this.dispatch( 'interactionStateChanged', enable )

  }

}