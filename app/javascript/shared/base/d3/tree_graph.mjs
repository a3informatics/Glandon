import * as d3Lib from 'd3'

import { $get } from 'shared/helpers/ajax'
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
   * @param {boolean} params.scaleContainer Determines whether the graph container should scale height to fit window height, optional [default=true]
   * @param {boolean} params.zoomable Determines whether the graph can be zoomed and dragged, optional [default=true]
   * @param {boolean} params.selectable Determines whether the nodes can be selected by clicking, optional [default=true]
   */
  constructor({
    selector,
    dataUrl,
    scaleContainer = true,
    zoomable = true,
    selectable = true,
  }) {

    Object.assign( this, { dataUrl, selector, scaleContainer, zoomable,
      selectable, d3: d3Lib.default } );

    // Init and load data
    this._init();
    this.loadData();

  }

  /**
   * Fetch graph data from the server
   * @param {string} url Source data url, overrides current dataUrl, optional
   */
  loadData(url) {

    // Overwrite instance's dataUrl
    if (url)
      this.dataUrl = url;

    this._loading(true);

    // Get request, handles response
    $get({
      url: this.dataUrl,
      done: (rawData) => this._onDataLoaded(rawData),
      always: () => this._loading(false)
    });

  }

  /**
   * Re-center the graph
   * @requires zoomable parameter set to true
   */
  center() {

    if ( this.zoomable && this.graph.svg )
      this.graph.svg.call(
        this.graph.zoom.transform,
        this.d3.zoomIdentity.translate(this._graphProps.svg.margin, (this._graphProps.svg.height / 2))
      );

  }

  /**
   * Translates graph with the given node in the center of view
   * @requires zoomable parameter set to true
   * @param {HTML Element} node Target node g element
   * @param {boolean} zoom Specifies whether the target node should also be zoomed to, optional [default=false]
   * @param {boolean} select Specifies whether the target node should also be selected, optional [default=false]
   */
  moveTo(node, zoom = false, select = false) {

    if ( this.zoomable && this.graph.svg && node )  {

      let nodeD = this.d3.select(node).data()[0],
          nodeWidth = node.getBBox().width,
          scale = 1.15,
          translateX = (this._graphProps.svg.width / 2) - ( nodeD.y + (nodeWidth / 2)) * ( zoom ? scale : 1),
          translateY = (this._graphProps.svg.height / 2) - nodeD.x * ( zoom ? scale : 1 ),
          transform = this.d3.zoomIdentity.translate( translateX, translateY )

      // Call transform to given node
      this.graph.svg.call(
        this.graph.zoom.transform,
        ( zoom ? transform.scale(scale) : transform )
      );

      // Select node if select arg enabled
      if (select)
        this.selectNode( $(node), nodeD, false );

    }
  }

  /**
   * Clear the graph contents
   * @param {boolean} reset Specifies whether the graph should be reset completely (true) or just re-drawn (false)
   */
  clearGraph(reset) {
    this.d3.select(`${this.selector} #d3 svg`).remove();
  }

  /**
   * Clear the search from the graph, remove styling
   * @param {boolean} clearInput Specifies whether the search input value should be cleared, optional, [default=false]
   */
  clearSearch(clearInput = false) {

    this.graph.searchIndex = 0;
    $( this.searchMatches.nodes() ).removeClass('search-match');

    // Clear input element value
    if ( clearInput )
      $(this.selector).find('#d3-search').val('');

    // Update search count display
    this._renderSearchCount();

  }

  /**
   * Select a given node and update styling
   * @requires selectable parameter set to true
   * @param {JQuery element} $node Target node element
   * @param {Object} d D3 Node object
   * @param {boolean} allowToggle Specifies whether deselection of the node on 2nd click should be allowed, optional [default=false]
   */
  selectNode($node, d, allowToggle = true) {

    if ( !this.selectable )
      return;

    let prevSelected = this.selected,
        sameNode = prevSelected && (prevSelected.node[0] == $node[0]);

    // Deselect previous node if toggle allowed
    if ( prevSelected ) {
      if ( !sameNode || (sameNode && allowToggle) )
        this._toggleNodeSelected( prevSelected.node, prevSelected.data, false );
    }

    // Select given node
    if ( !prevSelected || !sameNode )
      this._toggleNodeSelected( $node, d, true );

  }

  /**
   * Search through displayed nodes in graph and mark matching results with 'search-match' class
   * @param {string} text The text to search for
   */
  search(text) {

    this.clearSearch();

    if ( text === '' )
      return;

    this.d3.selectAll(`${this.selector} .node`).each( function(n) {

      // Found node text match
      if ( findInString( text, n.data.label ) )
        $(this).addClass('search-match'); // Mark matching nodes

    });

    // Update search count display
    this._renderSearchCount();

  }

  get searchMatches() {
    return this.d3.selectAll(`${this.selector} .node.search-match`);
  }

  /**
   * Get the maximum depth of the data tree
   * @return {int} The maximum depth of the current data tree
   */
  get treeDepth() {
    return this.graph.root.height;
  }

  /**
   * Get the currently selected node
   * @return {(object | null)} Object containing node element and its data object, null if no node selected
   */
  get selected() {
    let selected = this.d3.select(`${this.selector} .node.selected`);

    // Return null if selection is empty
    if ( selected.empty() )
      return null;

    return {
      node: $(selected.node()),
      data: selected.data()[0]
    }
  }


  /** Private **/


  /**
   * Create instance graph object, set listeners, initial resize
   */
  _init() {

    this.graph = {};
    this._setListeners();
    this._onResize();

  }

  /**
   * Set event listeners & handlers
   */
  _setListeners() {

    // Resize graph on window resize event
    $(window).on( 'resize', () => this._onResize() );

    // Center graph on btn click
    $(this.selector).find('#center-graph').on( 'click', () => this.center() );

    // Collapse graph nodes on btn click
    $(this.selector).find('#collapse-except-graph').on( 'click', () => {

      if ( !this.selected )
        return;

      this._collapseAllExcept( this.selected.data );
      this._render(false);
      this.center();

    } );

    // Collapse graph nodes on btn click
    $(this.selector).find('#collapse-graph').on( 'click', () => {

      this.d3.selectAll(`${this.selector} .node`).each( this._collapseNode.bind(this) );
      this._render(false);
      this.center();

    } );

    // Expand graph nodes on btn click
    $(this.selector).find('#expand-graph').on( 'click', () => {

      this._expandAll( this.graph.root, this );
      this._render(false);

    } );

    // Search graph on input key up event
    $(this.selector).find('#d3-search').on( 'keyup', (e) => {

      // Zoom to matching nodes on Enter key press
      if ( e.which === 13 )
        this._focusSearchMatches();

      // Perform search for entered value when any other key pressed
      else
        this.search( $(e.target).val() );

    } );

    // Clear Search stylings and field value on btn click
    $(this.selector).find('#d3-clear-search').on( 'click', () => this.clearSearch( true ) );

  }

  /**
   * Process and render raw graph data from the server
   * @param {Object} rawData Compatible graph data fetched from the server
   */
  _onDataLoaded(rawData) {

    // Convert raw data to d3 hierarchy
    this.graph.root = this._preprocessData(rawData);
    // Render processed data
    this._render();
    // Center graph initially
    this.center();

  }

  /**
   * Preprocess data and convert it into a D3 hierarchy
   * Override method for custom implementation
   * @param {Object} rawData Compatible graph data fetched from the server
   */
  _preprocessData(rawData) {

    return this.d3.hierarchy( rawData, (d) => d.children );

  }

  /**
   * Get a new D3 tree instance with custom nodeSize
   * Override method for custom implementation
   * @param {Object} treeProps Properties object containing the nodeHeight and nodeWidth values
   * @return {D3} New D3 tree graph instance
   */
  _newTree(treeProps) {

    return this.d3.tree()
                  .nodeSize( [treeProps.nodeHeight, treeProps.nodeWidth] );

  }

  /**
   * Get a new D3 svg view with custom size and zoom (if instance zoomable param is enabled)
   * Override method for custom implementation
   * @param {Object} svgProps Properties object containing the width and height values
   * @param {boolean} responsiveWidth Determines whether the graph should be responsive horizontally, optional [default=true]
   * @return {D3} New D3 svg view
   */
  _newSVG(svgProps, responsiveWidth = true) {

    let svg = this.d3.select( `${this.selector} #d3` )
                     .append( 'svg' )
                     .attr( 'width', (responsiveWidth ? '100%' : svgProps.width) )
                     .attr( 'height', svgProps.height )
                     .attr( 'viewBox', `0 0 ${ svgProps.width } ${ svgProps.height }` )
                     .attr( 'preserveAspectRatio', 'xMinYMin meet' );

    if ( this.zoomable )
      svg.call( this.graph.zoom );

    return svg;

  }

  /**
   * Get a new D3 zoom behavior instance with custom min and max values
   * Override method for custom implementation
   * @requires zoomable instance parameter to be enabled
   * @param {Object} zoomProps Properties object containing the min and max zoom values
   * @return {(D3 | null)} New D3 zoom behavior, null if zoomable disabled
   */
  _newZoom(zoomProps) {

    if ( !this.zoomable )
      return null;

    return this.d3.zoom()
                  .scaleExtent( [zoomProps.min, zoomProps.max] )
                  .on('zoom', () => {

                    // Perform transform on graph
                    this.graph.g.attr('transform', this.d3.event.transform );
                    // Cache transform value to use when re-drawing the graph
                    this.graph.lastTransform = this.d3.event.transform;

                  });

  }


  /** Renderers **/


  /**
   * Initialize and render the tree graph
   * @param {boolean} reset Specifies whether the graph should be reset completely (true) or just re-drawn (false), optional [default = true]
   */
  _render(reset = true) {

    this.clearGraph( reset );

    if ( reset ) {
      // Initialize a new D3 Tree graph
      this.graph.tree = this._newTree( this._graphProps.tree );
      // Initialize Zoom functionality
      this.graph.zoom = this._newZoom( this._graphProps.zoom )
    }

    // Map the node data to the tree
    this.graph.root = this.graph.tree( this.graph.root );

    // Render the graph
    this.graph.svg = this._newSVG( this._graphProps.svg )
    this.graph.g = this.graph.svg.append( 'g' );
    this._renderLinks( this._graphProps.links );
    this._renderNodes( this._graphProps.nodes );
    // Render any custom additional elements
    this._renderCustom(reset);

    // Restore zoom transforms on graph redraw
    if ( !reset && this.zoomable ) {
      this.graph.svg.call( this.graph.zoom.transform, this.graph.lastTransform )
    }

    // Reselect node on graph redraw
    if ( !reset && this.selectable && this.selected )
      this._toggleNodeSelected( this.selected.node, this.selected.data, true )

  }

  /**
   * Render links (lines) in the tree graph based on custom properties
   * Override method for custom implementation
   * @param {Object} linkProps Properties object containing the link width and color values
   * @return {D3} Rendered D3 links selection
   */
  _renderLinks(linkProps) {

    return this.graph.g.selectAll( '.link' )
                       .data( this.graph.root.descendants().slice(1) )
                       .enter()
                        .append( 'path' )
                        .attr( 'class', 'link' )
                        // Link styles
                        .style( 'fill', 'none' )
                        .style( 'stroke-width', linkProps.width )
                        .style( 'stroke', linkProps.color )
                        // Link curve definition
                        .attr( 'd', (d) => `M ${ d.y }, ${ d.x } C ${ (d.y + d.parent.y) / 2 },` +
                                           `${ d.x } ${ (d.y + d.parent.y) / 2 }, ` +
                                           `${ d.parent.x } ${ d.parent.y }, ${ d.parent.x}` );

  }

  /**
   * Render nodes in the tree graph based on custom properties
   * Override method for custom implementation
   * @param {Object} nodeProps Properties object containing the node radius and color values
   * @return {D3} Rendered D3 nodes selection
   */
  _renderNodes(nodeProps) {

    let self = this,
        nodes = this.graph.g.selectAll( '.node' )
                            .data( this.graph.root.descendants() )
                            .enter()
                              .append( 'g' )
                              // Transform node to coordinates
                              .attr( 'transform', (d) => `translate(${d.y}, ${d.x})` )
                              // CSS class dependent on selected data flag
                              .attr( 'class', (d) => (d.data.selected ? 'node selected' : 'node') )
                              // Click event, prevents firing on double click
                              .on( 'click', function (d) { self.d3.event.detail ? self._onNodeClick( $(this), d ) : null })
                              // Double click event
                              .on( 'dblclick', function(d) { self._onNodeDblClick( $(this), d ) })
                              // Right click event
                              .on( 'contextmenu', function(d) { self._onNodeRightClick( $(this), d ) });

      // Render circles in nodes
      this._renderNodeCircles(nodes, nodeProps);

      // Render node collapsed icons
      this._renderNodeCollapsedIcons(nodes, nodeProps);

      return nodes;

  }

  /**
   * Render circles in given nodes based on custom properties
   * Override method for custom implementation
   * @param {D3} nodes D3 selection of nodes
   * @param {Object} nodeProps Properties object containing the node radius and color values
   */
  _renderNodeCircles(nodes, nodeProps) {

    nodes.append( 'circle' )
         .attr( 'r', nodeProps.radius )
         .style( 'fill', nodeProps.color );

  }

  /**
   * Render icons showing whether a node with children is collapsed
   * Override method for custom implementation
   * @param {D3} nodes D3 selection of nodes
   * @param {Object} nodeProps Properties object containing the node radius and color values
   */
  _renderNodeCollapsedIcons(nodes, nodeProps) {

    nodes.append( 'text' )
         .attr( 'x', nodeProps.radius - 4 )
         .attr( 'y', nodeProps.radius * (-1) )
         .text( (d) => '\ue937' )
         .style( 'font-family', 'icomoon' )
         .style( 'font-size', '7pt' )
         // Only display if node's children are collapsed
         .style( 'display', (d) => d._children ? 'block' : 'none' )
         .style( 'fill', (d) => colors.greyLight );

  }

  _renderSearchCount() {
    $(this.selector).find('#d3-search-count')
                    .text( `(${ this.searchMatches.nodes().length })` );
  }

  /**
   * Render custom additional elements in the graph
   * Override method for custom implementation
   */
  _renderCustom() {  }


  /** Events **/


  /**
   * Node click event, handle UI update
   * Extend method for custom behavior
   * @param {JQuery element} $node Clicked node element
   * @param {Object} d D3 Node object
   */
  _onNodeClick($node, d) {

    this.selectNode( $node, d );

  }

  /**
   * Node double click event, prevent graph zoom
   * Extend method for custom behavior
   * @param {JQuery element} $node Clicked node element
   * @param {Object} d D3 Node object
   */
  _onNodeDblClick($node, d) {

    if ( this.zoomable )
      this.d3.event.stopPropagation();

  }

  /**
   * Node right click event, prevent default behavior, collapse / expands node's children
   * Extend method for custom behavior
   * @param {JQuery element} $node Clicked node element
   * @param {Object} d D3 Node object
   */
  _onNodeRightClick($node, d) {

    this.d3.event.preventDefault();
    this._collapseOrExpand(d);

  }

  /**
   * Graph / window resized event, adjust container and graph svg
   * Extend method for custom behavior
   */
   _onResize() {

    // Resize container if scaleContainer enabled
    if ( this.scaleContainer )
      this._graphProps.container.height( window.innerHeight - 230 );

    // Resize graph svg
    if ( this.graph && this.graph.svg )
      this.graph.svg.attr( 'viewBox', `0 0 ${ this._graphProps.svg.width } ${ this._graphProps.svg.height }` )
                    .attr( 'height', this._graphProps.svg.height )

  }


  /** Support **/


  /**
   * Moves zoom to and selects the nodes matching the current search, cycling through
   */
  _focusSearchMatches() {

    let searchMatches = this.searchMatches.nodes();

    // Return when no matches
    if ( searchMatches.length === 0 )
      return;

    // Focus (zoom) on node in current index
    this.moveTo( searchMatches[this.graph.searchIndex], true, true );

    // Update current node index
    if (this.graph.searchIndex === searchMatches.length - 1)
      this.graph.searchIndex = 0;
    else
      this.graph.searchIndex++;

  }

  /**
   * Toggle node's selected state, update data and styles
   * Override method for custom implementation
   * @param {JQuery element} $node Target node element
   * @param {Object} d Target D3 node object
   * @param {boolean} select Desired select state of the node
   */
  _toggleNodeSelected($node, d, select) {

    // Update node CSS class
    $node.toggleClass('selected', select);
    // Update node data object
    d.data.selected = select;

    // Update node style
    $node.find('circle').css('fill', (select ? colors.accent2 : this._graphProps.nodes.color) );

  }

  /**
   * Collapse or expand node children and re-draw graph
   * @param {Object} node D3 Node object
   */
  _collapseOrExpand(node) {

    // Collapse children and cache them
    if ( node.children )
      this._collapseNode(node);
    // Expand children and clear node cache
    else
      this._expandNode(node);

    // Re-draw graph
    this._render( false );

  }

  /**
   * Collapse node children
   * @param {Object} node D3 Node object
   */
  _collapseNode(node) {

    if ( node.children ) {
      node._children = node.children
      node.children = null;
    }

  }

  /**
   * Expand node children
   * @param {Object} node D3 Node object
   */
  _expandNode(node) {

    if ( node._children ) {
      node.children = node._children;
      node._children = null;
    }

  }

  /**
   * Expand all node children
   * @param {Object} node D3 Node object
   */
  _expandAll(node) {

    let children = node.children ? node.children : node._children;

    this._expandNode(node);

    if ( children )
      children.forEach( this._expandAll.bind(this) );

  }

  /**
   * Collapse all node children except given node and its direct parents
   * @param {Object} node D3 Node object to skip
   */
  _collapseAllExcept(node) {

    while (node.parent) {
      for ( let child of node.parent.children ) {
        if ( child != node )
          this._collapseNode(child);
      }
      node = node.parent;
    }

  }

  /**
   * Toggle loading state of the graph
   * @param {boolean} enable Desired loading state
   */
  _loading(enable) {

    $(this.selector).find('#d3').toggleClass('loading', enable);

    if ( enable )
      renderSpinnerIn$( $(this.selector).find('#d3'), 'small' );
    else
      removeSpinnerFrom$( $(this.selector).find('#d3') );

  }

  /**
   * Graph properties definitions
   * Extend and override method to customize
   * @return {Object} Graph properties for tree, svg, zoom, nodes and links
   */
  get _graphProps() {

    let self = this;

    let props = {
      container: $(this.selector),
      tree: {
        get nodeWidth() { return (props.svg.width / self.treeDepth) },
        nodeHeight: 30
      },
      svg: {
        margin: 20,
        get width() { return props.container.width() },
        get height() { return props.container.height() }
      },
      zoom: {
        min: 0.5,
        max: 2
      },
      nodes: {
        radius: 10,
        color: colors.primaryLight,
      },
      links: {
        width: '1.5',
        color: '#ddd'
      }
    }

    return props;

  }

}
