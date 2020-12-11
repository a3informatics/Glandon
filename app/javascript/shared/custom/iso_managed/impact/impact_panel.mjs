import TabsLayout from 'shared/ui/tabs_layout'
import ImpactGraph from './impact_graph.mjs'
import ManagedItemsPanel from '../managed_items_panel'

/**
 * Impact Panel
 * @description Tab-based panel containing an Impact Graph and Table
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ImpactPanel {
    
    /**
     * Create an Impact Panel instance 
     * @param {Object} params Instance parameters
     * @param {string} params.selector JQuery selector of the panel 
     */
    constructor({
        selector = '#impact-panel'
    } = {}) {

        Object.assign( this, { 
            selector,
            // Impact Graph instance
            impactGraph: new ImpactGraph({
                selector: `${ selector } #impact-graph`,
                dataUrl: impactDataUrl,
                onDataLoaded: () => 
                    this.impactTable._render(this.impactGraph.rawData.nodes, true)
            }),
            // Impact table instance
            impactTable: new ManagedItemsPanel({
                selector: selector,
                deferLoading: true 
            })
        })

        TabsLayout.initialize()

    }
  

    /** Private **/


}
