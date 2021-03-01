import Cacheable from 'shared/base/cacheable'
import SelectablePanel from 'shared/base/selectable_panel'

import { dtIndexColumns, dtCLIndexColumns, dtSimpleHistoryColumns, dtSimpleChildrenColumns } from 'shared/helpers/dt/dt_column_collections'
import { rdfTypesMap as types } from 'shared/helpers/rdf_types'
import { customBtn } from 'shared/helpers/dt/utils'
import { encodeDataToUrl } from 'shared/helpers/urls' 
import { tableInteraction } from 'shared/helpers/utils'
import IPSRenderer from '../support/ip_selector_renderer'

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

    Object.assign( this, {
      type, id, _Renderer,
      selector: `${ selector } #${ id }`
    })

    this._initPanel()

  }

  /**
   * Set current data source (used for history, children types)
   * @param {object} data Current data source depending on table type  
   * @return {PickerPanel} this instance (for chaining)
   */
  setData(data) {

    if ( data ) {

      this.data = data
      // Render the current item reference in this instance's card subtitle
      this._Renderer.renderSubtitle( this.id, data )

    }
    
    return this 

  }

  /**
   * Load data in panel 
   * @return {PickerPanel} this instance (for chaining)
   */
  load() {

    if ( this._canFetch ) {
    
      const cached = this._getFromCache( this._dataUrl )

      // Render data from cache 
      if ( cached )
        this.sp._render( cached, true )

      // Load data from server  
      else  {

        this._toggleInteraction( true )
        this.sp.loadData( this._dataUrl )

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
      this._removeFromCache( this._dataUrl )
      // Reload data from the server 
      this.load()
          ._dispatchEvent( 'refresh' )
    
    }

    return this 

  }

  /**
   * Clear (empty) panel
   * @param {boolean} clearCache Specify if cache should be cleared too, optional
   * @return {PickerPanel} this instance (for chaining)
   */
  clear(clearCache = false) {

    this.sp.clear()
    this.data = undefined 

    // Empty the subtitle text as no item currently shown 
    this._Renderer.renderSubtitle( this.id )

    if ( clearCache )
      this._clearCache()

    return this 

  }

  /**
   * Set the Multiple select allowed option
   * @param {boolean} multiple Option value 
   */
  setMultiple(multiple) {

    // Set DataTable select option
    this.sp.table.select.style( 
      multiple ? 'multi' : 'single' 
    )

    // Hide / show buttons in table depending on the multiple option value
    if ( this.id === 'children' )
      this.sp.table.buttons([ 'select-all:name', 'deselect-all:name' ])
                   .nodes()
                   .toggle( multiple )

    return this 
    
  }

  /**
   * Destroy Picker Panel instance
   */
  destroy() {

    $( this.selector ).unbind()
    this.sp.destroy()

  }

  /**
   * Add a custom event listener to the panel
   * @warning Do not use names of events that are used in the DataTables API 
   * @param {string} eventName Name of custom event. Available events: selected, deselected, dataLoaded, interactionStateChanged, refresh
   * @param {function} handler Event handler function
   * @return {PickerPanel} this instance (for chaining)
   */
  on(eventName, handler = () => {}) {

    $( this.selector ).on( eventName, (e, ...args) => handler(...args) )
    return this 

  }


  /*** Private ***/


  /**
   * Initialize a new SelectablePanel instance with properties dependent on Picker Panel type 
   */
  _initPanel() {

    const options = this._panelOpts

    if ( this.id === 'index' )
      options.ownershipColorBadge = true 

    if ( this.id === 'children' )
      options.allowAll = true 

    this.sp = new SelectablePanel( options )

  }


  /*** Events ***/

 
  /**
   * On data loaded callback, caches fetched data 
   */
  _onDataLoaded() {

    // Cache loaded data
    this._saveToCache( 
      this._dataUrl, 
      this.sp.rowDataToArray, 
      true 
    )

    // Update loading state
    this._toggleInteraction( false )

    // Data loaded event
    this._dispatchEvent( 'dataLoaded' )

  }

  /**
   * Dispatches a custom Panel event 
   * @warning Do not use names of events that are used in the DataTables API 
   * @param {string} eventName Name of the custom event 
   * @param {any} args Any args to pass into the handler 
   */
  _dispatchEvent(eventName, ...args) {
    $( this.selector ).trigger( eventName, args )
  }


  /*** Getters ***/


  /**
   * Get the columns for this Picker Panel type
   * @return {array} DT Column definitions collection 
   */
  get _columns() {

    switch ( this.id ) {
      case 'index':
        if ( this.type === types.TH_CL )
          return dtCLIndexColumns()
        else 
          return dtIndexColumns() 
      case 'history':
        return dtSimpleHistoryColumns()
      case 'children':
        return dtSimpleChildrenColumns()
    }

  }

  /**
   * Get strong param (server requests) for this Picker Panel type
   * @return {string} strong param for requests   
   */
  get _param() {

    if ( this.type === types.TH_CLI )
      return types.TH_CL.param 

    return this.type.param
  
  }

  /**
   * Get the count value (server requests) for this Picker Panel type
   * @return {int} count value
   */
  get _count() {

    switch ( this.id ) {
      case 'index':
        return 5000
      case 'history':
        return 30
      case 'children':
        return 10000
    }

  }

  /**
   * Get the empty message for this Picker Panel type 
   * @return {string} table empty message 
   */
  get _emptyMsg() {

    switch ( this.id ) {
      case 'index':
        return 'No items found'
      case 'history':
        return 'No version data. Select an item first.' 
      case 'children':
        return 'No children found.' 
    }

  }

  /**
   * Get the custom DT button for data refresh
   * @return {object} DT Button definition 
   */
  get _dtRefreshBtn() {

    return customBtn({
      text: 'Refresh',
      name: 'refresh',
      action: () => this.refresh()
    })

  }


  /*** Urls ***/


  /**
   * Get data url for this Picker Panel type 
   * @return {string} data load request url 
   */
  get _dataUrl() {

    switch ( this.id ) {

      case 'index':
        // Use special index url for for CLs and CLIs 
        if ( this.type === types.TH_CL || this.type === types.TH_CLI )
          return types.TH_CL.indexUrl
         
        return this.type.url  

      case 'history':
        let baseUrl = this.type.url 

        // Use CL url for CLIs 
        if ( this.type === types.TH_CLI )
          baseUrl = types.TH_CL.url 

        const url = baseUrl + '/history',
              urlData = { [this._param]: { 
                identifier: this.data.identifier,
                scope_id: this.data.scope_id
              } }

        return encodeDataToUrl( url, urlData )
        
      case 'children':
        return types.TH_CL.url + '/' + this.data.id + '/children'
    
      }

  }


  /*** Support ***/


  /**
   * Check if panel data can be fetched - validates if required data is set 
   * @return {boolean} True if data can be safely fetched  
   */
  get _canFetch() {

    if ( this.sp.isProcessing )
      return false 

    if ( this.id === 'history' )
      return ( this.data?.identifier && this.data?.scope_id ) 

    if ( this.id === 'children' )
      return !!this.data?.id

    return true 

  }

  /**
   * Set the Panel's interactable state 
   * Does not control the table loading animation
   * @param {boolean} enable Target interactable state
   */
  _toggleInteraction(enable) {

    if ( enable ) {

      tableInteraction.disable( this.selector )
      this.sp.table.buttons()
                   .disable()

    }
    else { 

      tableInteraction.enable( this.selector )
      this.sp.table.buttons()
                   .enable()

    }
    
    // Interaction state changed event
    this._dispatchEvent( 'interactionStateChanged', enable )

  }


  /*** Options ***/


  /**
   * Get the Selectable Panel instance options object for this Picker Panel type 
   * @return {object} Selectable Panel options
   */
  get _panelOpts() {

    return {
      tablePanelOptions: {
        selector: this.selector,
        deferLoading: true, 
        param: this._param,
        count: this._count,
        extraColumns: this._columns,
        buttons: [ this._dtRefreshBtn ],
        tableOptions: this._tableOpts,
        loadCallback: () => this._onDataLoaded(),
        errorCallback: () => this._toggleInteraction( false )
      },
      showSelectionInfo: false,
      onSelect: s => this._dispatchEvent( 'selected', s.data() ),
      onDeselect: s => this._dispatchEvent( 'deselected', s.data() )
    }

  }

  /**
   * Get the DT options object
   * @return {object} DT options
   */
  get _tableOpts() {

    return {
      pageLength: 10,
      lengthChange: false,
      autoWidth: true,
      scrollY: 400,
      scrollCollapse: true,
      scrollX: true,
      language: { emptyTable: this._emptyMsg }
    }

  }

}