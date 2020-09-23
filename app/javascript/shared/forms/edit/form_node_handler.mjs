import FormNode from 'shared/forms/edit/form_node'
import ItemsPicker from 'shared/ui/items_picker/items_picker'

import { $ajax } from 'shared/helpers/ajax'

import { $confirm } from 'shared/helpers/confirmable'
import { alerts } from 'shared/ui/alerts'
import { rdfTypesMap as rdfs } from 'shared/helpers/rdf_types'
import { renderMenuOnly } from 'shared/ui/context_menu'
import { isInViewport } from 'shared/helpers/utils'

/**
 * Node Handler
 * @description Handler for manipulating Form Nodes and their children
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

    if ( !node.addChildAllowed )
      return;

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

    if ( dir !== 'up' && dir !== 'down' ) // Validate direction
      return;

    this.node = node;

    let sibling = dir === 'up' ? node.previous : node.next;

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

    if ( !node.removeAllowed )
      return;

    this.node = node;

    $confirm({
      subtitle: `This action will remove the selected Node and all
                 its descendats and cannot be undone.`,
      dangerous: true,
      callback: () => this._remove()
    });

  }

  /**
   * Make a Node Common
   * @param {FormNode} node Node instance to make Common
   */
  makeCommon(node) {

    if ( !node.commonAllowed )
      return;

    this.node = node;

    this._commonOrRestore( 'make_common' );

  }

  /**
   * Restore a Node from being Common
   * @param {FormNode} node Node instance to Restore from Common
   */
  restoreCommon(node) {

    if ( !node.restoreAllowed )
      return;

    this.node = node;

    this._commonOrRestore( 'restore' );

  }

  /**
   * Executes a server request, handles loading, alerts and response
   */
  executeRequest({
    url,
    data,
    type,
    done,
    success = ''
  }) {

    this.loading( true );

    $ajax({
      url, data, type,
      contentType: 'application/json',
      errorDiv: this.alertDiv,
      done: d => {

        done(d);
        alerts.success( success, this.alertDiv );

      },
      always: () => this.loading( false )
    });

  }


  /** Add Child **/


  /**
   * Make an Add Child request to server, handle response (current instance Node)
   * @param {string} type Child/children type (rdf param value)
   * @param {array | null} extraData Additional data to include in request, or null if none
   */
  _addChild(type, extraData) {

    this.executeRequest({
      type: 'POST',
      url: this._nodeUrl + '/add_child',
      data: this._makeRequestData( 'add', type, extraData ),
      success: 'Added successfully.',
      done: d => this.onUpdate( this._appendData( d ) )
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

    this.executeRequest({
      type: 'PUT',
      url: this._nodeUrl + '/move_' + dir,
      data: this._makeRequestData( 'move' ),
      success: 'Moved successfully.',
      done: d => {

        let sibling = dir === 'up' ?
                      this.node.previous :
                      this.node.next;

        this.node.swapOrdinals( sibling );
        this.node.parent.sortChildren();

        this.onUpdate();

      }
    });

  }


  /** Remove **/


  /**
   * Make a delete Node request to server (current instance Node)
   */
  _remove() {

    this.executeRequest({
      type: 'DELETE',
      url: this._nodeUrl,
      data: this._makeRequestData( 'remove' ),
      success: 'Node removed successfully.',
      done: d => {

        this.node.parent.removeChild( this.node );
        this.onUpdate( this.node.parent );

      }
    });

  }


  /** Common / Restore **/


  /**
   * Make a Node common / restore request to server (current instance Node)
   * @param {string} action Target action (common / restore)
   */
  _commonOrRestore(action) {

    let type = action === 'restore' ?
               'DELETE' : 'POST';

    this.executeRequest({
      type,
      url: this._nodeUrl + '/' + action,
      data: this._makeRequestData( action ),
      success: 'Node updated successfully.',
      done: d => {

        // TODO: Append returned data
        this.onUpdate();

      }
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
   * Get request data object for specific action and item type
   * @param {string} action Request action - add / remove / move
   * @param {string} type Item type (rdf param value) (only for 'add' action)
   * @param {?} extraData Additional data, optional
   * @return {json} Stringified data object for a server request
   */
  _makeRequestData(action, type, extraData) {

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

    // Remove / Move Node require Node parent ID
    else if ( action === 'remove' || action === 'move' )
      data[ param ].parent_id = this.node.d.parent.data.id;

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
