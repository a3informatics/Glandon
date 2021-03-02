import { dtIndexColumns, dtCLIndexColumns, dtSimpleHistoryColumns, dtSimpleChildrenColumns } from 'shared/helpers/dt/dt_column_collections'
import { rdfTypesMap as types } from 'shared/helpers/rdf_types'
import { encodeDataToUrl } from 'shared/helpers/urls' 

/**
 * Picker Panel Helper  
 * @description Collection of helper functions for Picker Panel 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class PickerPanelHelper {

  /**
   * Builds the panel parameters for a new Selectable Panel based on Picker Panel options 
   * @param {object} options Picker Panel options object containing its id and type definitions 
   * @param {string} selector Unique table selector
   * @param {array} buttons Custom table button definitions
   * @param {function} onLoad On table data load callback
   * @param {function} onError On table request error callback
   * @param {function} onSelect On table item(s) selection callback
   * @param {function} onDeselect On table item(s) deselection callback
   * @return {object} Properties object for a Selectable Panel in the context of Picker Panel
   */
  static panelParams(options, {
    selector, 
    buttons = [],
    onLoad,
    onError,
    onSelect,
    onDeselect
  }) {

    const params = {
      showSelectionInfo: false,
      onSelect: s => onSelect(s),
      onDeselect: d => onDeselect(d),

      tablePanelOptions: {
        selector, buttons, 
        deferLoading: true, 

        extraColumns: this.columns( options ),
        param: this.param( options ),
        count: this.count( options ),

        loadCallback: () => onLoad(),
        errorCallback: () => onError(),

        tableOptions: {
          pageLength: 10,
          lengthChange: false,
          autoWidth: true,
          scrollY: 400,
          scrollCollapse: true,
          scrollX: true,
          language: { 
            emptyTable: this.emptyMessage( options ) 
          }
        }
      }
    }

    if ( options.id === 'index' )
      params.ownershipColorBadge = true 

    if ( options.id === 'children' )
      params.allowAll = true 

    return params 

  }

  /**
   * Get table column collection based on panel options
   * @param {object} options Picker Panel options object containing its id and type definitions
   * @return {array} DT column definitions
   */
  static columns(options) {

    switch ( options.id ) {

      case 'index':
        if ( options.type === types.TH_CL )
          return dtCLIndexColumns()

        return dtIndexColumns() 

      case 'history':
        return dtSimpleHistoryColumns()

      case 'children':
        return dtSimpleChildrenColumns()

    }
    
  }

  /**
   * Get request param based on panel options
   * @param {object} options Picker Panel options object containing its id and type definitions
   * @return {string} Request strong param
   */
  static param(options) {
    
    if ( options.type === types.TH_CLI )
      return types.TH_CL.param 

    return options.type.param

  }

  /**
   * Get request count parameter based on panel options
   * @param {object} options Picker Panel options object containing its id and type definitions
   * @return {int} Request count parameter
   */
  static count(options) {
    
    switch ( options.id ) {
      case 'index':
        return 5000
      case 'history':
        return 30
      case 'children':
        return 10000
    }

  }

  /**
   * Get table empty message based on panel options 
   * @param {object} options Picker Panel options object containing its id and type definitions
   * @return {string} Custom table empty message 
   */
  static emptyMessage(options) {
    
    switch ( options.id ) {
      case 'index':
        return 'No items found'
      case 'history':
        return 'No versions found.' 
      case 'children':
        return 'No children found.' 
    }

  }


  /*** Urls ***/


  /**
   * Get data url based on panel options and type 
   * @param {object} options Picker Panel options object containing its id and type definitions
   * @param {object | undefined} data Data object of item to build the url for (not required for index url)
   * @return {string | undefined} Panel data url, undefined if data in wrong format  
   */
  static dataUrl(options, data) {

    switch( options.id ) {

      case 'index':
        return this.indexUrl( options )

      case 'history':
        return this.historyUrl( options, data )

      case 'children':
        return this.childrenUrl( options, data )

    }

  }


  /**
   * Get index data url based on panel options 
   * @param {object} options Picker Panel options object containing its id and type definitions
   * @return {string} Index data url 
   */
  static indexUrl(options) {
    
    const { type } = options 

    // Use special index url for for CLs and CLIs 
    if ( type === types.TH_CL || type === types.TH_CLI )
      return types.TH_CL.indexUrl
    
    return type.url  

  }

  /**
   * Get history data url based on panel options 
   * @param {object} options Picker Panel options object containing its id and type definitions
   * @param {object} data Data object of item to access history data for, must have the identifier and scope_id properties set 
   * @return {string | undefined} History data url, undefined if data in wrong format  
   */
  static historyUrl(options, data) {

    const { type } = options 

    if ( !data?.identifier || !data?.scope_id )
      return

    let baseUrl = type.url 

    // Use CL base url for CLIs 
    if ( type === types.TH_CLI )
      baseUrl = types.TH_CL.url 

    const url = baseUrl + '/history',
          urlData = { [ this.param(options) ]: { 
            identifier: data.identifier,
            scope_id: data.scope_id
          } }

    return encodeDataToUrl( url, urlData )

  }

  /**
   * Get children data url based on panel options 
   * @param {object} options Picker Panel options object containing its id and type definitions
   * @param {object} data Data object of item to access children data for, must have the id property set  
   * @return {string | undefined} Children data url, undefined if data in wrong format  
   */
  static childrenUrl(options, data) {

    if ( !data?.id )
      return

    return types.TH_CL.url + '/' + data.id + '/children'
  
  }

}
