import Cacheable from 'shared/base/cacheable'
import SelectablePanel from 'shared/base/selectable_panel'
import IPHelper from '../../support/ip_helper'

import { dtIndexColumns, dtCLIndexColumns, dtSimpleHistoryColumns, dtSimpleChildrenColumns } from 'shared/helpers/dt/dt_column_collections'
import { rdfTypesMap as types } from 'shared/helpers/rdf_types'
import { customBtn } from 'shared/helpers/dt/utils'
import { encodeDataToUrl } from 'shared/helpers/urls' 

/**
 * Items Picker (Selectable) Panel 
 * @description Wrapping class for a Selectable Panel with custom Items Picker related features  
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class PickerPanel extends Cacheable {

  /**
   * Create a new Picker Panel instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique selector string of the wrapping element 
   * @param {Object} params.type Selector type, must an entry be from the RdfTypesMap
   * @param {string} params.tableId Specifies type of the table and its id - index / history / children  
   */
  constructor({
    selector, 
    type,
    tableId
  }) {

    super()

    Object.assign( this, {
      type, tableId,
      selector: `${ selector } #${ tableId }`
    })

    this._initPanel()

  }

  /**
   * Set current data source (used for history, children types)
   * @param {object} data Current data source depending on table type  
   * @return {PickerPanel} this instance (for chaining)
   */
  setData(data) {

    if ( data )
      this.data = data

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

        this._loading( true )
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

      this._removeFromCache( this._dataUrl )

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

    if ( clearCache )
      this._clearCache()

    return this 

  }

  /**
   * Set the Multiple select allowed option
   * @param {boolean} multiple Option value 
   */
  setMultiple(multiple) {
    this.sp.table.select.style( multiple ? 'multi' : 'single' )
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
   * @param {string} eventName Name of custom event. Available events: selected, deselected, dataLoaded, loadingStateChanged, refresh
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

    if ( this.tableId === 'index' )
      options.ownershipColorBadge = true 

    if ( this.tableId === 'children' )
      options.allowAll = true 

    this.sp = new SelectablePanel( options )

  }


  /*** Events ***/


  /**
   * Dispatches a custom Panel event 
   * @warning Do not use names of events that are used in the DataTables API 
   * @param {string} eventName Name of the custom event 
   * @param {any} args Any args to pass into the handler 
   */
  _dispatchEvent(eventName, ...args) {
    $( this.selector ).trigger( eventName, args )
  }
  
  /**
   * On data loaded callback, caches fetched data 
   */
  _onDataLoaded() {

    // Cache loaded data
    const url = this._dataUrl,
          data = this.sp.rowDataToArray

    this._saveToCache( url, data, true )

    // Update loading state
    this._loading( false )

    // Data loaded event
    this._dispatchEvent( 'dataLoaded' )

  }


  /*** Getters ***/


  /**
   * Get the columns for this Picker Panel type
   * @return {array} DT Column definitions collection 
   */
  get _columns() {

    switch ( this.tableId ) {
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

    switch ( this.tableId ) {
      case 'index':
        return 5000
      case 'history':
        return 30
      case 'children':
        return 10000
    }

  }

  get _emptyMsg() {

    switch ( this.tableId ) {
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

    let { url } = this.type  

    switch ( this.tableId ) {

      case 'index':
        if ( this.type === types.TH_CL || this.type === types.TH_CLI )
          return this._codeListsIndexUrl
         
        return url 

      case 'history':
        const baseUrl = url + '/history',
              urlData = { [this._param]: { 
                identifier: this.data.identifier,
                scope_id: this.data.scope_id
              } }

        return encodeDataToUrl( baseUrl, urlData )
        
      case 'children':
        return types.TH_CL.url + '/children'
    
      }

  }

  /**
   * Get the Code Lists index url (set with indicators) 
   * @return {string} Code Lists index url 
   */
  get _codeListsIndexUrl() {

    const baseUrl = types.TH_CL.url + '/set_with_indicators',
          urlData = { [types.TH_CL.param]: { 
            type: 'all' 
          } }

    return encodeDataToUrl( baseUrl, urlData )

  }


  /*** Support ***/


  /**
   * Check if panel data can be fetched - validates if required data is set 
   * @return {boolean} True if data can be safely fetched  
   */
  get _canFetch() {

    if ( this.sp.isProcessing )
      return false 

    if ( this.tableId === 'history' )
      return ( this.data?.identifier && this.data?.scope_id ) 

    return true 

  }

  /**
   * Set the Panel's loading state 
   * does not control the table loading animation, only additional stuff (e.g. table buttons)
   * @param {boolean} enable Target loading state
   */
  _loading(enable) {

    if ( enable )
      this.sp.table.buttons().disable()
    else 
      this.sp.table.buttons().enable()

    // Loading state changed event
    this._dispatchEvent( 'loadingStateChanged', enable )

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
        loadCallback: () => this._onDataLoaded()
      },
      showSelectionInfo: false,
      onSelect: s => this._dispatchEvent( 'selected', s ),
      onDeselect: s => this._dispatchEvent( 'deselected', s )
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