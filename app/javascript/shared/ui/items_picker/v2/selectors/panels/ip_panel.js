import SelectablePanel from 'shared/base/selectable_panel'
import IPHelper from '../../support/ip_helper'

import { dtIndexColumns, dtCLIndexColumns, dtSimpleHistoryColumns, dtSimpleChildrenColumns } from 'shared/helpers/dt/dt_column_collections'
import { rdfTypesMap } from 'shared/helpers/rdf_types'
import { customBtn } from 'shared/helpers/dt/utils'

export default class PickerPanel {

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

    this.sp = this._initPanel()

  }

  destroy() {

  }

  load() {
    this.sp.loadData()
  }


  /*** Private ***/


  _initPanel() {

    return new SelectablePanel({
      tablePanelOptions: {
        selector: this.selector,
        url: this._dataUrl,
        param: this._param,
        count: this._count,
        deferLoading: true, 
        extraColumns: this._columns,
        buttons: [ this._refreshBtn ],
        tableOptions: this._tableOpts
      },
      ownershipColorBadge: true,
      showSelectionInfo: false,
      allowAll: this.tableId === 'children'
    })

  }

  _isType(type) {
    return this.type === rdfTypesMap[ type ]
  }

  
  /*** Getters ***/


  get _dataUrl() {

    switch ( this.tableId ) {

      case 'index':
        if ( this._isType( 'TH_CL' ) )
          return `${ this.type.url }/set_with_indicators?managed_concept%5Btype%5D=all`

        return this.type.url 
        
      case 'history':
        return `${ this.type.url }/history`

      case 'children':
        return `${ rdfTypesMap.TH_CL.url }/children`

    }

  }

  get _param() {

    if ( this._isType( 'TH_CLI' ) )
      return rdfTypesMap.TH_CL.param 

    return this.type.param 
  
  }

  get _count() {
    return 5000
  }

  get _columns() {

    switch ( this.tableId ) {

      case 'index':
        if ( this._isType( 'TH_CL' ) )
          return dtCLIndexColumns()

        return dtIndexColumns() 

      case 'history':
        return dtSimpleHistoryColumns()

      case 'children':
        return dtSimpleChildrenColumns()

    }

  }

  get _refreshBtn() {

    return customBtn({
        text: 'Refresh',
        action: () => this.load()
      })

  }

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