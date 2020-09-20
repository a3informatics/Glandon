import FormNode from 'shared/forms/edit/form_node'
import ItemsPicker from 'shared/ui/items_picker/items_picker'

import { $post, $put, $delete } from 'shared/helpers/ajax'

import { $confirm } from 'shared/helpers/confirmable'
import { alerts } from 'shared/ui/alerts'
import { rdfTypesMap as rdfs } from 'shared/helpers/rdf_types'
import { renderMenuOnly } from 'shared/ui/context_menu'
import { isInViewport } from 'shared/helpers/utils'

/**
 * Node Handler
 * @description Handler for adding, removing and moving Form Nodes / Children
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class NodeHandler {

  /**
   * Create a Node Handler instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the wrapping panel
   * @param {string} params.formId ID of the currently edited form
   * @param {JQuery Element} params.alertDiv Div to display alerts & errors in
   * @param {Function} params.onUpdate Callback to execute on node update success
   * @param {Function} params.processData Function reference to convert raw data structure to a compatible d3 hierarchy
   * @param {Function} params.loading Loading function reference
   */
  constructor({
    selector,
    formId,
    alertDiv,
    onUpdate = () => {},
    processData = () => {},
    loading = () => {}
  } = {} ) {

    Object.assign( this, {
      selector, formId, alertDiv, onUpdate,
      processData, loading
    });

    this._initPicker();

  }

  /**
   * Add a child of specific type to a Node
   * @param {FormNode} node Node instance to add child/children to
   * @param {string} type Child/children type (rdf param value)
   */
  addChild(node, type) {

    this.node = node;

    // Expand node as children are being added
    node.expand();

    // Check for param types requiring an Items Picker
    type === rdfs.BC_GROUP.param || type === rdfs.TUC_REF.param ?
      this._pickChildren( type ) :
      this._addChild( type )

  }

  /**
   * Open / close Node's add children context menu
   * @param {string} state Target menu state ( show / hide )
   * @param {FormNode} node Node instance
   * @param {event} e Event that triggered state change ( focus / blur )
   */
  childrenMenu(state, node, e) {

    this.node = node;

    if ( state === 'show' )
      this._showMenu( e );

    else if ( state === 'hide' )
      this._hideMenu( e );

  }

  /**
   * Move a Node in given direction
   * @param {FormNode} node Node instance to add child/children to
   * @param {string} dir Direction to move Node ( up / down )
   */
  move(node, dir) {

    // Validate direction
    if ( dir !== 'up' && dir !== 'down' )
      return;

    this.node = node;

    let sibling = dir === 'up' ?
                  node.previous :
                  node.next

    if ( sibling )
      this._move( dir );
    else
      alerts.warning( `Cannot move Node ${ dir }.`, this.alertDiv );

  }

  /**
   * Remove a Node upon user confirmation
   * @requires $confirm
   * @param {FormNode} node Node instance to remove
   */
  remove(node) {

    this.node = node;

    $confirm({
      subtitle: `This action will remove the selected Node and all
                 its descendats and cannot be undone.`,
      dangerous: true,
      callback: () => this._remove()
    });

  }


  /** Add Child **/


  /**
   * Make an Add Child request to server, handle response (current instance Node)
   * @param {string} type Child/children type (rdf param value)
   * @param {array | null} extraData Additional data to include in request, or null if none
   */
  _addChild(type, extraData = null) {

    let url = this._addChildUrl,
        data = this._makeRequestData( 'add', type, extraData );

    this.loading( true );

    $post({
      url,
      data,
      contentType: 'application/json',
      errorDiv: this.alertDiv,
      done: d => {

        let result = this._appendData( d );

        this.onUpdate( result );
        alerts.success( 'Added successfully.', this.alertDiv );

      },
      always: () => this.loading( false )
    });

  }

  /**
   * Initialize and open an Items Picker with parameters dependent on the type argument
   * @param {string} type Child/children type (rdf param value)
   */
  _pickChildren(type) {

    let disableType,
        onSubmit;

    // Pick from BCs
    if ( type === rdfs.BC_GROUP.param ) {

      disableType = rdfs.TH_CLI.param;
      onSubmit = s => this._addChild( type, s.asIDsArray() );

    }

    // Pick from Unmanaged Concepts
    else if ( type === rdfs.TUC_REF.param ) {

      disableType = rdfs.BC.param;
      onSubmit = (s) => {

        let ids = s.asObjectsArray()
                   .map( o => { return { id: o.id, context_id: o.context.id } });

        this._addChild( type, ids );

      }
    }

    else
      return;

    // Init and show picker
    this.picker.onSubmit = onSubmit;
    this.picker.disableTypes( [ disableType ] )
               .show();

  }

  /**
   * Append new nodes to Node children
   * @param {object | array} data Child/children data object(s) to append to Node
   * @return {FormNode | undefined} Returns added child Node instance or undefined if mulitple children were added
   */
  _appendData(data) {

    // Merge multiple data items into Node
    if ( Array.isArray(data) ) {

      data.forEach( d => this._mergeIntoNode( this.processData(d) ) );
      return;

    }

    // Merge single item data into Node
    let child = new FormNode(
      this.processData( data ),
      false
    );
    this._mergeIntoNode( child.d );

    return child;

  }

  /**
   * Merge data object and its descendants into current Node's children collection
   * @param {object} data Child data object to marge into Node children
   */
  _mergeIntoNode(data) {

    let node = this.node.d;

    data.height = node.height;
    data.parent = node;

    if ( node.children )
      node.children.push( data );
    else
      node.children = [ data ];

    // Update depth of new node descendants offset by current Node depth
    data.descendants().forEach( d => d.depth += node.depth + 1 );

  }


  /** Move **/


  /**
   * Make a move by ordinal value server request (current instance Node)
   * @param {string} dir Direction of movement ( up / down )
   */
  _move(dir) {

    let url = this._moveUrl( dir ),
        data = this._makeRequestData( 'move' );

    this.loading( true );

    $put({
      url,
      data,
      contentType: 'application/json',
      errorDiv: this.alertDiv,
      done: d => {

        let sibling = dir === 'up' ?
                      this.node.previous :
                      this.node.next;

        this.node.swapOrdinals( sibling );
        this.node.parent.sortChildren();

        this.onUpdate();
        alerts.success( 'Moved successfully.', this.alertDiv );

      },
      always: () => this.loading( false )
    });

  }


  /** Remove **/


  /**
   * Make a delete Node request to server (current instance Node)
   */
  _remove() {

    let url = this._nodeUrl,
        data = this._makeRequestData( 'remove' )

    this.loading( true );

    $delete({
      url,
      data,
      contentType: 'application/json',
      errorDiv: this.alertDiv,
      done: d => {

        this.node.parent.removeChild( this.node );
        this.onUpdate( this.node.parent );
        alerts.success( 'Node removed successfully.', this.alertDiv );


      },
      always: () => this.loading( false )
    });

  }


  /** Children Menu **/


  /**
   * Shows a Context Menu with children options
   * @param {Event} e Focus event that trigerred the show action
   */
   _showMenu(e) {

    if ( !this.node.addChildAllowed || this._menuOpen )
      return;

    let $target = $( e.currentTarget ),

        // Render menu HTML
        $menu = $(
          renderMenuOnly({
            menuItems: this._menuItems,
            menuStyle: { color: 'light', size: 'small' }
          })
        );

    // Append menu to DOM
    $target.append( $menu );

    // Update menu css if outside of viewport
    $menu.css( 'display', 'block' )
         .toggleClass( 'top', !this._menuInViewport );

    this._setMenuListeners( $menu );

  }

  /**
   * Hides the Children Context Menu
   * @param {event} e Event (blur) that trigerred menu hide, optional
   */
  _hideMenu(e) {

    // Do not hide menu if focused element is a child option
    if ( e && $( e.relatedTarget ).hasClass('option') )
      return;

    $( this.selector ).find( '.node-actions .context-menu' )
                      .remove()

  }

  /**
   * Set event listeners to the children menu options
   * @param {JQuery Element} menu Context Menu element
   */
  _setMenuListeners(menu) {

    $( menu ).on( 'click', 'a.option', e => {

      let type = $( e.currentTarget ).prop( 'id' );
      this.addChild( this.node, type );

    });

  }

  /**
   * Get Menu Items definitions for permitted child types of current Node instance
   * @return {array} Definitions of menu options to be rendered
   */
  get _menuItems() {

    return this.node.childTypes.map( type =>

      Object.assign({
        id: rdfs[type].param,
        url: '#',
        text: rdfs[type].name,
        icon: 'icon-plus'
      })

    );

  }

  /**
   * Check if menu is within parent viewport or not
   * @param {JQuery element} menu Menu element to assess
   * @return {boolean} Returns false if menu portion overflows parent
   */
  get _menuInViewport() {

    let menu = $( this.selector ).find('.node-actions .context-menu'),
        parent = $( this.selector ).find( '#d3 svg' );

    return isInViewport( parent, menu, 1 );

  }

  /**
   * Check if a context menu is open within node-selector element
   * @return {boolean} Returns true if context menu exists within node-actions
   */
  get _menuOpen() {
    return $( this.selector ).find('.node-actions .context-menu').length > 0;
  }


  /** Support **/


  /**
   * Get a URL to Node instance
   * @return {string} URL pointing to current Node instance
   */
  get _nodeUrl() {
    return `${ this.node.rdfObject.url }/${ this.node.data.id }`
  }

  /**
   * Get a URL to add child action
   * @return {string} URL pointing to current Node's add_child action
   */
  get _addChildUrl() {
    return `${ this._nodeUrl }/add_child`
  }

  /**
   * Get a URL to move node action
   * @param {string} dir Move direction: up / down
   * @return {string} URL pointing to current Node's move action
   */
  _moveUrl(dir) {
    return `${ this._nodeUrl }/move_${ dir }`
  }

  /**
   * Get request data object for specific action and item type
   * @param {string} action Request action - add / remove / move
   * @param {string} type Item type (rdf param value) (only for 'add' action)
   * @param {?} extraData Additional data, optional
   * @return {json} Stringified data object for a server request
   */
  _makeRequestData(action, type, extraData = null) {

    let param = this.node.rdfObject.param,
        data = {}

    data[ param ] = {
      form_id: this.formId
    }

    // Add children request data
    if ( action === 'add' ) {

      data[ param ].type = type;

      if ( extraData )
        data[ param ].id_set = extraData;

    }

    // Remove / Move Node request data
    else if ( action === 'remove' || action === 'move' )
      data[ param ].parent_id = this.node.parent.data.id;

    return JSON.stringify( data );

  }

  /**
   * Initialize Items Picker instance for selecting BCs and CLIs
   */
  _initPicker() {

    this.picker = new ItemsPicker({
      id: 'node-add-child',
      types: [ rdfs.BC.param, rdfs.TH_CLI.param ],
      multiple: true,
      description: 'Pick one or more items to be added into the selected node.'
    });

  }

}
