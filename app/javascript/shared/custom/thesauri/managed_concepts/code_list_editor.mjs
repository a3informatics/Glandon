import EditablePanel from 'shared/base/editable_panel'

import ItemsPicker from 'shared/ui/items_picker/items_picker'
import { $ajax } from 'shared/helpers/ajax'
import { $confirm } from 'shared/helpers/confirmable'
import { isCDISC } from 'shared/helpers/utils'

import { dtCLEditColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtCLEditFields } from 'shared/helpers/dt/dt_field_collections'

/**
 * Code List Editor
 * @description DataTable-based Editor of a Code List (CRUD actions)
 * @extends EditablePanel class from shared/base/editable_panel
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CLEditor extends EditablePanel {

  /**
   * Create a Panel
   * @param {Object} params Instance parameters
   * @param {string} params.id ID of the currently edited item
   * @param {object} params.urls Must contain urls for 'data', 'update', 'newChild' and 'addChildren'
   * @param {string} params.selector JQuery selector of the target table
   * @param {string} params.helpDialogId ID of the information dialog containing help
   * @param {function} params.onEdited Callback for Timer extend called on any Edit action
   */
  constructor({
    id,
    urls,
    selector = "#editor-panel table#editor",
    helpDialogId = 'cl-edit',
    onEdited = () => {}
  }) {

    super({
      selector,
      dataUrl: urls.data,
      updateUrl: urls.update,
      param: "managed_concept",
      columns: dtCLEditColumns(),
      fields: dtCLEditFields()
    });

    Object.assign(this, {
      id, urls, helpDialogId, onEdited
    });

    this._initSelector();

  }

  /**
   * Create a new child in Code List
   */
  newChild() {

    this._executeRequest({
      url: this.urls.newChild,
      type: 'POST',
      data: {
        identifier: 'SERVERIDENTIFIER'
      },
      callback: () => this.refresh()
    });

  }

  /**
   * Add one or more existing Code List Items to Code List
   * @param {Array} childrenIds Set of Unmanaged Concept IDs to be added to Code List
   * @param {string} param Name of the UC IDs parameter
   */
  addChildren(childrenIds, param = 'set_ids') {

    let data = {}
    data[param] = childrenIds;

    this._executeRequest({
      url: this.urls.addChildren,
      type: 'POST',
      data,
      callback: () => this.refresh()
    });

  }

  /**
   * Remove or unlink item from the Code List
   * @param {DataTable Row} childRow Reference to the DT Row instance to be removed
   * @requires $confirm user confirmation
   */
  removeChild(childRow) {

    $confirm({
      subtitle: `This action will remove the Code List Item reference from this Code List.
                 If it is its only parent, the item will be removed from the system.`,
      dangerous: true,
      callback: () => this._executeRequest({
                        url: childRow.data().delete_path,
                        type: 'DELETE',
                        callback: () => this.removeItems( childRow )
                      })
    });

  }


  /** Private **/


  /**
   * Perform a server request based on given parameters
   * @param {string} url Url of the request
   * @param {string} type Type of the request
   * @param {objet} data Request data object (without strong parameter), optional
   * @param {function} callback Function to execute on request success
   */
  _executeRequest({ url, type, data = {}, callback }) {

    this._loading( true );

    $ajax({
      url, type,
      data: { managed_concept: data },
      done: d => {

        callback( d );
        this.onEdited();

      },
      always: () => this._loading( false )
    });

  }

  /**
   * Sets event listeners, handlers
   */
  _setListeners() {

    // Call super's _setListeners first
    super._setListeners();

    // Edit tags
    $( this.selector ).on( 'click', 'tbody td.editable.edit-tags', e => {

      const editTagsUrl = this._getRowDataFrom$( e.target ).edit_tags_path;

      if ( editTagsUrl )
        window.open( editTagsUrl, '_blank' ).focus();

    })

    // Add New Child
    $( '#new-item-button' ).on( 'click', () => this.newChild() );

    // Add Existing Child
    $( '#add-existing-button' ).on( 'click', () => this.itemSelector.show() );

    // Refresh
    $( '#refresh-button' ).on( 'click', () => this.refresh() );

    // Remove item
    $( this.selector ).on( 'click', 'tbody .remove', e =>
          this.removeChild( this._getRowFrom$( e.target ) )
    );

    // Help dialog
    $('#editor-help').on('click', () =>
          new InformationDialog({
            div: $( `#information-dialog-${ this.helpDialogId }` )
          }).show()
    );

  }

  /**
   * Formats the update data to be compatible with server
   * @param {object} d DataTables Editor data object
   */
  _preformatUpdateData(d) {

    const itemId = Object.keys( d.data )[0];

    d.edit = d.data[itemId];
    d.edit.parent_id = this.id;

    delete d.data;

  }

  /**
   * Formats the updated data returned from the server before being added to Editor
   * @override for custom behavior
   * @param {object} oldData Data object sent to the server
   * @param {object} newData Data returned from the server
   */
  _postformatUpdatedData(oldData, newData) {

    // Merge and update edited row data
    let editedRow = this.table.row( this.editor.modifier().row );
        newData = Object.assign( editedRow.data(), newData[0] );

    editedRow.data( newData );

  }

  /**
   * Initialize Items Selector for adding Code List Items to the Code List
   */
  _initSelector() {

    this.itemSelector = new ItemsPicker({
      id: "add-children",
      multiple: true,
      types: ['unmanaged_concept'],
      onSubmit: s => this.addChildren( s.asIDsArray() )
    });

  }

  /**
   * Check if item editable - must have referenced data property set to true
   * @override super's _editable
   * @param {object} modifier Contains the reference to the cell being edited
   * @returns {boolean} true/false ~~ enable/disable editing for the cell
   */
  _editable(modifier) {
    return !this.table.row( modifier.row ).data().referenced;
  }


  /**
   * Extend default Editable Panel options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {

    let options = super._tableOpts;

    options.scrollX = true;
    options.autoWidth = true;

    // CSS Styling for editable rows
    options.createdRow = (row, data) => {

      let rowClass = data.referenced ?
                        isCDISC( data.uri ) ?
                          'row-cdisc' :
                          'row-disabled' :
                          'row-sponsor';

      $( row ).addClass( rowClass );

    }

    return options;

  }

}
