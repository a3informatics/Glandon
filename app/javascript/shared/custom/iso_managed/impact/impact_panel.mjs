import TabsLayout from 'shared/ui/tabs_layout'
import ImpactGraph from './impact_graph.mjs'

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
            impactGraph: new ImpactGraph({
                selector: `${ selector } #impact-graph`,
                dataUrl: impactDataUrl
            })
        })

        TabsLayout.initialize()

    }
  

    /** Private **/


}
