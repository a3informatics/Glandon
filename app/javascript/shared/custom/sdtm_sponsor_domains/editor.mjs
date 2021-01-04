import EditablePanel from 'shared/base/editable_panel'

import { $confirm } from 'shared/helpers/confirmable'
import { alerts } from 'shared/ui/alerts'
import { $post, $delete } from 'shared/helpers/ajax'
import { jumpToRow, highlightRow } from 'shared/helpers/dt/utils'

import { dtSDTMIGDomainEditColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtSDTMSDEditFields } from 'shared/helpers/dt/dt_field_collections'
import { dtRowRemoveColumn } from 'shared/helpers/dt/dt_columns'

import { getEditorSelectOptions } from 'shared/helpers/dt/dt_metadata'
import { dtFieldsInit } from 'shared/helpers/dt/dt_fields'

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

    dtFieldsInit( ['truefalse'] );
    
    super({
      selector,
      dataUrl: urls.data,
      updateUrl: urls.updateVar,
      param: "sdtm_sponsor_domain",
      columns: dtSDTMIGDomainEditColumns(),
      fields: dtSDTMSDEditFields(),
      order: [[0, 'asc']],
      requiresMetadata: true,
      autoHeight: true
    }, {
      urls, onEdited
    })

  }

  /**
   * Create a blank new variable in the SDTM
   */
  newVariable() {

    this._loading( true )
    
    $post({
      url: this.urls.newVar,
      done: d => {
        
        this._render( [d] )

        // Jump to and highlight the new variable row
        jumpToRow( this.table, d )
        highlightRow( this.table, this._getRowFromData( 'id', d.id ) )

      },
      always: () => this._loading( false )
    })

  }

  /**
   * Remove a variable from the SDTM (if removal allowed)
   * @param {DataTable Row} dtRow Reference to the DT Row variable to be removed
   * @requires $confirm user confirmation
   */
  removeVariable(dtRow) {

    if ( this._removeNotAllowed( dtRow.data() ) ) {

      alerts.error( 'Variable is Standard and cannot be removed.' )
      return; 

    }

    $confirm({
      dangerous: true,
      callback: () => $delete({
                        url: this.urls.removeVar,
                        data: {
                          [ this.param ]: {
                            non_standard_var_id: dtRow.data().id
                          }
                        },
                        always: () => this.refresh()
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

    const $tableBody = $( `${ this.selector } tbody` );

    // Remove variable button click
    $tableBody.on( 'click', '.remove', e =>
      this.removeVariable( this._getRowFrom$( e.target ) )
    );

  }

  /**
   * Sets event listeners, handlers
   * Used for non-table related listeners only!
   */
  _setListeners() {

    super._setListeners();

    // Add New Variable button click
    $( '#new-variable-button' ).on( 'click', () => 
      this.newVariable() 
    );

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
   * Check if item editable - item must a custom property or not be referenced
   * @extends _editable parent implementation
   * @param {object} modifier Contains the reference to the cell being edited
   * @returns {boolean} true/false ~~ enable/disable editing for the cell
   */
  _editable(modifier) {

    const { standard } = this.table.row( modifier.row ).data();
    return super._editable( modifier ) || !standard;

  }

  /**
   * Check if variable remove is disallowed - only for 'standard' variables
   * @param {Object} data Variable data object to check removable 
   * @returns {boolean} True if variable is not-removable
   */
  _removeNotAllowed(data) {
    return data.standard === true
  }


  /**
   * Extend default Editable Panel options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {

    let options = super._tableOpts;

    options.columns = [ 
      ...this._defaultColumns, 
      ...this.extraColumns, 

      // Row Remove column
      dtRowRemoveColumn({ 
        text: 'Remove variable', 
        isDisabledFn: this._removeNotAllowed 
      }) 
    ]

    return options;

  }

}
