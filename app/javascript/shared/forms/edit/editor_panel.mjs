import d3 from 'shared/base/d3/tree/d3_tree'

import TreeGraph from 'shared/base/d3/tree/tree_graph'
import FormNode from 'shared/forms/edit/form_node'
import NodeEditor from 'shared/forms/edit/form_node_editor'

import { D3Tooltip } from 'shared/helpers/d3/renderers/tooltip'
import { D3Actions } from 'shared/helpers/d3/renderers/actions'

import { $get, $post } from 'shared/helpers/ajax'
import { $confirm } from 'shared/helpers/confirmable'
import { iconTypes } from 'shared/ui/icons'
import { iconBtn } from 'shared/ui/buttons'
import { getRdfNameByType as nameFromRdf, rdfTypesMap as rdfs } from 'shared/helpers/rdf_types'
import colors from 'shared/ui/colors'
import { renderMenuOnly } from 'shared/ui/context_menu'
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
   * @param {object} params.urls Must contain urls for 'data', 'update'
   * @param {string} params.selector JQuery selector of the editor panel
   * @param {function} params.onEdited Callback executed on any edit action
   */
  constructor({
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
      onEdited, urls,
      nodeEditor: new NodeEditor()
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


  /** Editor actions **/


  /**
   * Makes server request to remove node, handles update
   * @confirmable
   * @param {FormNode} node Node instance to remove
   */
  removeNode(node) {

    if ( !node )
      return;

    $confirm({
      callback: () => {
        node.d.parent.children.splice( ( node.d.parent.children.indexOf( node.d ) ), 1 );

        if (node.d.parent.children.length === 0)
          delete node.d.parent.children;

        this.render()._restoreGraph();
      },
      dangerous: true
    });

  }

  /**
   * Makes server request to move node up or down, handles update
   * @param {FormNode} node Node instance to move
   * @param {string} dir Direction of movement 'up' or 'down'
   */
  moveNode(node, dir) {

    if ( !node )
      return;

    // Update call

    switch (dir) {
      case 'up':
        console.log('Moved up');
        break;
      case 'down':
        console.log('Moved down');
        break;
    }

  }

  /**
   * Opens a node Editor window
   * @param {FormNode} node Node instance to edit
   */
  editNode(node) {

    if ( this.nodeEditor )
      this.nodeEditor.edit( node );

  }


  /******* Private *******/


  /**
   * Set event listeners, handlers
   */
  _setListeners() {

    super._setListeners();

    // Node actions edit button click
    $( this.selector ).on( 'click', '#edit-node',
                           () => this.editNode( this.selected ) );

    // Node actions edit button click
    $( this.selector ).on( 'focus', '#add-child',
                           (e) => this._showAddChildMenu( this.selected, e ) );

    // Node actions edit button click
    $( this.selector ).on( 'focusout', '#add-child',
                           (e) => this._hideAddChildMenu() );

    // Node actions remove button click
    $( this.selector ).on( 'click', '#remove-node',
                           () => this.removeNode( this.selected ) );

    // Node actions move up button click
    $( this.selector ).on( 'click', '#move-up',
                           () => this.moveNode( this.selected, 'up' ) );

    // Node actions move down button click
    $( this.selector ).on( 'click', '#move-down',
                                    () => this.moveNode( this.selected, 'down' ) );

  }

  /**
   * Preprocess data and convert it into a D3 hierarchy
   * @override parent implementation
   * @param {Object} rawData Graph data fetched from the server
   */
  _preprocessData(rawData) {

    return d3.hierarchy( rawData, (d) =>[
        ...d.has_group||[],
        ...d.has_common||[],
        ...d.has_item||[],
        ...d.has_sub_group||[],
        ...d.has_coded_value||[]
      ]);

  }


  /** Referenced Items **/


  /**
   * Fetch additional referenced item data from the server
   */
  _loadReferences() {

    this._loadingExtra( true );

    $get({
      url: this.urls.refData,
      done: (refData) => this._appendReferences(refData),
      always: () => this._loadingExtra( false )
    });

  }

  /**
   * Append reference data to the graph structure and re-render graph
   * @param {Object} refData The raw refences data from the server (Keys: reference ids, Values: referenced item data)
   */
  _appendReferences(refData) {

    // Expand to make sure all nodes are in the graph
    this.expandAll( false );

    // Select reference nodes and append data
    d3.selectAll( '.node.reference' )
      .each( (d) => {
        let referenced = refData[d.data.id];

        if ( referenced ) {
          d.data.label = referenced.label
          d.data.referenceData = referenced
        }
      });

    this.render()
        ._restoreGraph();

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

    super._onDataLoaded(rawData)
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

  _onRenderComplete() {

    if ( this.nodeEditor.isOpen )
      this.nodeEditor.render();

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
   * Render Nodes in customis style (with icons and labels)
   */
  _renderNodes() {

    // Add Icons and Labels to rendered Nodes
    this.graph.nodes = renderIconsLabels({
      nodes: this.graph.nodes,
      nodeIcon: this.Node.icon,
      nodeColor: this.Node.color,
      onHover: (d) => this._renderTooltip( new this.Node(d) ),
      onHoverOut: (d) => D3Tooltip.hide()
    })

    // Override nodes class attribute to build a custom class list
    this.graph.nodes.attr( 'class', (d) => this._nodeClassList( new this.Node(d) ) );

  }


  /** Node Actions **/


  /**
   * Render node-actions element with buttons at a given node
   * @param {FormNode} node Node instance to render the node-actions element at
   */
  _renderActions(node) {

    if ( !node )
      return;

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


  /** Node Add-Child Menu **/


  /**
   * Shows a Context Menu with addable children options
   * @param {FormNode} node Node instance to render the add-child menu for
   * @param {Event} e Focus event that trigerred the action
   */
   _showAddChildMenu(node, e) {

    //  Map allowed children RDFs into Menu item list
    let menuItems = this._addChildrenTypes( node ).map( (rdf) => {
      return { text: rdf.name, url: '#', icon: 'icon-plus' }
    }),
    //  Raw menu HTML
    menuHTML = renderMenuOnly({
      menuStyle: { color: 'light', size: 'small' },
      menuItems
    }),
    //  Styled menu element
    $menu = $( menuHTML ).css( 'display', 'block' );

    $( e.currentTarget ).append( $menu );

  }

  /**
   * Hides a Context Menu with addable children options
   */
  _hideAddChildMenu() {

    $( this.selector ).find( '.node-actions .context-menu' )
                      .remove();

  }


  /** Tooltip **/


  /**
   * Render tooltip contents and show
   * @param {FormNode} node Node instance to show the tooltip at
   */
  _renderTooltip(node) {

    let html = `<div>` +
                  `<div class='font-regular' style='color: ${ node.color }'> ${ node.rdfName } </div>` +
                  ( node.disabled ? '<i>Disabled</i> <br>' : '') +
                  `${ node.data.label }` +
               `</div>`;

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
    if ( node.disabled )
      classList += ' disabled'
    if ( node.isReference )
      classList += ' reference'

    return classList;

  }

  /**
   * Get a list of allowed children types for a given node
   * @param {FormNode} node Node instance to generate the list for
   * @return {Array} RDF Objects of types allowed as children for a given node
   */
  _addChildrenTypes(node) {

    switch( node.rdf ) {
      case rdfs.FORM.rdfType:
        return [ rdfs.NORMAL_GROUP ]
        break;
      case rdfs.NORMAL_GROUP.rdfType:
        return [ rdfs.NORMAL_GROUP, rdfs.COMMON_GROUP, rdfs.BC_GROUP,
                 rdfs.QUESTION, rdfs.MAPPING, rdfs.TEXTLABEL, rdfs.PLACEHOLDER ]
        break;
      case rdfs.QUESTION.rdfType:
        return [ rdfs.TUC_REF ]
        break;
    }

    return [];

  }


  /**
   * Graph properties definitions
   * @extends _props parent parameters
   * @return {Object} Graph properties for tree, svg, zoom
   */
  get _props() {

    let props = super._props;

    // Custom rightOffset
    props.tree.rightOffset = 30;

    // Custom zoom values
    props.zoom.min = 0.3;
    props.zoom.max = 1.6;

    return props;

  }

}
