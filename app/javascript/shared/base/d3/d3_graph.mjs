import { $get } from 'shared/helpers/ajax'

import { renderSpinnerIn$, removeSpinnerFrom$ } from 'shared/ui/spinners'
import { findInString } from 'shared/helpers/strings'

/**
 * D3 Graph Base Class
 * @description Extensible D3-based Graph module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class D3Graph {

  /**
   * Create a D3 Graph instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the D3 graph 
   * @param {string} params.dataUrl Url to fetch the graph data from
   * @param {module} params.nodeModule Graph Node module class 
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
    selectable = true,
  }) {

    Object.assign( this, {
      dataUrl, selector, autoScale,
      zoomable, selectable,
      Node: nodeModule
    });

    this._loadD3();

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
      errorDiv: this._alertDiv,
      done: rawData => this._onDataLoaded( rawData ),
      always: () => this._loading( false )
    });

  }


  /** Graph **/


  /**
   * Render the Graph
   * @override for custom behavior
   * @return {D3Graph} This instance for method chaining
   */
  render() {

    // Initialize graph 
    this._initGraph();
    return this; 

  }

  /**
   * Re-center the graph
   * @requires zoomable parameter set to true
   * @return {D3Graph} This instance for method chaining
   */
  reCenter() {

    if ( this.zoomable && this.graph.svg )
      this._reCenter();

    return this;

  }

  /**
   * Focus a given node into view, optional zoom and select
   * @requires zoomable enabled
   * @param {D3Node} node Target node instance
   * @param {boolean} zoom Specifies if the node should be zoomed to, optional [default=true]
   * @param {boolean} select Specifies if the node should be selected, optional [default=true]
   */
  focusOn(node, zoom = true, select = true) {

    if ( this.zoomable && this.graph.svg && node.exists )
      this._focusOn( node, zoom, select );

    return this;

  }

  /**
   * Restore focus to the selected node element
   */
  restoreFocus() {

    setTimeout( () => {

        if ( this.selected )
          this.selected.el.focus();

    }, 300 );

  }

  /**
   * Clear the graph contents
   */
  clearGraph() {

    this.d3.select(`${this.selector} #d3 svg`)
           .remove();

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

    return this.d3.selectAll(`${this.selector} .node.search-match`);

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
   * @param {D3Node} node Target node instance
   * @param {boolean} toggle Specifies if node deselect allowed, optional [default=true]
   */
  selectNode(node, toggle = true) {

    if ( this.selectable && node )
      this._selectNode(node, toggle);

  }

  /**
   * Get the currently selected node
   * @return {(D3Node | null)} Node instance or null if no node selected
   */
  get selected() {

    let selected = this.d3.select(`${this.selector} .node.selected`);

    // Return null if selection is empty
    if ( selected.empty() )
      return null;

    return new this.Node( selected.data()[0] );

  }


  /** Getters **/


  /**
   * Get all nodes visible in the graph
   * @return {array} Collection of all nodes cast to Node instances
   */
  get allNodes() { }


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
    $( window ).on( 'resize', () => this._onResize() );

    // Center graph on btn click
    $( this.selector ).find( '#center-graph' )
                      .on( 'click', () => this.reCenter() );

    // Clear Search stylings and field value on btn click
    $( this.selector ).find( '#d3-clear-search' )
                      .on( 'click', () => this.clearSearch( true ) );

    // Search graph on input key up event
    $( this.selector ).find( '#d3-search' )
                      .on( 'keyup', e => this._onSearchInput(e) );

  }

  /**
   * Preprocess data
   * Override method for custom implementation
   * @param {Object} rawData Compatible graph data fetched from the server
   */
  _preprocessData(rawData) { }


  /** Graph Control **/


  /**
   * Focus a given node into view, specifiable zoom and select, private
   * @param {D3Node} node Target node instance
   * @param {boolean} zoom Specifies if the node should be zoomed to
   * @param {boolean} select Specifies if the node should be selected
   */
  _focusOn(node, zoom, select) {

    let scale = zoom ? 1.15 : this.graph.lastTransform.k,
        tX = (this._props.svg.width / 2) - ( node.d.x + (node.width / 2) ) * scale,
        tY = (this._props.svg.height / 2) - node.d.y * scale,
        transform = this.d3.zoomIdentity.translate( tX, tY ).scale( scale );

    // Call transform to given node
    this.graph.svg.call( this.graph.zoom.transform, transform );

    if ( select )
      this.selectNode( node, false );

  }

  /**
   * Re-center the graph
   * @param {int} tX X target offset, optional
   * @param {int} tY Y target offset, optional 
   */
  _reCenter(
    tX = this._props.svg.margin, 
    tY = this._props.svg.height 
  ) {

    this.graph.svg.call(
      this.graph.zoom.transform,
      this.d3.zoomIdentity.translate( tX, tY / 2 )
    );

  }


  /** Search **/


  /**
   * Search through displayed nodes in graph and mark matching results
   * @param {string} searchText The text to search for
   */
  _search(searchText) {

    // Find matches
    let matches = this.d3.selectAll( `${this.selector} .node` )
                         .filter( d => findInString( searchText, new this.Node(d).label ) )
                         .nodes();

    $( matches ).addClass( 'search-match' ); // Mark matching nodes

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
   * @param {D3Node} node Target node instance
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
   * @override for custom behavior
   * @param {Object} rawData Compatible graph data fetched from the server
   */
  _onDataLoaded(rawData) {

    // Save reference to the raw data structure
    this.rawData = rawData;

  }

  /**
   * Node click event, handle UI update
   * Extend method for custom behavior
   * @warning IE will trigger this event even on double-click
   * @param {D3Node} node Clicked Node instance
   */
  _onNodeClick(node) {

    if ( this.d3.event.detail < 2 )
      this.selectNode( node )

  }

  /**
   * Node double click event, prevent graph zoom
   * Extend method for custom behavior
   * @param {D3Node} node Clicked Node instance
   */
  _onNodeDblClick(node) {

    if ( this.zoomable )
      this.d3.event.stopPropagation();

  }

  /**
   * Node right click event, prevent default behavior, collapse / expands node's children
   * Extend method for custom behavior
   * @param {D3Node} node Clicked Node instance
   */
  _onNodeRightClick(node) { }

  /**
   * Graph / window resized event, adjust container and graph svg
   * Extend method for custom behavior
   */
   _onResize() {

    // Resize container if autoScale enabled
    if ( this.autoScale )
      this._props.container.height( window.innerHeight - 200 );

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
    this.graph.g.attr( 'transform', this.d3.event.transform );
    // Cache transform value
    this.graph.lastTransform = this.d3.event.transform;

  }

  /**
   * Called when render completed and graph drawn
   * Override for custom behavior
   */
  _onRenderComplete() { }


  /** Renderers **/


  /**
   * Clear and render the D3 Graph based on instance data
   * @return {D3Graph} This instance for method chaining
   */
  _render() {

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
   * Initialize Graph, called before each re-render
   * @override for custom behavior
   */
  _initGraph() {

    // Extend to initialize other features 

    // Initialize Zoom functionality
    this.graph.zoom = this._newZoom();

    return this;

   }

  /**
   * Restore graph to the state before re-draw (zoom and selection), call only on re-draw
   * @param {boolean} restoreZoom Specifies if zoom should be restored from cache, optional [defeault=true]
   * @param {boolean} restoreSelection Specifies if prev selected node should be reselected, optional [defeault=true]
   * @return {D3Graph} This instance for method chaining
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
   * Get a new D3 SVG with custom size and zoom
   * Override for custom implementation
   * @param {boolean} responsive Specifies if the graph is responsive horizontally, optional [default=true]
   * @return {D3} New D3 SVG view
   */
  _newSVG(responsive = true) {

    let width = this._props.svg.width,
        height = this._props.svg.height,
        svg = this.d3.select( `${this.selector} #d3` )
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

    return this.d3.zoom()
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
   * Toggle loading state of the D3 Graph
   * @param {boolean} enable Desired loading state
   */
  _loading(enable) {

    this.loading = enable;

    let graph = $( this.selector ).find( '#d3' );

    graph.toggleClass( 'loading', enable );

    if ( enable )
      renderSpinnerIn$( graph, 'small' );
    else
      removeSpinnerFrom$( graph );

  }

  /**
   * Toggle unintrusive loading-extra state of the Graph
   * @param {boolean} enable Desired loading state
   */
  _loadingExtra(enable) {

    $( this.selector ).find( '#d3 #loading-extra' )
                      .toggle( enable );

  }

  get _alertDiv() {
    return $( this.selector ).find( '#graph-alerts' );
  }

  /**
   * Graph properties definitions
   * Extend and override method to customize
   * @return {Object} Graph properties for svg, zoom
   */
  get _props() {

    let self = this,
        props = {
          container: $(this.selector),
          svg: {
            margin: 25,
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

  /**
   * Load D3 modules asynchronously and init graph afterwards
   * @override for custom behavior
   */
  async _loadD3() {

    // Load D3 modules here  

    this._init(); // Call init after load 

  }

}
