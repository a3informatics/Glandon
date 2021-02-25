import SelectablePanel from 'shared/base/selectable_panel'
import IPHelper from '../../support/ip_helper'

import { dtIndexColumns, dtCLIndexColumns, dtSimpleHistoryColumns, dtSimpleChildrenColumns } from 'shared/helpers/dt/dt_column_collections'
import { rdfTypesMap as types } from 'shared/helpers/rdf_types'
import { customBtn } from 'shared/helpers/dt/utils'

/**
 * Items Picker (Selectable) Panel 
 * @description Wrapping class for a Selectable Panel with custom Items Picker related features  
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class PickerPanel {

  /**
   * Create a new Picker Panel instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique selector string of the wrapping element 
   * @param {Object} params.type Selector type, must an entry be from the RdfTypesMap
   * @param {string} params.tableId Specifies type of the table and its id - index / history / children  
   * @param {function} params.onLoad On data load callback
   * @param {function} params.onSelect On item(s) selected callback
   * @param {function} params.onDeselect On item(s) deselected callback
   */
  constructor({
    selector, 
    type,
    tableId,
    onLoad = () => {}, 
    onSelect = () => {}, 
    onDeselect = () => {}
  }) {

    Object.assign( this, {
      type, tableId,
      selector: `${ selector } #${ tableId }`,
      events: {
        onLoad,
        onSelect,
        onDeselect
      }
    })

    this._initPanel()

  }

  /**
   * Destroy Picker Panel instance
   */
  destroy() {
    this.sp.destroy()
  }

  /**
   * Load / reload data in panel 
   */
  load() {
    this.sp.loadData()
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

        return dtIndexColumns() 

      case 'history':
        return dtSimpleHistoryColumns()

      case 'children':
        return dtSimpleChildrenColumns()

    }

  }

  /**
   * Get data url for this Picker Panel type 
   * @return {string} data load request url 
   */
  get _dataUrl() {

    const { url } = this.type 

    switch ( this.tableId ) {

      case 'index':
        if ( this.type === types.TH_CL )
          return `${ url }/set_with_indicators?managed_concept%5Btype%5D=all`
        else
          return url 

      case 'history':
        return `${ url }/history`
      
      case 'children':
        return `${ types.TH_CL.url }/children`
    
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
        return 100 
      case 'children':
        return 10000
    }

  }

  /**
   * Get the custom DT button for data refresh
   * @return {object} DT Button definition 
   */
  get _dtRefreshBtn() {

    return customBtn({
        text: 'Refresh',
        action: () => this.destroy()
      })

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
        url: this._dataUrl,
        param: this._param,
        count: this._count,
        deferLoading: true, 
        extraColumns: this._columns,
        buttons: [ this._dtRefreshBtn ],
        tableOptions: this._tableOpts
      },
      showSelectionInfo: false
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
      scrollY: 400,
      scrollCollapse: true,
      scrollX: true 
    }

  }



}