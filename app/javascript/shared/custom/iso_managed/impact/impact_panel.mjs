import TabsLayout from 'shared/ui/tabs_layout'
import ForceGraph from '../../../base/d3/force_graph/force_graph.mjs'

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
        selector = '#impact-panel #d3'
    } = {}) {

        Object.assign( this, { 
            selector,
            impactGraph: new ForceGraph({
                selector
            })
        })

        TabsLayout.initialize()

    }
  

    /** Private **/


}
