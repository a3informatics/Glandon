import D3Graph from 'shared/base/d3/d3_graph'
import D3Node from 'shared/base/d3/d3_node'

import { renderSimpleLinks as renderLinks } from 'shared/helpers/d3/renderers/links'
import { renderNodesSimple as renderNodes } from 'shared/helpers/d3/renderers/nodes'

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
   * @param {function} params.onDataLoaded Data load completed callback, receives raw data as first argument, optional
  */
  constructor({
    selector,
    dataUrl,
    nodeModule = D3Node,
    autoScale = true,
    zoomable = true,
    selectable = true,
    onDataLoaded = () => {}
  }) {

    super({
      selector,
      dataUrl,
      nodeModule,
      autoScale,
      zoomable,
      selectable,
      onDataLoaded
    });

  }


  /** Graph **/


  /**
   * Render the Force Graph
   * @return {TreeGraph} This instance for method chaining
   */
  render() {

    super.render();

    this._render();

    // Trigger keyup event to re-apply search on re-rendered items
    $( this.selector ).find( '#d3-search' )
                      .keyup();

    return this;
  
  }


  /******* Private *******/


  /** Graph **/


  /**
   * Render the Force Graph
   * @return {ForceGraph} This instance for method chaining
   */
  _render() {

    this.clearGraph();

    const { links, nodes } = this.rawData;

    // Render the graph
    this.graph.svg = this._newSVG();
    this.graph.g = this.graph.svg
                             .append('g');

    this.graph.links = renderLinks({
      target: this.graph.g,
      data: links
    });

    this.graph.nodes = renderNodes({
      target: this.graph.g,
      data: nodes,
      selectable: this.selectable,
      onClick: d => this._onNodeClick( new this.Node(d) ),
      onDblClick: d => this._onNodeDblClick( new this.Node(d) )
    });

    // Render extras and callback to onRenderComplete 
    super._render();

    // Start force simulation
    this._startSimulation( links, nodes );

    return this;

  }


  /** Events **/


  /**
   * Process and render raw graph data from the server
   * @param {Object} rawData Compatible graph data fetched from the server
   */
  _onDataLoaded(rawData) {

    super._onDataLoaded( rawData );

    this.render()
        .reCenter();

  }


  /** Simulation **/

  
  /**
   * Set up and start the force simulation on the graph 
   * @param {Array} links Raw links data to apply simulation to 
   * @param {Array} nodes Raw nodes data to apply simulation to 
   * @param {int} distance Distance between nodes
   */
  _startSimulation(links, nodes, distance = 100) {

    const { width, height } = this._props.svg,
          { d3 } = this;

    return d3.forceSimulation( nodes )

      .force( 'link', d3.forceLink()
                        .id( d => d.id )
                        .distance( distance )
                        .links( links ) )

      .force( 'charge', d3.forceManyBody()
                          .strength( -400 ) )

      .force( 'center', d3.forceCenter( width / 2, height / 2 ) )
      .on( 'tick', () => this._onSimulationTick() );

  }

  /**
   * Update graph state on current simulation tick 
   */
  _onSimulationTick() {

    // Update Links coordinates
    this.graph.links
      .attr( 'x1', d => d.source.x )
      .attr( 'y1', d => d.source.y )
      .attr( 'x2', d => d.target.x )
      .attr( 'y2', d => d.target.y );

    // Update Nodes coordinates
    this.graph.nodes
      .attr( 'transform', d => `translate(${d.x}, ${d.y})` )
      .attr( 'cx', d => d.x )
      .attr( 'cy', d => d.y );

  }


  /** Graph Control **/


  /**
   * Re-center the graph
   */
  _reCenter() {
    super._reCenter( 0, 0 );
  }


  /** Graph utils **/


  /**
   * Load D3 module asynchronously and init graph afterwards
   */
  async _loadD3() {

    this._loading( true );

    let d3 = await import( /* webpackPrefetch: true */ './d3_force_graph' );
    this.d3 = d3.default;

    super._loadD3();

  }

}