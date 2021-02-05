import EditablePanel from 'shared/base/editable_panel'

import { $confirm } from 'shared/helpers/confirmable'
import { alerts } from 'shared/ui/alerts'
import { $post, $delete } from 'shared/helpers/ajax'
import { jumpToRow, highlightRow } from 'shared/helpers/dt/utils'

import { dtSDTMSDDomainEditColumns } from 'shared/helpers/dt/dt_column_collections'
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
   * Create a SDTM SD Editor instance 
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
      columns: dtSDTMSDDomainEditColumns(),
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

        // On Edited callback (token extend)
        this.onEdited()

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
                        done: () => this.onEdited(),
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

    // Refresh button click
    $( '#refresh-button' ).on( 'click', () => 
      this.refresh() 
    );

    // Help dialog button click
    $( '#editor-help' ).on( 'click', () =>
      new InformationDialog({
        div: $( `#information-dialog-sdtm-edit` )
      }).show()
    );

  }

  /**
   * Formats the update data to be compatible with server
   * @param {object} d DataTables Editor data object
   */
  _preformatUpdateData(d) {

    const updateData = Object.keys( d.data ).map( id =>
      Object.assign( {}, { 
          ...d.data[ id ], 
          non_standard_var_id: id 
      } )
    )

    d.sdtm_sponsor_domain = { 
      ...updateData[0]
    }

    delete d.data;

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

    const { standard } = this.table.row( modifier.row ).data(),
          fieldName = this.table.column( modifier.column ).dataSrc()

    return standard === false || fieldName === 'used';

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
