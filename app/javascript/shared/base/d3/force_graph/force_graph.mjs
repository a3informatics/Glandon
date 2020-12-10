import D3Graph from 'shared/base/d3/d3_graph'

import * as d3 from 'd3'
import { renderLinksSimple as renderLinks } from 'shared/helpers/d3/renderers/links'
import { renderNodesSimple as renderNodes } from 'shared/helpers/d3/renderers/nodes'

import { isInViewport } from 'shared/helpers/utils'

/**
 * Force Graph Base Class
 * @description Extensible D3-based Force Graph module
 * @extends D3Graph base module 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ForceGraph extends D3Graph {

 /**
  * Create a Force Graph instance
  * @param {Object} params Instance parameters
  * @param {string} params.selector JQuery selector of the editor panel
  * @param {string} params.dataUrl Url to fetch the graph data from
  * @param {module} params.nodeModule Custom Node module class (wrapper), optional [default=TreeNode]
  * @param {boolean} params.autoScale Determines whether the graph container should scale height to fit window height, optional [default=true]
  * @param {boolean} params.zoomable Determines whether the graph can be zoomed and dragged, optional [default=true]
  * @param {boolean} params.selectable Determines whether the nodes can be selected by clicking, optional [default=true]
  */
  constructor({
    selector,
    dataUrl,
    nodeModule,
    autoScale = true,
    zoomable = true,
    selectable = true
  }) {

    super({
      selector,
      dataUrl,
      nodeModule,
      autoScale,
      zoomable,
      selectable
    })

    Object.assign( this, {
        
    });

  }

  loadData() {
    
  }


  /** Graph **/


  /**
   * Render the Force Graph
   * @return {TreeGraph} This instance for method chaining
   */
  render() {


  }

  /** Graph utils **/



  /**
   * Graph properties definitions
   * Extend and override method to customize
   * @return {Object} Graph properties for tree, svg, zoom, allowed keys
   */
  get _props() {

    const props = super._props;

    return props;

  }

  /**
   * Load D3 module asynchronously and init graph afterwards
   */
  async _loadD3() {

    this._loading( true );

    let d3 = await import( /* webpackPrefetch: true */ 'shared/base/d3/tree/d3_tree' );
    this.d3 = d3.default;

    super._loadD3();

  }

}