import TreeGraph from 'shared/base/d3/tree/tree_graph'
import TagNode from 'shared/custom/iso_concept_systems/d3/tag_node'

// import InformationDialog from 'shared/ui/dialogs/information_dialog'

import { D3Tooltip } from 'shared/helpers/d3/renderers/tooltip'
import { D3Actions } from 'shared/helpers/d3/renderers/actions'

import { iconBtn } from 'shared/ui/buttons'
import { cropText } from 'shared/helpers/strings'
import { alerts } from 'shared/ui/alerts'

import { renderLabels } from 'shared/helpers/d3/renderers/nodes'

/**
 * Tags Manager
 * @description D3 Tree graph-based Manager of Tags
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TagsManager extends TreeGraph {

  /**
   * Create a Tag Manager instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the editor panel
   * @param {object} params.urls Must contain urls for 'data', 'update', 'create'
   * @param {boolean} params.editable Specifies whether tags are editable or view-only [default=true]
   */
  constructor({
    selector = '#tags-tree',
    urls,
    editable = true
  }) {

    super({
      selector,
      dataUrl: urls.data,
      nodeModule: TagNode
    });

    Object.assign( this, {
      urls, editable
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

    if ( this.editable )
      D3Actions.destroy();

  }


  /** Tag Actions **/


  /**
   * Remove a Tag
   * @requires TagEditor
   * @param {TagNode} tag Tag instance to remove
   */
  removeTag(tag) {

    if ( this.tagEditor )
      this.tagEditor.remove( tag );

  }

  /**
   * Edit a Tag instance in Tag Editor
   * @requires TagEditor
   * @param {TagNode} tag Tag instance to edit
   */
  editTag(tag) {

    if ( this.tagEditor )
      this.tagEditor.edit( tag );

  }

  /**
   * Create a new Tag in Tag Editor
   * @requires TagEditor
   * @param {TagNode} tag Tag instance to add a child tag to
   */
  addTag(tag) {

    if ( this.tagEditor )
      this.tagEditor.addTag( tag );

  }


  /******* Private *******/


  /**
   * Initialize D3Tooltip and D3Actions modules with D3 library
   * @extends _init parent implementation
   */
  _init() {

    super._init();
    D3Tooltip.init( this.d3 );

    if ( this.editable )
      D3Actions.init( this.d3 );

  }

  /**
   * Set event listeners, handlers
   */
  _setListeners() {

    super._setListeners();

    // Tag Editor Help dialog
  //   $( '#editor-help-btn' ).on( 'click',
  //                               () => new InformationDialog({ div: '#id-form-editor' }).show() );

    // Actions edit button click
    $( this.selector ).on( 'click', '#edit-node',
                           () => this.editTag( this.selected ) );

    // Actions add child button click
    $( this.selector ).on( 'click', '#add-child',
                           () => this.addTag( this.selected ) );

    // Actions remove button click
    $( this.selector ).on( 'click', '#remove-node',
                           () => this.removeTag( this.selected ) );

  }

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
  * Select a given Tag and update styling, render node-actions
  * @extends _selectNode parent implementation
  * @param {TagNode} node Target tag instance
  * @param {boolean} toggle Specifies if tag deselect allowed, optional [default=true]
  */
  _selectNode(node, toggle = true) {

    super._selectNode( node, toggle );

    if ( this.editable ) {

      D3Actions.hide();

      if ( this.selected )
        this._renderActions( this.selected );

    }

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

  /**
   * Tag Node double click event, prevent graph zoom
   * @extends _onNodeDblClick parent implementation
   * @param {TagNode} tag Clicked Tag instance
   */
  _onNodeDblClick(tag) {

    super._onNodeDblClick( tag );

    if ( this.taggedItemsPanel )
      this.taggedItemsPanel.show( tag );

  }

  /**
   * On graph data update; re-process data, re-draw the graph and show alert
   * @param {string} message Success message to display
   */
  _onUpdate(message) {

    // Reprocess data
    this.graph.root = this._preprocessData( this.rawData );

    // Re-render graph
    this.render()._restoreGraph();

    // Display success message
    alerts.success( message, this._alertDiv );

  }


  /** Keys ** /


  /**
   * Handle graph key controls ( edit, add, remove tag )
   * @extends _keyControls parent implementation
   * @param {event} e Key event object
   */
  _keyControls(e) {

    super._keyControls(e);

    if ( !e.shiftKey && e.which === 69 && this.selected ) // E
      this.editTag( this.selected );

    else if ( !e.shiftKey && e.which === 65 && this.selected ) // A
      this.addTag( this.selected );

    else if ( !e.shiftKey && (e.which === 46 || e.which === 8) && this.selected ) // Delete / Backspace
      this.removeTag( this.selected );

  }


  /** Renderers **/


  /**
   * Render custom additional elements in the graph
   * @override parent implementation
   */
  _renderCustom() {

    this._renderNodes();

    D3Tooltip.new();

    if ( this.editable )
      D3Actions.new( this.selector, this._actionButtons );

  }

  /**
   * Render Nodes in custom style (with icons and labels)
   */
  _renderNodes() {

    // Custom render nodes with labels and colored circles
    this.graph.nodes = renderLabels({
      nodes: this.graph.nodes,
      nodeColor: this.Node.color,

      // Custom label property cropped at 14 characters
      labelProperty: d => cropText( d.data.pref_label, 14 ) || '...',

      // Tooltip render & hide on hover actions
      onHover: d => this._renderTooltip( new this.Node(d) ),
      onHoverOut: d => D3Tooltip.hide(),

      // Custom node circle radius
      props: {
        radius: 5
      }
    });

  }


  /** Node Actions **/


  /**
   * Render node-actions element with buttons at a given node
   * @param {TagNode} node Node instance to render the node-actions element at
   */
  _renderActions(node) {

    if ( !node || !this.editable )
      return;

    // Toggle edit button depending on node
    D3Actions.actions.find( '#edit-node' )
                     .toggle( node.editAllowed );

    // Toggle remove button depending on node type
    D3Actions.actions.find( '#remove-node' )
                     .toggle( node.removeAllowed );

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
   * @param {TagNode} node Node instance to show the tooltip at
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
    props.keys = props.keys.concat( [ 46, 8, 65 ] );

    return props;

  }

  /**
   * Load modules that are required later on
   */
  async _importModules() {

    // Tagged Items Panel module
    let TaggedItemsPanel = await import( /* webpackPrefetch: true */
                                  'shared/custom/iso_concept_systems/tagged_items_panel' );

    this.taggedItemsPanel = new TaggedItemsPanel.default({
      dataUrl: taggedItemsUrl,
      onShow: () => this.keysDisable(),
      onHide: () => {
        this.keysEnable();
        this.restoreFocus();
      }
    });

    if ( this.editable ) {

      // Tag Editor module
      let TagEditor = await import( /* webpackPrefetch: true */
                                    'shared/custom/iso_concept_systems/tag_node_editor' );

      this.tagEditor = new TagEditor.default({
        urls: this.urls,
        onLoading: enable => this._loading( enable ),
        onUpdate: message => this._onUpdate( message ),
        onShow: () => this.keysDisable(),
        onHide: () => {
          this.keysEnable();
          this.restoreFocus();
        }
      });

    }

  }

}
