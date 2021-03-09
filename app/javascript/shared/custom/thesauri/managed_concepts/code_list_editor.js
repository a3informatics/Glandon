import CustomPropsEditablePanel from 'shared/base/custom_properties/cp_editable_panel'

import ItemsPicker from 'shared/ui/items_picker/v2/items_picker'
import { $ajax } from 'shared/helpers/ajax'
import { $confirm } from 'shared/helpers/confirmable'
import { isCDISC } from 'shared/helpers/utils'

import { dtCLEditColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtCLEditFields } from 'shared/helpers/dt/dt_field_collections'

/**
 * Code List Editor
 * @description DataTable-based Editor of a Code List (CRUD actions)
 * @extends CustomPropsEditablePanel module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CLEditor extends CustomPropsEditablePanel {

  /**
  * Create a CL Editor instance 
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
    selector = "#editor-panel #editor",
    helpDialogId = 'cl-edit',
    onEdited = () => {}
  }) {

    super({
      tablePanelOpts: {
        selector,
        dataUrl: urls.data,
        updateUrl: urls.update,
        param: "managed_concept",
        columns: dtCLEditColumns(),
        fields: dtCLEditFields()
      },
      enabled: true
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
   * @param {Array} children Set of objects containing properties: id - Unmanaged Concept id and contextI to be added to Code List
   * @param {string} param Name of the UC IDs parameter
   */
  addChildren(children, param = 'set_ids') {

    // Map children to array of objects with id and context_id props
    const data = children.map( ({ id, _context }) => 
      Object.assign( {}, { id, context_id: _context.id } )
    )

    this._executeRequest({
      url: this.urls.addChildren,
      type: 'POST',
      data: { 
        [param]: data 
      },
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
   * Sets event listeners, handlers
   * Used for table related listeners only
   */
  _setTableListeners() {

    super._setTableListeners();

    // Find table body selector 
    const $tableBody = $( `${ this.selector } tbody` );

    // Edit tags cell click
    $tableBody.on( 'click', 'td.editable.edit-tags', e => {

      const tagsUrl = this._getRowDataFrom$( e.target ).edit_tags_path;

      tagsUrl && window.open( tagsUrl, '_blank' ).focus();

    });

    // Remove item button click
    $tableBody.on( 'click', '.remove', e =>
          this.removeChild( this._getRowFrom$( e.target ) )
    );

  }

  /**
   * Sets event listeners, handlers
   * Used for non-table related listeners only!
   */
  _setListeners() {

    super._setListeners();

    // Add New Child button click
    $( '#new-item-button' ).on( 'click', () => 
      this.newChild() 
    );

    // Add Existing Child button click
    $( '#add-existing-button' ).on( 'click', () => 
      this.picker.show() 
    );

    // Refresh button click
    $( '#refresh-button' ).on( 'click', () => 
      this.refresh() 
    );

    // Help dialog button click
    $( '#editor-help' ).on( 'click', () =>
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

    let fData = super._preformatUpdateData( d );

    // If data present, the edited field is *not* a custom property 
    if ( d.data ) 
      d.edit = { 
        ...fData[0],
        with_custom_props: this.handler.hasData 
      }

    // Provide the parent (code list) id to the server 
    Object.assign( d.edit, { 
      parent_id: this.id
    });

    delete d.data;
    return fData;

  }

  /**
   * Formats the updated data returned from the server before being added to Editor
   * @override for custom behavior
   * @param {object} _oldData Data object sent to the server
   * @param {object} newData Data returned from the server
   */
  _postformatUpdatedData(_oldData, newData) {

    // Merge and update edited row data
    const editedRow = this.table.row( this.editor.modifier().row ),
          mergedData = Object.assign( {}, editedRow.data(), newData[0] );

    editedRow.data( mergedData );

  }

  
  /*** Support ***/


  /**
   * Perform a JSON server request based on given parameters
   * @param {string} url Url of the request
   * @param {string} type Type of the request
   * @param {objet} data Request data object (without strong parameter), optional
   * @param {function} callback Function to execute on request success
   */
  _executeRequest({ url, type, data = {}, callback }) {

    this._loading( true );

    $ajax({
      url, type, 
      contentType: 'application/json',
      data: JSON.stringify({ 
        managed_concept: data 
      }),
      done: d => {

        callback( d );
        this.onEdited();

      },
      always: () => this._loading( false )
    });

  }

  /**
   * Initialize Items Selector for adding Code List Items to the Code List
   */
  _initSelector() {

    this.picker = new ItemsPicker({
      id: "add-children",
      multiple: true,
      types: [ ItemsPicker.allTypes.TH_CLI ],
      description: 'Select one or more Code List Items to add to the Code List.',
      onSubmit: s => this.addChildren( s.asObjects() )
    });

  }

  /**
   * Check if item editable - item must a custom property or not be referenced
   * @extends _editable parent implementation
   * @param {object} modifier Contains the reference to the cell being edited
   * @returns {boolean} true/false ~~ enable/disable editing for the cell
   */
  _editable(modifier) {

    const { referenced } = this.table.row( modifier.row ).data();

    return super._editable( modifier ) || !referenced;

  }


  /**
   * Extend default Editable Panel options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {

    let options = super._tableOpts;

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
