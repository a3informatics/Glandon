import TreeGraph from 'shared/base/d3/tree/tree_graph'
import TagNode from 'shared/iso_concept_systems/d3/tag_node'

// import InformationDialog from 'shared/ui/dialogs/information_dialog'

import { $get } from 'shared/helpers/ajax'

import { D3Tooltip } from 'shared/helpers/d3/renderers/tooltip'
import { D3Actions } from 'shared/helpers/d3/renderers/actions'

// import colors from 'shared/ui/colors'
import { iconBtn } from 'shared/ui/buttons'
// import { cropText } from 'shared/helpers/strings'
// import { alerts } from 'shared/ui/alerts'

import { renderLabels } from 'shared/helpers/d3/renderers/nodes'

/**
 * Tags Editor
 * @description D3 Tree Graph-based Editor of Tags
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TagsEditor extends TreeGraph {

  /**
   * Create a Form Editor instance
   * @param {Object} params Instance parameters
   * @param {object} params.urls Must contain urls for 'data', 'update'
   * @param {string} params.selector JQuery selector of the editor panel
   */
  constructor({
    urls,
    selector = '#tags-editor',
  }) {

    super({
      selector,
      dataUrl: urls.data,
      nodeModule: TagNode
    });

    Object.assign( this, {
      urls
    });

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
  //
  //
  // /** Editor actions **/
  //
  //
  // /**
  //  * Remove a Node from the graph
  //  * @requires NodeHandler
  //  * @param {FormNode} node Node instance to remove
  //  */
  // removeNode(node) {
  //
  //   if ( !node )
  //     return;
  //
  //   if ( this.nodeHandler )
  //     this.nodeHandler.remove( node );
  //
  // }
  //
  // /**
  //  * Move a Node on the graph (up/down)
  //  * @requires NodeHandler
  //  * @param {FormNode} node Node instance to remove
  //  * @param {string} dir Direction of move ( up / down )
  //  */
  // moveNode(node, dir) {
  //
  //   if ( !node )
  //     return;
  //
  //   if ( this.nodeHandler )
  //     this.nodeHandler.move( node, dir );
  //
  // }
  //
  // /**
  //  * Open a nodeEditor panel with given Node instance
  //  * @requires NodeEditor
  //  * @param {FormNode} node Node instance to edit
  //  */
  // editNode(node) {
  //
  //   if ( this.nodeEditor )
  //     this.nodeEditor.edit( node );
  //
  // }
  //
  // commonOrRestore(node, action) {
  //
  //   if ( !node )
  //     return;
  //
  //   if ( this.nodeHandler )
  //     this.nodeHandler.commonOrRestore( node, action );
  //
  // }
  //
  // /**
  //  * Open / close Node's add children context menu
  //  * @requires NodeHandler
  //  * @param {string} state Target menu state ( show / hide )
  //  * @param {event} e Event that triggered state change ( focus / blur )
  //  */
  // childrenMenu(state, e) {
  //
  //   if ( this.nodeHandler )
  //       this.nodeHandler.childrenMenu( state, this.selected, e );
  //
  // }


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

  // /**
  //  * Set event listeners, handlers
  //  */
  // _setListeners() {
  //
  //   super._setListeners();
  //
  //   // Editor Help dialog
  //   $( '#editor-help-btn' ).on( 'click',
  //                               () => new InformationDialog({ div: '#id-form-editor' }).show() );
  //
  //   // Node actions edit button click
  //   $( this.selector ).on( 'click', '#edit-node',
  //                          () => this.editNode( this.selected ) );
  //
  //   // Node actions edit button click
  //   $( this.selector ).on( 'focus', '#add-child',
  //                          e => this.childrenMenu( 'show', e ) );
  //
  //   // Node actions edit button click
  //   $( this.selector ).on( 'blur', '#add-child',
  //                          e => this.childrenMenu( 'hide', e ) );
  //
  //   // Node actions remove button click
  //   $( this.selector ).on( 'click', '#remove-node',
  //                          () => this.removeNode( this.selected ) );
  //
  //   // Node actions move up button click
  //   $( this.selector ).on( 'click', '#move-up',
  //                          () => this.moveNode( this.selected, 'up' ) );
  //
  //   // Node actions move down button click
  //   $( this.selector ).on( 'click', '#move-down',
  //                          () => this.moveNode( this.selected, 'down' ) );
  //
  //   // Node actions make common button click
  //   $( this.selector ).on( 'click', '#common-node',
  //                           () => this.commonOrRestore( this.selected, 'make_common' ) );
  //
  //   // Node actions restore button click
  //   $( this.selector ).on( 'click', '#restore-node',
  //                          () => this.commonOrRestore( this.selected, 'restore' ) );
  //
  // }
  //
  /**
   * Preprocess data and convert it into a sorted D3 hierarchy
   * @override parent implementation
   * @param {Object} rawData Graph data fetched from the server
   */
  _preprocessData(rawData) {

    return this.d3.hierarchy( rawData, d => [
        ...d.is_top_concept||[],
        ...d.narrower||[]
      ]);

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
    console.log(rawData)

  }


  /**
   * Re-render node-actions on zoom (to keep position relative to node)
   * @extends _onZoom parent implementation
   */
  _onZoom() {

    super._onZoom();
    this._renderActions( this.selected );

  }

  // /**
  //  * On graph data update; re-render, extend edit token and focus on node if available
  //  * @param {FormNode} node Node to focus on after update, optional
  //  */
  // _onUpdate(node) {
  //
  //   this.render()._restoreGraph();
  //
  //   this.onEdited();
  //
  //   if (node) {
  //
  //     node.findElement();
  //     this.focusOn( node, false );
  //
  //     // Set element focus
  //     setTimeout( () => node.$.focus(), 100 );
  //
  //   }
  //
  // }
  //
  //
  // /** Keys ** /
  //
  //
  // /**
  //  * Handle graph key controls ( edit, move node up & down )
  //  * @extends _keyControls parent implementation
  //  * @param {event} e Key event object
  //  */
  // _keyControls(e) {
  //
  //   super._keyControls(e);
  //
  //   if ( e.shiftKey && e.which === 38 && this.selected ) // Shift + Arrow Up
  //     this.moveNode( this.selected, 'up' );
  //
  //   else if ( e.shiftKey && e.which === 40 && this.selected ) // Shift + Arrow Down
  //     this.moveNode( this.selected, 'down' );
  //
  //   else if ( !e.shiftKey && e.which === 69 && this.selected ) // E
  //     this.editNode( this.selected );
  //
  //   else if ( !e.shiftKey && (e.which === 46 || e.which === 8) && this.selected ) // Delete / Backspace
  //     this.removeNode( this.selected );
  //
  // }


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
    this.graph.nodes = renderLabels({
      nodes: this.graph.nodes,
      nodeColor: this.Node.color,
      labelProperty: 'pref_label',
      onHover: d => this._renderTooltip( new this.Node(d) ),
      onHoverOut: d => D3Tooltip.hide(),
      props: {
        radius: 5
      }
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
    //
    // // Toggle add-child button depending on node type
    // D3Actions.actions.find( '#add-child' )
    //                  .toggle( node.addChildAllowed );
    //
    // // Toggle Remove button depending on node type
    // D3Actions.actions.find( '#remove-node' )
    //                  .toggle( node.removeAllowed );

    D3Actions.show( node );

  }

  /**
   * Get the HTMLs for Action buttons to be rendered in node-actions
   * @return {Array} Array of HTML strings for node-action icon buttons
   */
  get _actionButtons() {

    return [
      iconBtn({ icon: 'edit', color: 'light', id: 'edit-node', ttip: 'Edit' }),
      iconBtn({ icon: 'plus', color: 'light', id: 'add-child', ttip: 'Add Child Tag' }),
      iconBtn({ icon: 'times', color: 'red', id: 'remove-node', ttip: 'Remove' }),
    ]

  }


  /** Tooltip **/


  /**
   * Render tooltip contents and show
   * @param {FormNode} node Node instance to show the tooltip at
   */
  _renderTooltip(node) {

    let html = `<div>
                  <div class='font-regular' style='color: ${ node.color }'> ${ node.label } </div>
                  ${ node.data.description }
                </div>`;

    D3Tooltip.show( html );

  }


  /** Support **/


  /**
   * Graph properties definitions
   * @extends _props parent parameters
   * @return {Object} Graph properties for tree, svg, zoom
   */
  get _props() {

    let props = super._props;

    // Custom node width
    props.tree.nodeWidth = 140;

    // Custom zoom values
    props.zoom.min = 0.3;
    props.zoom.max = 1.6;

    // Custom key controls
    // props.keys = props.keys.concat( [ 38, 40, 46, 8 ] );

    return props;

  }
  //
  // /**
  //  * Load modules that are required later on
  //  */
  // async _importModules() {
  //
  //   // Node Editor module
  //   let NodeEditor = await import( /* webpackPrefetch: true */
  //                                 'shared/forms/edit/form_node_editor' );
  //
  //   this.nodeEditor = new NodeEditor.default({
  //     formId: this.formId,
  //     onShow: () => this.keysDisable(),
  //     onHide: () => {
  //
  //       this.keysEnable();
  //       setTimeout( () =>
  //           this.selected.el.focus(), 300 ); // Restore focus
  //
  //     },
  //     onUpdate: () => {
  //
  //       this._onUpdate();
  //       alerts.success( 'Node updated successfully.', this._alertDiv );
  //
  //     }
  //   });
  //
  //   // Node Handler module
  //   let NodeHandler = await import( /* webpackPrefetch: true */
  //                                   'shared/forms/edit/form_node_handler' );
  //
  //   this.nodeHandler = new NodeHandler.default( this );
  //
  // }

}
