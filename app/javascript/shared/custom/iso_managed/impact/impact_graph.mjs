import ForceGraph from 'shared/base/d3/force_graph/force_graph'
import ImpactNode from './impact_node'

import { D3Tooltip } from 'shared/helpers/d3/renderers/tooltip'
import { D3Actions } from 'shared/helpers/d3/renderers/actions'

import { renderWithFilledIconsLabels } from 'shared/helpers/d3/renderers/nodes'
import { cropText } from 'shared/helpers/strings' 
import { managedConceptRef } from 'shared/ui/strings'
import { iconBtn } from 'shared/ui/buttons'

import TestData from './test_data'

/**
 * Force Graph Base Class
 * @description Extensible D3-based Force Graph module
 * @extends D3Graph base module 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ImpactGraph extends ForceGraph {

 /**
  * Create an Impact Graph instance
  * @param {Object} params Instance parameters
  * @param {string} params.selector JQuery selector of the editor panel
  * @param {string} params.dataUrl Url to fetch the graph data from
  * @param {module} params.nodeModule Custom Node module class (wrapper), optional [default=TreeNode]
  * @param {function} params.onDataLoaded Data load completed callback, receives raw data as first argument, optional
  */
  constructor({
    selector,
    dataUrl,
    nodeModule = ImpactNode,
    onDataLoaded = () => {}
  }) {

    super({
      selector,
      dataUrl,
      nodeModule,
      onDataLoaded
    })

  }

  loadData() {
    this._onDataLoaded( TestData );
    this._loading( false );
  }

  /**
   * Clear the graph contents
   * @extends clearGraph parent implementation
   */
  clearGraph() {

    super.clearGraph();
    D3Tooltip.destroy();
    D3Actions.destroy();

  }


  /******* Private *******/


  /**
   * Initialize D3Tooltip and D3Actions modules with D3 library
   * @extends _init parent implementation
   */
  _init() {

    super._init();
    D3Tooltip.init( this.d3 );
    D3Actions.init( this.d3 );

  }


  /** Select **/


  /**
   * Select a given node and update styling, render node-actions
   * @extends _selectNode parent implementation
   * @param {FormNode} node Target node instance
   * @param {boolean} toggle Specifies if node deselect allowed, optional [default=true]
   */
  _selectNode(node, toggle = true) {

    D3Actions.hide();

    super._selectNode( node, toggle );

    if ( this.selected )
      this._renderActions( this.selected );

  }


  /** Events **/


  /**
   * Re-render node-actions on zoom (to keep position relative to node)
   * @extends _onZoom parent implementation
   */
  _onZoom() {

    super._onZoom();
    this._renderActions( this.selected );

  }


  /** Renderers **/


  /**
   * Render custom additional elements in the graph
   * @override parent implementation
   */
  _renderCustom() {

    this._renderNodes();

    D3Tooltip.new();

    D3Actions.new( this.selector, this._actionButtons );

  }

  /**
   * Render Nodes in custom style (with icons and labels)
   */
  _renderNodes() {

    // Add Icons and Labels to rendered Nodes
    this.graph.nodes = renderWithFilledIconsLabels({
      nodes: this.graph.nodes,
      nodeIcon: this.Node.icon,
      nodeColor: this.Node.color,
      labelProperty: d => cropText( d.identifier, 10 ),
      onHover: d => this._renderTooltip( new this.Node(d) ),
      onHoverOut: d => D3Tooltip.hide()
    })

    // Override nodes class attribute to build a custom class list
    // this.graph.nodes.attr( 'class', d => this._nodeClassList( new this.Node(d) ) );

  }


  /** Node Actions **/


  /**
   * Render node-actions element with buttons at a given node
   * @param {FormNode} node Node instance to render the node-actions element at
   */
  _renderActions(node) {

    if ( !node )
      return;

    // // Toggle edit button depending on node
    // D3Actions.actions.find( '#edit-node' )
    //                  .toggle( node.editAllowed );

    D3Actions.show( node, 0, -12 );

  }

  /**
   * Get the HTMLs for Action buttons to be rendered in node-actions
   * @return {Array} Array of HTML strings for node-action icon buttons
   */
  get _actionButtons() {

    return [
      iconBtn({ icon: 'plus', color: 'light', id: 'load-impact', ttip: 'Load Data' }),
      iconBtn({ icon: 'history', color: 'light', id: 'show-history', ttip: 'Item History' }),
    ]

  }


  /** Tooltip **/


  /**
   * Render tooltip contents and show
   * @param {TagNode} node Node instance to show the tooltip at
   */
  _renderTooltip(node) {

    let html = `<div>` +
      `<div class='font-regular' style='color: ${ node.color }'> ${ node.rdfName } </div>
      ${ managedConceptRef(node.data) }
    </div>`;

    D3Tooltip.show( html );

  }

}