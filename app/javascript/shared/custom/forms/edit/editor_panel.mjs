import TreeGraph from 'shared/base/d3/tree/tree_graph'
import FormNode from 'shared/custom/forms/edit/form_node'

import InformationDialog from 'shared/ui/dialogs/information_dialog'

import { $get } from 'shared/helpers/ajax'

import { D3Tooltip } from 'shared/helpers/d3/renderers/tooltip'
import { D3Actions } from 'shared/helpers/d3/renderers/actions'

import colors from 'shared/ui/colors'
import { iconBtn } from 'shared/ui/buttons'
import { cropText } from 'shared/helpers/strings'
import { alerts } from 'shared/ui/alerts'

import { renderIconsLabels } from 'shared/helpers/d3/renderers/nodes'

/**
 * Form Editor
 * @description D3 Tree Graph-based Editor of a Form
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class FormEditor extends TreeGraph {

  /**
   * Create a Form Editor instance
   * @param {Object} params Instance parameters
   * @param {string} params.formId ID of the currently edited form
   * @param {object} params.urls Must contain urls for 'data', 'update'
   * @param {string} params.selector JQuery selector of the editor panel
   * @param {function} params.onEdited Callback executed on any edit/update action
   */
  constructor({
    formId,
    urls,
    selector = '#form-editor',
    onEdited = () => {}
  }) {

    super({
      selector,
      dataUrl: urls.data,
      nodeModule: FormNode
    });

    Object.assign( this, {
      formId, onEdited, urls
    });

    this._importModules();

  }


  /** Graph **/


  /**
   * Clear the graph contents
   * @extends clearGraph parent implementation
   */
  clearGraph() {

    super.clearGraph();
    D3Tooltip.destroy();
    D3Actions.destroy();

  }


  /** Editor actions **/


  /**
   * Remove a Node from the graph
   * @requires NodeHandler
   * @param {FormNode} node Node instance to remove
   */
  removeNode(node) {

    if ( !node )
      return;

    if ( this.nodeHandler )
      this.nodeHandler.remove( node );

  }

  /**
   * Move a Node on the graph (up/down)
   * @requires NodeHandler
   * @param {FormNode} node Node instance to remove
   * @param {string} dir Direction of move ( up / down )
   */
  moveNode(node, dir) {

    if ( !node )
      return;

    if ( this.nodeHandler )
      this.nodeHandler.move( node, dir );

  }

  /**
   * Open a nodeEditor panel with given Node instance
   * @requires NodeEditor
   * @param {FormNode} node Node instance to edit
   */
  editNode(node) {

    if ( this.nodeEditor )
      this.nodeEditor.edit( node );

  }

  commonOrRestore(node, action) {

    if ( !node )
      return;

    if ( this.nodeHandler )
      this.nodeHandler.commonOrRestore( node, action );

  }

  /**
   * Open / close Node's add children context menu
   * @requires NodeHandler
   * @param {string} state Target menu state ( show / hide )
   * @param {event} e Event that triggered state change ( focus / blur )
   */
  childrenMenu(state, e) {

    if ( this.nodeHandler )
        this.nodeHandler.childrenMenu( state, this.selected, e );

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

  /**
   * Set event listeners, handlers
   */
  _setListeners() {

    super._setListeners();

    // Editor Help dialog
    $( '#editor-help-btn' ).on( 'click',
                                () => new InformationDialog({ div: '#id-form-editor' }).show() );

    // Node actions edit button click
    $( this.selector ).on( 'click', '#edit-node',
                           () => this.editNode( this.selected ) );

    // Node actions add-child button focus
    $( this.selector ).on( 'focus', '#add-child',
                           e => this.childrenMenu( 'show', e ) );

    // Node actions add-child button focus-lost (blur)
    $( this.selector ).on( 'blur', '#add-child',
                           e => this.childrenMenu( 'hide', e ) );

    // Node actions remove button click
    $( this.selector ).on( 'click', '#remove-node',
                           () => this.removeNode( this.selected ) );

    // Node actions move up button click
    $( this.selector ).on( 'click', '#move-up',
                           () => this.moveNode( this.selected, 'up' ) );

    // Node actions move down button click
    $( this.selector ).on( 'click', '#move-down',
                           () => this.moveNode( this.selected, 'down' ) );

    // Node actions make common button click
    $( this.selector ).on( 'click', '#common-node',
                            () => this.commonOrRestore( this.selected, 'make_common' ) );

    // Node actions restore button click
    $( this.selector ).on( 'click', '#restore-node',
                           () => this.commonOrRestore( this.selected, 'restore' ) );

  }

  /**
   * Preprocess data and convert it into a sorted D3 hierarchy
   * @override parent implementation
   * @param {Object} rawData Graph data fetched from the server
   */
  _preprocessData(rawData) {
    let data = this.d3.hierarchy( rawData, d => [
        ...d.has_group||[],
        ...d.has_common||[],
        ...d.has_item||[],
        ...d.has_sub_group||[],
        ...d.has_coded_value||[]
      ]);

    data.descendants().forEach( n => {

      new this.Node( n, false ).sortChildren();

      // Hide children of common BC Properties
      if ( n.data.is_common === true ) {
        n.__children = n.children;
        n.children = null;
      }

    });

    return data;

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
   * Process and render raw graph data from the server, load referenced item data
   * @extends _onDataLoaded parent implementation
   * @param {Object} rawData Compatible graph data fetched from the server
   */
  _onDataLoaded(rawData) {

    super._onDataLoaded(rawData);
    // Fetch additional refData once rawData processed
    this._loadReferences();

  }


  /**
   * Re-render node-actions on zoom (to keep position relative to node)
   * @extends _onZoom parent implementation
   */
  _onZoom() {

    super._onZoom();
    this._renderActions( this.selected );

  }

  /**
   * Render completed callback, re-render nodeEditor contents if open
   * @override parent implementation
   */
  _onRenderComplete() {

    if ( this.nodeEditor && this.nodeEditor.isOpen )
      this.nodeEditor.render();

  }

  /**
   * On graph data update; re-render, extend edit token and focus on node if available
   * @param {FormNode} node Node to focus on after update, optional
   */
  _onUpdate(node) {

    this.render()._restoreGraph();

    this.onEdited();

    if (node) {

      node.findElement();
      this.focusOn( node, false );

      // Set element focus
      setTimeout( () => node.$.focus(), 100 );

    }

  }


  /** Keys ** /


  /**
   * Handle graph key controls ( edit, move node up & down )
   * @extends _keyControls parent implementation
   * @param {event} e Key event object
   */
  _keyControls(e) {

    super._keyControls(e);

    if ( e.shiftKey && e.which === 38 && this.selected ) // Shift + Arrow Up
      this.moveNode( this.selected, 'up' );

    else if ( e.shiftKey && e.which === 40 && this.selected ) // Shift + Arrow Down
      this.moveNode( this.selected, 'down' );

    else if ( !e.shiftKey && e.which === 69 && this.selected ) // E
      this.editNode( this.selected );

    else if ( !e.shiftKey && (e.which === 46 || e.which === 8) && this.selected ) // Delete / Backspace
      this.removeNode( this.selected );

  }


  /** Referenced Items **/


  /**
   * Fetch additional referenced item data from the server
   */
  _loadReferences() {

    this._loadingExtra( true );

    $get({
      url: this.urls.refData,
      done: refData => this._appendReferences(refData),
      always: () => this._loadingExtra( false )
    });

  }

  /**
   * Append reference data to the graph structure and re-render graph
   * @param {Object} references The raw refences data from the server (Keys: reference ids, Values: referenced item data)
   */
  _appendReferences(references) {

    // Needs to expand all nodes to access all reference nodes
    this._expandAll( new this.Node( this.graph.root ) );

    // Filter referenced nodes and append data
    this.allNodes.filter( node => node.isReference )
                 .forEach( node => {

        // Find reference
        let referenceId = node.data.has_biomedical_concept ?
                          node.data.has_biomedical_concept.id :
                          node.data.id,
            data = references[ referenceId ];

        if ( !data )
          return;

        // Merge reference data into Node data
        if ( node.data.has_biomedical_concept )
          node.data.has_biomedical_concept.reference = data;
        else
          node.data.reference = data;

        // Set default label & local label value if none is set
        if ( node.data.local_label === '' )
          node.data.local_label = data.label;

    });

    // Render changes
    this.render()._restoreGraph();

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
    this.graph.nodes = renderIconsLabels({
      nodes: this.graph.nodes,
      nodeIcon: this.Node.icon,
      nodeColor: this.Node.color,
      onHover: d => this._renderTooltip( new this.Node(d) ),
      onHoverOut: d => D3Tooltip.hide(),
      labelProperty: d => {

        if ( d.data.local_label )
          return cropText( d.data.local_label );

        return cropText( d.data.label ) || '...';

      }
    })

    // Override nodes class attribute to build a custom class list
    this.graph.nodes.attr( 'class', d => this._nodeClassList( new this.Node(d) ) );

  }


  /** Node Actions **/


  /**
   * Render node-actions element with buttons at a given node
   * @param {FormNode} node Node instance to render the node-actions element at
   */
  _renderActions(node) {

    if ( !node )
      return;

    // Toggle edit button depending on node
    D3Actions.actions.find( '#edit-node' )
                     .toggle( node.editAllowed );

    // Toggle add-child button depending on node type
    D3Actions.actions.find( '#add-child' )
                     .toggle( node.addChildAllowed );

    // Toggle Common button depending on node type
    D3Actions.actions.find( '#common-node' )
                     .toggle( node.commonAllowed );

    // Toggle Remove button depending on node type
    D3Actions.actions.find( '#remove-node' )
                     .toggle( node.removeAllowed );

    // Toggle Restore button depending on node type
    D3Actions.actions.find( '#restore-node' )
                     .toggle( node.restoreAllowed );

    D3Actions.show( node );

  }

  /**
   * Get the HTMLs for Action buttons to be rendered in node-actions
   * @return {Array} Array of HTML strings for node-action icon buttons
   */
  get _actionButtons() {

    return [
      iconBtn({ icon: 'edit', color: 'light', id: 'edit-node' }),
      iconBtn({ icon: 'plus', color: 'light', id: 'add-child' }),
      iconBtn({ icon: 'arrow-u', color: 'light', id: 'move-up' }),
      iconBtn({ icon: 'arrow-d', color: 'light', id: 'move-down' }),
      iconBtn({ icon: 'C', color: 'light', id: 'common-node' }),
      iconBtn({ icon: 'R', color: 'light', id: 'restore-node' }),
      iconBtn({ icon: 'times', color: 'red', id: 'remove-node' }),
    ]

  }


  /** Tooltip **/


  /**
   * Render tooltip contents and show
   * @param {FormNode} node Node instance to show the tooltip at
   */
  _renderTooltip(node) {

    let html = `<div>` +
                  `<div class='font-regular' style='color: ${ node.color }'> ${ node.rdfName } </div>
                   ${ ( node.disabled ? '<i>Disabled</i> <br>' : '') }
                   ${ ( node.isCommon ? '<i>Common</i> <br>' : '') }
                   ${ node.label }
                </div>`;

    D3Tooltip.show( html );

  }


  /** Support **/


  /**
   * Get a CSS class list for a given node instance
   * @param {FormNode} node Node instance to generate the class list for
   * @return {string} Node CSS class list
   */
  _nodeClassList(node) {

    let classList = 'node';

    if ( node.selected )
      classList += ' selected'
    if ( node.disabled || node.isCommon )
      classList += ' disabled'

    return classList;

  }


  /**
   * Graph properties definitions
   * @extends _props parent parameters
   * @return {Object} Graph properties for tree, svg, zoom
   */
  get _props() {

    let props = super._props;

    // Custom node width
    props.tree.nodeWidth = 250;

    // Custom zoom values
    props.zoom.min = 0.3;
    props.zoom.max = 1.6;

    // Custom key controls
    props.keys = props.keys.concat( [ 38, 40, 46, 8 ] );

    return props;

  }

  /**
   * Load modules that are required later on
   */
  async _importModules() {

    // Node Editor module
    let NodeEditor = await import( /* webpackPrefetch: true */
                                  'shared/custom/forms/edit/form_node_editor' );

    this.nodeEditor = new NodeEditor.default({
      formId: this.formId,
      onShow: () => this.keysDisable(),
      onHide: () => {

        this.keysEnable();
        this.restoreFocus();

      },
      onUpdate: () => {

        this._onUpdate();
        alerts.success( 'Node updated successfully.', this._alertDiv );

      }
    });

    // Node Handler module
    let NodeHandler = await import( /* webpackPrefetch: true */
                                    'shared/custom/forms/edit/form_node_handler' );

    this.nodeHandler = new NodeHandler.default( this );

  }

}
