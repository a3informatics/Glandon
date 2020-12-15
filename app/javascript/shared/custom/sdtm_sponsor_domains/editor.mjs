import EditablePanel from 'shared/base/editable_panel'

// import { $confirm } from 'shared/helpers/confirmable'

import { dtSDTMIGDomainEditColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtSDTMSDEditFields } from 'shared/helpers/dt/dt_field_collections'

import { getEditorSelectOptions } from 'shared/helpers/dt/dt_metadata'

/**
 * SDTM Sponsor Domain Editor 
 * @description DataTable-based Editor of a SDTM Sponsor Domain
 * @extends EditablePanel module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SDTMSDEditor extends EditablePanel {

  /**
  * Create a SDTMSD Editor instance 
   * @param {Object} params Instance parameters
   * @param {object} params.urls Must contain urls for 'data', 'update', 'newChild' and 'addChildren'
   * @param {string} params.selector JQuery selector of the target table
   * @param {function} params.onEdited Callback for Timer extend called on any Edit action
   */
  constructor({
    urls,
    selector = "#editor-panel #editor",
    onEdited = () => {}
  }) {

    super({
      selector,
      dataUrl: urls.data,
      updateUrl: urls.update,
      param: "sdtm_sponsor_domain",
      columns: dtSDTMIGDomainEditColumns(),
      fields: dtSDTMSDEditFields(),
      order: [[0, 'asc']],
      requiresMetadata: true
    }, {
      id, urls, onEdited
    })

  }


  /**
   * Create a new child in Code List
   */
  newChild() {

    // this._executeRequest({
    //   url: this.urls.newChild,
    //   type: 'POST',
    //   data: {
    //     identifier: 'SERVERIDENTIFIER'
    //   },
    //   callback: () => this.refresh()
    // });

  }

  /**
   * Remove or unlink item from the Code List
   * @param {DataTable Row} childRow Reference to the DT Row instance to be removed
   * @requires $confirm user confirmation
   */
  removeChild(childRow) {

    // $confirm({
    //   subtitle: `This action will remove the Code List Item reference from this Code List.
    //              If it is its only parent, the item will be removed from the system.`,
    //   dangerous: true,
    //   callback: () => this._executeRequest({
    //                     url: childRow.data().delete_path,
    //                     type: 'DELETE',
    //                     callback: () => this.removeItems( childRow )
    //                   })
    // });

  }


  /** Private **/


  /**
   * Sets event listeners, handlers
   * Used for table related listeners only
   */
  _setTableListeners() {

    super._setTableListeners();

  }

  /**
   * Sets event listeners, handlers
   * Used for non-table related listeners only!
   */
  _setListeners() {

    super._setListeners();

    // // Add New Child button click
    // $( '#new-item-button' ).on( 'click', () => 
    //   this.newChild() 
    // );

  }

  /**
   * Formats the update data to be compatible with server
   * @param {object} d DataTables Editor data object
   */
  _preformatUpdateData(d) {

    console.log(d);
    // let fData = super._preformatUpdateData( d );

    // // If data present, the edited field is *not* a custom property 
    // if ( d.data ) 
    //   d.edit = { 
    //     ...fData[0],
    //     with_custom_props: this.handler.hasData 
    //   }

    // // Provide the parent (code list) id to the server 
    // Object.assign( d.edit, { 
    //   parent_id: this.id
    // });

    // delete d.data;
    // return fData;

  }

  // /**
  //  * Formats the updated data returned from the server before being added to Editor
  //  * @override for custom behavior
  //  * @param {object} _oldData Data object sent to the server
  //  * @param {object} newData Data returned from the server
  //  */
  // _postformatUpdatedData(_oldData, newData) {

  //   // Merge and update edited row data
  //   const editedRow = this.table.row( this.editor.modifier().row ),
  //         mergedData = Object.assign( {}, editedRow.data(), newData[0] );

  //   editedRow.data( mergedData );

  // }

  /**
   * Loads additional metadata - options for Editor select fields
   */
  _loadMetadata() {

    this._loadingExtra( true );

    getEditorSelectOptions({ 
      url: this.urls.metadata, 
      editor: this.editor, 
      always:() => 
        this._loadingExtra( false )
    })

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

    return options;

  }

}
