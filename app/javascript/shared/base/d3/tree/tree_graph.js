import D3Graph from 'shared/base/d3/d3_graph'
import TreeNode from 'shared/base/d3/tree/tree_node'

import { renderTreeLinks as renderLinks } from 'shared/helpers/d3/renderers/links'
import { renderNodesTree as renderNodes } from 'shared/helpers/d3/renderers/nodes'

import { isInViewport } from 'shared/helpers/utils'

/**
 * Tree Graph Base Class
 * @description Extensible D3-based Tree Graph module
 * @extends D3Graph base module 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TreeGraph extends D3Graph {

  /**
   * Create a Tree Graph instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the editor panel
   * @param {string} params.dataUrl Url to fetch the graph data from
   * @param {module} params.nodeModule Custom Node module class (wrapper), optional [default=TreeNode]
   * @param {boolean} params.autoScale Determines whether the graph container should scale height to fit window height, optional [default=true]
   * @param {boolean} params.zoomable Determines whether the graph can be zoomed and dragged, optional [default=true]
   * @param {boolean} params.selectable Determines whether the nodes can be selected by clicking, optional [default=true]
   * @param {boolean} params.keyControls Determines whether the nodes can be selected with keyboard arrow keys, optional [default=true]
   * @param {function} params.onDataLoaded Data load completed callback, receives raw data as first argument, optional
   */
  constructor({
    selector,
    dataUrl,
    nodeModule = TreeNode,
    autoScale = true,
    zoomable = true,
    selectable = true,
    keyControls = true,
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
    })

    Object.assign( this, {
      keyControls
    });

  }

  
  /** Graph **/


  /**
   * Render the Tree Graph
   * @return {TreeGraph} This instance for method chaining
   */
  render() {

    super.render();

    // Map the node data to the tree
    this.graph.root = this.graph.tree( this.graph.root );

    this._render();

    // Trigger keyup event to re-apply search on re-rendered items
    $( this.selector ).find( '#d3-search' )
                      .keyup();

    return this;

  }

  /**
   * Expand all nodes in the Graph
   * @param {boolean} recenter Value specifying whether the graph should be centered after render, optional [default=true]
   * @return {TreeGraph} This instance for method chaining
   */
  expandAll(recenter = true) {

    if ( this.graph.root ) {

      this._expandAll( new this.Node( this.graph.root ) );
      this.render()._restoreGraph()

      if (recenter)
        this.reCenter();

    }

    return this;

  }

  /**
   * Collapse all nodes in the Graph and re-draw
   * @return {TreeGraph} This instance for method chaining
   */
  collapseAll() {

    this._collapseAll();
    this.render()._restoreGraph().reCenter();

    return this;

  }

  /**
   * Collapse all nodes except given node and its direct parents and re-draw
   * @param {TreeNode} node Node instance to exclude from collapse
   * @return {TreeGraph} This instance for method chaining
   */
  collapseExcept(node) {

    if ( node ) {

      this._collapseExcept( node );
      this.render()._restoreGraph().reCenter();

    }

    return this;

  }

  /**
   * Collapse / expand (toggle) Node and re-draw
   * @param {TreeNode} node Node instance to toggle
   * @return {TreeGraph} This instance for method chaining
   */
  collapseOrExpand(node) {

    if ( node ) {
      node.collapseOrExpand();
      this.render()._restoreGraph();
    }

    return this;

  }

  /**
   * Enable graph key navigation
   */
  keysEnable() {
    this.keyControls = true;
  }

  /**
   * Disable graph key navigation
   */
  keysDisable() {
    this.keyControls = false;
  }


  /** Getters **/


  /**
   * Get all nodes visible in the graph
   * @return {array} Collection of all nodes cast to Node instances
   */
  get allNodes() {

    return this.graph.root.descendants()
                          .map( d => new this.Node(d) );

  }


  /******* Private *******/


  /**
   * Set event listeners & handlers
   */
  _setListeners() {

    super._setListeners();

    // Collapse graph nodes on btn click
    $( this.selector ).find( '#collapse-except-graph' )
                      .on( 'click', () => this.collapseExcept( this.selected ) );

    // Collapse graph nodes on btn click
    $( this.selector ).find( '#collapse-graph' )
                      .on( 'click', () => this.collapseAll() );

    // Expand graph nodes on btn click
    $( this.selector ).find( '#expand-graph' )
                      .on( 'click', () => this.expandAll() );

    // Key navigation event handler
    if ( this.keyControls )
      $( 'body' ).on( 'keydown', e => this._onKeyPress(e) );

    // Search graph enable / disable graph keys controls on focus out / in
    if ( this.keyControls )
      $( this.selector ).find( '#d3-search' )
                        .on( 'focusin', e => this.keysDisable() )
                        .on( 'focusout', e => this.keysEnable() );

  }

  /**
   * Preprocess data and convert it into a D3 hierarchy
   * Override method for custom implementation
   * @param {Object} rawData Compatible graph data fetched from the server
   */
  _preprocessData(rawData) {

    return this.d3.hierarchy( rawData, d => d.children );

  }


  /** Graph Control **/


  /**
   * Focus a given node into view, specifiable zoom and select
   * @override parent implementation, reverses node x and y coords 
   */
  _focusOn(node, zoom, select) {

    let scale = zoom ? 1.15 : this.graph.lastTransform.k,
        tX = (this._props.svg.width / 2) - ( node.d.y + (node.width / 2) ) * scale,
        tY = (this._props.svg.height / 2) - node.d.x * scale,
        transform = this.d3.zoomIdentity.translate( tX, tY ).scale( scale );

    // Call transform to given node
    this.graph.svg.call( this.graph.zoom.transform, transform );

    if ( select )
      this.selectNode( node, false );

  }

  /**
   * Expand all nodes in the Graph
   */
  _expandAll(node) {

    node.expand();

    if ( node.hasChildren )
      node.children.forEach( this._expandAll.bind(this) );

  }

  /**
   * Collapse all nodes in the Graph
   */
  _collapseAll() {

    this.expandAll();
    this.allNodes.forEach( (node) => node.collapse() );

  }

  /**
   * Collapse all nodes except given node and its direct parents
   * @param {TreeNode} node Node instance to exclude from collapse
   */
  _collapseExcept(node) {

    node.expand();

    while ( node && node.parent ) {

      for ( let child of node.parent.children ) {
        if ( child.d != node.d )
          child.collapse();
      }

      node = node.parent;
    }

  }


  /** Events **/


  /**
   * Process and render raw graph data from the server
   * @param {Object} rawData Compatible graph data fetched from the server
   */
  _onDataLoaded(rawData) {

    super._onDataLoaded( rawData );

    // Convert raw data to d3 hierarchy
    this.graph.root = this._preprocessData( rawData );
    this.render().reCenter();

  }

  /**
   * Node right click event, prevent default behavior, collapse / expands node's children
   * Extend method for custom behavior
   * @param {TreeNode} node Clicked TreeNode instance
   */
  _onNodeRightClick(node) {

    // Prevent context menu display
    this.d3.event.preventDefault();
    this.collapseOrExpand( node );

  }

  /**
   * On keyup event, handle graph key navigation and controls
   * Extend / override method for custom behavior
   * @param {event} e Keyup event object
   */
  _onKeyPress(e) {

    if ( !this.keyControls || this.loading || e.ctrlKey || e.altKey || e.metaKey )
      return;

    if ( this.selectable && this.selected )
      this._keyNavigation( e );

    if ( this._props.keys.includes( e.which ) )
      this._keyControls( e );

  }


  /** Keys **/


  /**
   * Handle graph selected node navigation
   * Extend / override method for custom behavior
   * @param {event} e Key event object
   */
  _keyNavigation(e) {

    if ( e.which === 37 && !e.shiftKey ) // Arrow Left
      this.selectNode( this.selected.parent );

    else if ( e.which === 38 && !e.shiftKey ) // Arrow Up
      this.selectNode( this.selected.previous );

    else if ( e.which === 39 && !e.shiftKey ) // Arrow Right
      this.selectNode( this.selected.middleChild );

    else if ( e.which === 40 && !e.shiftKey ) // Arrow Down
      this.selectNode( this.selected.next );

    else
      return;

    // Focus on Node if out of viewport
    if ( !isInViewport( $(this.graph.svg.node()), this.selected.$, 1 ) )
      this.focusOn( this.selected, false, false );

    e.preventDefault();

  }

  /**
   * Handle graph key controls
   * Extend / override method for custom behavior
   * @param {event} e Key event object
   */
  _keyControls(e) {

    if ( e.shiftKey && e.which === 67 ) // Shift + C
      this.collapseAll();

    else if ( e.shiftKey && e.which === 88 ) // Shift + X
      this.collapseExcept( this.selected );

    else if ( e.shiftKey && e.which === 69 ) // Shift + E
      this.expandAll( false );

    else if ( !e.shiftKey && e.which === 67 ) // C
      this.reCenter();

    else if ( e.which === 32 && this.selected ) // Spacebar
      this.collapseOrExpand( this.selected );

    else
      return;

    e.preventDefault()

  }


  /** Renderers **/


  /**
   * Clear and render the D3 Tree Graph based on instance data
   */
  _render() {

    this.clearGraph();

    // Render the graph
    this.graph.svg = this._newSVG();
    this.graph.g = this.graph.svg.append('g');

    this.graph.links = renderLinks({
      target: this.graph.g,
      data: this.graph.root.descendants().slice(1)
    });

    this.graph.nodes = renderNodes({
      target: this.graph.g,
      data: this.graph.root.descendants(),
      selectable: this.selectable,
      onClick: d => this._onNodeClick( new this.Node(d) ),
      onDblClick: d => this._onNodeDblClick( new this.Node(d) ),
      onRightClick: d => this._onNodeRightClick( new this.Node(d) )
    });

    super._render();

    return this;

  }


  /** Graph utils **/


  /**
   * Initialize Graph functionalities, called on each re-render
   * @return {TreeGraph} This instance for method chaining
   */
  _initGraph() {

    super._initGraph();

    // Initialize a new D3 Tree graph
    this.graph.tree = this._newTree();

    return this;

  }

  /**
   * Get a new D3 tree instance with custom nodeSize
   * Override for custom implementation
   * @return {D3} New D3 tree graph instance
   */
  _newTree() {

    return this.d3.tree()
                  .nodeSize( [this._props.tree.nodeHeight, this._props.tree.nodeWidth] );

  }

  /**
   * Graph properties definitions
   * Extend and override method to customize
   * @return {Object} Graph properties for tree, svg, zoom, allowed keys
   */
  get _props() {

    const props = super._props;

    props.tree = {
      nodeWidth: 200,
      nodeHeight: 28
    }

    props.keys = [ 32, 38, 40, 67, 69, 88 ]

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
