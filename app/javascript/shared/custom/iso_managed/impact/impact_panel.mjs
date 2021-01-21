import TabsLayout from 'shared/ui/tabs_layout'
import ImpactGraph from './impact_graph.mjs'
import ManagedItemsPanel from '../managed_items_panel'

import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'

/**
 * Impact Panel
 * @description Tab-based panel containing an Impact Graph and Table
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ImpactPanel {

  constructor({
    selector = '#impact-panel'
  } = {}) {

    Object.assign( this, { selector } )
    
    Object.assign( this, {
      impactGraph: this._initImpactGraph(),
      impactTable: this._initImpactTable()
    })

    TabsLayout.initialize()

    // Set tab switch event handler
    TabsLayout.onTabSwitch( selector, tab => this._onTabSwitch( tab ) )

  }

  /**
   * Initialize a new ImpactGraph  
   * @return {ImpactGraph} Instance 
   */
  _initImpactGraph() {

    return new ImpactGraph({
      selector: `${ this.selector } #impact-graph`,
      dataUrl: impactDataUrl,
      onDataLoaded: () => this._onImpactDataLoaded()
    })

  }

  /**
   * Initialize a new ManagedItemsPanel - Impact Table 
   * @return {ManagedItemsPanel} Instance 
   */
  _initImpactTable() {

    return new ManagedItemsPanel({
      selector: this.selector,
      deferLoading: true,
      buttons: [csvExportBtn(), excelExportBtn()],
      tableOptions: {
        order: [[2, 'asc']]
      }
    })

  }

  /**
   * On tab-switch event in Tab Layout callback, ensures proper display
   * @param {string} tab Name of the tab switched into 
   */
  _onTabSwitch(tab) {

    switch (tab) {

      case 'tab-table':
        this.impactTable.table.columns.adjust()
        break

      case 'tab-graph':
        this.impactGraph._onResize()
        break

    }

  }

  /**
   * On Impact Graph data load callback, clone and render data in Impact Table 
   */
  _onImpactDataLoaded() {

    const clonedData = JSON.parse( JSON.stringify( this.impactGraph.rawData.nodes ) )
    this.impactTable._render( clonedData, true )

  }

}
