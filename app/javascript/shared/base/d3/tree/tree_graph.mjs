import d3 from 'shared/base/d3/tree/d3_tree'
import TreeNode from 'shared/base/d3/tree/tree_node'

import { renderLinksSimple as renderLinks } from 'shared/helpers/d3/renderers/links'
import { renderNodesSimple as renderNodes } from 'shared/helpers/d3/renderers/nodes'

import { $get } from 'shared/helpers/ajax'
import { isInViewport } from 'shared/helpers/utils'
import { findInString } from 'shared/helpers/strings'
import { renderSpinnerIn$, removeSpinnerFrom$ } from 'shared/ui/spinners'
import colors from 'shared/ui/colors'

/**
 * Tree Graph Base Class
 * @description Extensible D3-based Tree Graph module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TreeGraph {

  /**
   * Create a Tree Graph instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the editor panel
   * @param {string} params.dataUrl Url to fetch the graph data from
   * @param {module} params.nodeModule Custom Node module class (wrapper), optional [default=TreeNode]
   * @param {boolean} params.autoScale Determines whether the graph container should scale height to fit window height, optional [default=true]
   * @param {boolean} params.zoomable Determines whether the graph can be zoomed and dragged, optional [default=true]
   * @param {boolean} params.selectable Determines whether the nodes can be selected by clicking, optional [default=true]
   * @param {boolean} params.keyNavigation Determines whether the nodes can be selected with keyboard arrow keys, optional [default=true]
   */
  constructor({
    selector,
    dataUrl,
    nodeModule = TreeNode,
    autoScale = true,
    zoomable = true,
    selectable = true,
    keyNavigation = true
  }) {

    Object.assign( this, {
      dataUrl, selector, autoScale, zoomable, selectable, keyNavigation,
      Node: nodeModule
    });

    this._init();

  }

  /**
   * Fetch graph data from the server
   * @param {string} url Source data url (overrides dataUrl), optional
   */
  loadData(url) {

    // Overwrite instance's dataUrl
    if ( url )
      this.dataUrl = url;

    this._loading( true );

    // Get request, handles response
    $get({
      url: this.dataUrl,
      done: ( rawData ) => this._onDataLoaded( rawData ),
      always: () => this._loading( false )
    });

  }


  /** Graph **/


  /**
   * Render the Tree Graph
   * @return {TreeGraph} This instance for method chaining
   */
  render() {

    // Initialize graph if not already
    if ( !this.graph.tree )
      this._initGraph();

    // Map the node data to the tree
    this.graph.root = this.graph.tree( this.graph.root );

    this._render();

    return this;

  }

  /**
   * Re-center the graph
   * @requires zoomable parameter set to true
   * @return {TreeGraph} This instance for method chaining
   */
  reCenter() {

    if ( this.zoomable && this.graph.svg )
      this._reCenter();

    return this;

  }

  /**
   * Focus a given node into view, optional zoom and select
   * @requires zoomable enabled
   * @param {TreeNode} node Target node instance
   * @param {boolean} zoom Specifies if the node should be zoomed to, optional [default=true]
   * @param {boolean} select Specifies if the node should be selected, optional [default=true]
   */
  focusOn(node, zoom = true, select = true) {

    if ( this.zoomable && this.graph.svg && node.exists )
      this._focusOn( node, zoom, select );

    return this;

  }

  /**
   * Clear the graph contents
   */
  clearGraph() {

    d3.select(`${this.selector} #d3 svg`)
           .remove();

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


  /** Search **/


  /**
   * Search through nodes in graph and mark matching results and re-draw
   * @param {string} searchText The text to search for
   */
  search(searchText) {

    this.clearSearch();

    if ( searchText !== '' )
      this._search( searchText );

  }

  /**
   * Get the graph nodes marked as search-match
   * @return {D3} Selection of nodes with the search-match class
   */
  get searchMatches() {

    return d3.selectAll(`${this.selector} .node.search-match`);

  }

  /**
   * Clear the search from the graph, remove styling
   * @param {boolean} clearInput Specifies if the search input should be cleared, optional [default=false]
   */
  clearSearch(clearInput = false) {

    this.searchIndex = 0;   // Reset search index
    $(this.selector).find( '.search-match' )
                    .removeClass( 'search-match' );

    this._renderSearchCount();  // Update search count display

    if ( clearInput )
      $(this.selector).find('#d3-search')
                      .val('');

  }


  /** Select **/


  /**
   * Select a given node and update styling
   * @requires selectable parameter set to true
   * @param {TreeNode} node Target node instance
   * @param {boolean} toggle Specifies if node deselect allowed, optional [default=true]
   */
  selectNode(node, toggle = true) {

    if ( this.selectable && node )
      this._selectNode(node, toggle);

  }

  /**
   * Get the currently selected node
   * @return {(TreeNode | null)} TreeNode instance or null if no node selected
   */
  get selected() {

    let selected = d3.select(`${this.selector} .node.selected`);

    // Return null if selection is empty
    if ( selected.empty() )
      return null;

    return new this.Node( selected.data()[0] );

  }


  /** Getters **/


  /**
   * Get the maximum depth of the data tree
   * @return {int} The maximum depth of the current data tree
   */
  get treeDepth() {
    return this.graph.root.height;
  }

  /**
   * Get all nodes visible in the graph
   * @return {array} Collection of all nodes cast to TreeNode instances
   */
  get allNodes() {

    return d3.selectAll(`${this.selector} .node`)
                    .data()
                    .map( (d) => new this.Node(d) );

  }


  /******* Private *******/


  /**
   * Create instance graph object, set listeners, initial resize
   */
  _init() {

    this.graph = {};
    this._setListeners();
    this._onResize();
    this.loadData();

  }

  /**
   * Set event listeners & handlers
   */
  _setListeners() {

    // Resize graph on window resize event
    $(window).on( 'resize', () => this._onResize() );

    // Center graph on btn click
    $(this.selector).find('#center-graph')
                    .on( 'click', () => this.reCenter() );

    // Collapse graph nodes on btn click
    $(this.selector).find('#collapse-except-graph')
                    .on( 'click', () => this.collapseExcept( this.selected ) );

    // Collapse graph nodes on btn click
    $(this.selector).find('#collapse-graph')
                    .on( 'click', () => this.collapseAll() );

    // Expand graph nodes on btn click
    $(this.selector).find('#expand-graph')
                    .on( 'click', () => this.expandAll() );

    // Clear Search stylings and field value on btn click
    $(this.selector).find('#d3-clear-search')
                    .on( 'click', () => this.clearSearch( true ) );

    // Search graph on input key up event
    $(this.selector).find('#d3-search').on( 'keyup', (e) => this._onSearchInput(e) );

    if ( this.selectable && this.keyNavigation )
      $('body').on('keydown', (e) => this._onKeyPress(e) );

  }

  /**
   * Preprocess data and convert it into a D3 hierarchy
   * Override method for custom implementation
   * @param {Object} rawData Compatible graph data fetched from the server
   */
  _preprocessData(rawData) {

    return d3.hierarchy( rawData, (d) => d.children );

  }


  /** Graph Control **/


  /**
   * Focus a given node into view, specifiable zoom and select, private
   * @param {TreeNode} node Target node instance
   * @param {boolean} zoom Specifies if the node should be zoomed to
   * @param {boolean} select Specifies if the node should be selected
   */
  _focusOn(node, zoom, select) {

    let scale = zoom ? 1.15 : this.graph.lastTransform.k,
        tX = (this._props.svg.width / 2) - ( node.d.y + (node.width / 2) ) * scale,
        tY = (this._props.svg.height / 2) - node.d.x * scale,
        transform = d3.zoomIdentity.translate( tX, tY ).scale( scale );

    // Call transform to given node
    this.graph.svg.call( this.graph.zoom.transform, transform );

    if (select)
      this.selectNode( node, false );

  }

  /**
   * Re-center the graph
   */
  _reCenter() {

    let tX = this._props.svg.margin,
        tY = this._props.svg.height / 2;

    this.graph.svg.call(
      this.graph.zoom.transform,
      d3.zoomIdentity.translate( tX, tY )
    );

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


  /** Search **/


  /**
   * Search through displayed nodes in graph and mark matching results
   * @param {string} searchText The text to search for
   * @param {string} property Data property to compare, [default=label]
   */
  _search(searchText, property = 'label') {

    // Find matches
    let matches = d3.selectAll(`${this.selector} .node`)
                         .filter( (n) => findInString( searchText, n.data[property] ) )
                         .nodes();

    $( matches ).addClass('search-match'); // Mark matching nodes

    // Update search count
    this._renderSearchCount();

  }

  /**
   * Called on search input key press
   * @param {Event} e The key event
   */
  _onSearchInput(e) {

    // Zoom to matching nodes on Enter key press
    if ( e.which === 13 )
      this._nextMatch();
    // Perform search for entered value when any other key pressed
    else
      this.search( $(e.target).val() );

  }


  /** Select **/


  /**
   * Select a given node and update styling
   * @param {TreeNode} node Target node instance
   * @param {boolean} toggle Specifies if node deselect allowed, optional [default=true]
   */
  _selectNode(node, toggle) {

    let oldNode = this.selected,
        sameNode = oldNode && (oldNode.el == node.el);

    // Deselect previous node if toggle allowed
    if ( oldNode && ( !sameNode || (sameNode && toggle) ) )
        oldNode.deselect();

    // Select given node
    if ( (!oldNode || !sameNode) || (oldNode && sameNode && !toggle) )
      node.select();

  }


  /** Events **/


  /**
   * Process and render raw graph data from the server
   * @param {Object} rawData Compatible graph data fetched from the server
   */
  _onDataLoaded(rawData) {
console.log(rawData);
    // Convert raw data to d3 hierarchy
    this.graph.root = this._preprocessData(rawData);
    this.render().reCenter();

  }

  /**
   * Node click event, handle UI update
   * Extend method for custom behavior
   * @warning IE will trigger this event even on double-click
   * @param {TreeNode} node Clicked TreeNode instance
   */
  _onNodeClick(node) {

    if ( d3.event.detail < 2 )
      this.selectNode( node )

  }

  /**
   * Node double click event, prevent graph zoom
   * Extend method for custom behavior
   * @param {TreeNode} node Clicked TreeNode instance
   */
  _onNodeDblClick(node) {

    if ( this.zoomable )
      d3.event.stopPropagation();

  }

  /**
   * Node right click event, prevent default behavior, collapse / expands node's children
   * Extend method for custom behavior
   * @param {TreeNode} node Clicked TreeNode instance
   */
  _onNodeRightClick(node) {

    // Prevent context menu display
    d3.event.preventDefault();

    node.collapseOrExpand();
    // Re-draw graph
    this.render()._restoreGraph();

  }

  /**
   * Graph / window resized event, adjust container and graph svg
   * Extend method for custom behavior
   */
   _onResize() {

    // Resize container if autoScale enabled
    if ( this.autoScale )
      this._props.container.height( window.innerHeight - 230 );

    // Resize graph svg
    if ( this.graph && this.graph.svg )
      this.graph.svg.attr( 'viewBox', `0 0 ${ this._props.svg.width } ${ this._props.svg.height }` )
                    .attr( 'height', this._props.svg.height )

  }

  /**
   * Graph zoomed / dragged on event, apply and cache the transform
   * Extend method for custom behavior
   */
  _onZoom() {

    // Transform graph
    this.graph.g.attr( 'transform', d3.event.transform );
    // Cache transform value
    this.graph.lastTransform = d3.event.transform;

  }

  /**
   * Key down event
   * Extend method for custom behavior
   */
  _onKeyPress(e) {

    if ( !this.selected )
      return;

    if ( e.which < 37 || e.which > 40 )
      return;

    switch(e.which) {
      case 38:
        this.selectNode( this.selected.previous );
        break;
      case 39:
        this.selectNode( this.selected.middleChild );
        break;
      case 40:
        this.selectNode( this.selected.next );
        break;
      case 37:
        this.selectNode( this.selected.parent );
        break;
    }

    e.preventDefault();

    if ( !isInViewport( $( this.graph.svg.node() ), this.selected.$ ) )
      this.focusOn( this.selected, false, false );

  }

  /**
   * Called when render completed and graph drawn
   * Override for custom behavior
   */
  _onRenderComplete() { }


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
      onClick: (d) => this._onNodeClick( new this.Node(d) ),
      onDblClick: (d) => this._onNodeDblClick( new this.Node(d) ),
      onRightClick: (d) => this._onNodeRightClick( new this.Node(d) )
    });

    this._renderCustom(); // Render any custom additional elements

    this._onRenderComplete(); // Graph rendered callback

    return this;

  }

  /**
   * Renders the latest Search match count
   */
  _renderSearchCount() {

    let count = `(${ this.searchMatches.size() })`;
    $(`${ this.selector } #d3-search-count`).text( count );

  }

  /**
   * Render custom additional elements in the graph
   * Override method for custom implementation
   */
  _renderCustom() {  }


  /** Graph utils **/


  /**
   * Initialize Tree and Zoom instances, call only on Graph reset
   * @return {TreeGraph} This instance for method chaining
   */
  _initGraph() {

    // Initialize a new D3 Tree graph
    this.graph.tree = this._newTree();
    // Initialize Zoom functionality
    this.graph.zoom = this._newZoom();

    return this;

  }

  /**
   * Restore graph to the state before re-draw (zoom and selection), call only on re-draw
   * @param {boolean} restoreZoom Specifies if zoom should be restored from cache, optional [defeault=true]
   * @param {boolean} restoreSelection Specifies if prev selected node should be reselected, optional [defeault=true]
   * @return {TreeGraph} This instance for method chaining
   */
  _restoreGraph(restoreZoom = true, restoreSelection = true) {

    // Restore zoom transforms
    if ( this.zoomable && restoreZoom )
      this.graph.svg.call( this.graph.zoom.transform, this.graph.lastTransform );

    // Reselect node
    if ( this.selected && restoreSelection )
      this.selectNode( this.selected, false );

    return this;

  }

  /**
   * Get a new D3 tree instance with custom nodeSize
   * Override for custom implementation
   * @return {D3} New D3 tree graph instance
   */
  _newTree() {

    return d3.tree()
                  .nodeSize( [this._props.tree.nodeHeight, this._props.tree.nodeWidth] );

  }

  /**
   * Get a new D3 SVG with custom size and zoom
   * Override for custom implementation
   * @param {boolean} responsive Specifies if the graph is responsive horizontally, optional [default=true]
   * @return {D3} New D3 SVG view
   */
  _newSVG(responsive = true) {

    let width = this._props.svg.width,
        height = this._props.svg.height,
        svg = d3.select( `${this.selector} #d3` )
                     .append( 'svg' )
                     .attr( 'width', (responsive ? '100%' : width) )
                     .attr( 'height', height )
                     .attr( 'viewBox', `0 0 ${ width } ${ height }` )
                     .attr( 'preserveAspectRatio', 'xMinYMin meet' )

    if ( this.zoomable )
      svg.call( this.graph.zoom );

    return svg;

  }

  /**
   * Get a new D3 zoom behavior instance with custom min and max values
   * Override for custom implementation
   * @requires zoomable enabled
   * @return {(D3 | null)} New D3 zoom behavior or null if zoomable disabled
   */
  _newZoom() {

    if ( !this.zoomable )
      return null;

    return d3.zoom()
                  .scaleExtent( [ this._props.zoom.min, this._props.zoom.max ] )
                  .on( 'zoom', () => this._onZoom() );

  }

  /**
   * Moves zoom to and selects the nodes matching the current search, cycling through
   */
  _nextMatch() {

    let nodesFound = this.searchMatches.data();

    // Return when no matches
    if ( !nodesFound.length )
      return;

    // Focus on next node
    let nextNode = new this.Node( nodesFound[ this.searchIndex ] );
    this.focusOn( nextNode );

    // Update search index
    if ( nodesFound[ this.searchIndex + 1] )
      this.searchIndex++
    else
      this.searchIndex = 0

  }

  /**
   * Toggle loading state of the Tree Graph
   * @param {boolean} enable Desired loading state
   */
  _loading(enable) {

    let graph = $( this.selector ).find( '#d3' );

    graph.toggleClass( 'loading', enable );

    if ( enable )
      renderSpinnerIn$( graph, 'small' );
    else
      removeSpinnerFrom$( graph );

  }

  /**
   * Toggle unintrusive loading-extra state of the Tree Graph
   * @param {boolean} enable Desired loading state
   */
  _loadingExtra(enable) {

    $( this.selector ).find( '#d3 #loading-extra' ).toggle( enable );

  }

  /**
   * Graph properties definitions
   * Extend and override method to customize
   * @return {Object} Graph properties for tree, svg, zoom
   */
  get _props() {

    let self = this,
        props = {
          container: $(this.selector),
          tree: {
            get nodeWidth() {
              return (props.svg.width / self.treeDepth) - this.rightOffset < this.minNodeWidth ?
                        this.minNodeWidth : (props.svg.width / self.treeDepth) - this.rightOffset;
            },
            nodeHeight: 26,
            minNodeWidth: 240,
            rightOffset: 0
          },
          svg: {
            margin: 20,
            get width() { return props.container.width() },
            get height() { return props.container.height() }
          },
          zoom: {
            min: 0.5,
            max: 2
          }
        }

    return props;

  }

}
