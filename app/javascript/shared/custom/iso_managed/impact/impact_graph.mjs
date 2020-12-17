import ForceGraph from 'shared/base/d3/force_graph/force_graph'
import ImpactNode from './impact_node'

import { D3Tooltip } from 'shared/helpers/d3/renderers/tooltip'
import { D3Actions } from 'shared/helpers/d3/renderers/actions'

import { renderWithFilledIconsLabels as renderStyledNodes } from 'shared/helpers/d3/renderers/nodes'
import { cropText } from 'shared/helpers/strings' 
import { managedConceptRef } from 'shared/ui/strings'
import { iconBtn } from 'shared/ui/buttons'
import { alerts } from 'shared/ui/alerts'

/**
 * Impact Graph 
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
  * @param {module} params.nodeModule Custom Node module class (wrapper), optional [default=ImpactNode]
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

  /**
   * Clear the graph contents
   * @extends clearGraph parent implementation
   */
  clearGraph() {

    super.clearGraph()
    D3Tooltip.destroy()
    D3Actions.destroy()

  }


  /******* Private *******/


  /**
   * Initialize D3Tooltip and D3Actions modules with D3 library
   * @extends _init parent implementation
   */
  _init() {

    super._init()
    D3Tooltip.init( this.d3 )
    D3Actions.init( this.d3 )

  }

  /**
   * Set event listeners, handlers
   */
  _setListeners() {

    super._setListeners();

    // Node actions View Impact button click, load node's impact data 
    $( this.selector ).on( 'click', '#load-impact', () =>
      this.loadData( this.selected.data.impact_path )
    )

    // Node actions Show History button click, open history page in new tab 
    $( this.selector ).on( 'click', '#show-history', () => 
      window.open( this.selected.data.history_path, '_blank' ) 
    )

  }


  /** Select **/


  /**
   * Select a given node and update styling, render node-actions
   * @extends _selectNode parent implementation
   * @param {ImpactNode} node Target node instance
   * @param {boolean} toggle Specifies if node deselect allowed, optional [default=true]
   */
  _selectNode(node, toggle = true) {

    D3Actions.hide();

    super._selectNode( node, toggle )

    if ( this.selected )
      this._renderActions( this.selected )

  }


  /** Events **/


  /**
   * Re-render node-actions on zoom (to keep position relative to node)
   * @extends _onZoom parent implementation
   */
  _onZoom() {

    super._onZoom()
    this._renderActions( this.selected )

  }

  /**
   * Process and render raw graph data from the server, load referenced item data
   * @extends _onDataLoaded parent implementation
   * @param {Object} rawData Compatible graph data fetched from the server (nodes & links)
   */
  _onDataLoaded({nodes, links}) {

    // Display message when no impact data returned 
    if ( !links.length )
      alerts.warning( 'Item has no Impact', this._alertDiv )
  
    // Set first Node instance as Root Node on initial data load 
    if ( this.dataEmpty ) 
      new this.Node( nodes[0], false ).setRoot() 

    // Set impactLoaded flag on current Node
    else 
      this.selected.setImpactLoaded()

    // Merge fetched data with existing impact data 
    this._mergeData( nodes, links )

    super._onDataLoaded()

  }

  /**
   * Update graph state on current simulation tick 
   */
  _onSimulationTick() {

    super._onSimulationTick()
    this._renderActions( this.selected ) 

  }


  /** Data **/


  /**
   * Merge new Node and Link data with the current Graph Data, excluding duplicates 
   * @param {Array} newNodes New Node objects to merge with Graph Data
   * @param {Array} newLinks New Link objects to merge with Graph Data
   */
  _mergeData(newNodes, newLinks) {

    // Get current Node IDs
    const allNodes = this.rawData.nodes.map( node => node.id )

    // Filter new Nodes and exclude duplicates 
    const newNodesUnique = newNodes.filter( node => 
            !allNodes.includes( node.id ) 
          )

    // Normalizes a link object into a string of sorted source & target IDs
    const linkToString = l => 
      [ l.source.id || l.source, l.target.id || l.target ].sort().join('')

    // Get current Link IDs (normalized)
    const allLinks = this.rawData.links.map( linkToString )

    // Filter new Links and exclude duplicated 
    const newLinksUnique = newLinks.filter( link => !allLinks.includes( linkToString( link ) ) )

    // Merge old and new data 
    this.rawData.links = [ ...this.rawData.links, ...newLinksUnique ]
    this.rawData.nodes = [ ...this.rawData.nodes, ...newNodesUnique ]

  }


  /** Renderers **/


  /**
   * Render custom additional elements in the graph
   * @override parent implementation
   */
  _renderCustom() {

    this._renderNodes()

    D3Tooltip.new();
    D3Actions.new( this.selector, this._actionButtons )

  }

  /**
   * Render Nodes in custom style (with icons and labels)
   */
  _renderNodes() {

    // Add Icons and Labels to rendered Nodes
    this.graph.nodes = renderStyledNodes({
      nodes: this.graph.nodes,
      nodeIcon: this.Node.icon,
      nodeColor: this.Node.color,
      labelProperty: d => cropText( d.identifier, 10 ),
      onHover: d => this._renderTooltip( new this.Node(d) ),
      onHoverOut: d => D3Tooltip.hide()
    })

  }


  /** Node Actions **/


  /**
   * Render node-actions element with buttons at a given node
   * @param {ImpactNode} node Node instance to render the node-actions element at
   */
  _renderActions(node) {

    if ( !node )
      return;

    // Toggle edit button depending on node
    D3Actions.actions.find( '#load-impact' )
                     .toggleClass( 'disabled', node.impactLoaded )

    D3Actions.show( node, { offsetY: -12 } )

  }

  /**
   * Get the HTMLs for Action buttons to be rendered in node-actions
   * @return {Array} Array of HTML strings for node-action icon buttons
   */
  get _actionButtons() {

    return [
      iconBtn({ icon: 'view', color: 'light', id: 'load-impact', ttip: "View Impact" }),
      iconBtn({ icon: 'old', color: 'light', id: 'show-history', ttip: "Item History" }),
    ]

  }


  /** Tooltip **/


  /**
   * Render tooltip contents and show
   * @param {ImpactNode} node Node instance to show the tooltip at
   */
  _renderTooltip(node) {

    let html = 
    `<div> 
      <div class='font-regular' style='color: ${ node.color }'> 
        ${ node.rdfName } 
      </div>
      ${ node.isRoot ? '<div class="text-tiny"> <i>Source Node</i> </div>' : '' }
      ${ managedConceptRef(node.data) }
    </div>`

    D3Tooltip.show( html )

  }

}