import TabsLayout from 'shared/ui/tabs_layout'
import ImpactGraph from './impact_graph.mjs'
import ManagedItemsPanel from '../managed_items_panel'

import { csvExportBtn } from 'shared/helpers/dt/utils'

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

  }

  _initImpactGraph() {

    return new ImpactGraph({
      selector: `${ this.selector } #impact-graph`,
      dataUrl: impactDataUrl,
      onDataLoaded: () => 
        this.impactTable._render( this.impactGraph.rawData.nodes, true )
    })

  }

  _initImpactTable() {

    return new ManagedItemsPanel({
      selector: this.selector,
      deferLoading: true,
      buttons: [ csvExportBtn ]
    })

  }

}
