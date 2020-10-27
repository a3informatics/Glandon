import { $delete } from 'shared/helpers/ajax'
import { $confirm } from 'shared/helpers/confirmable'
import { renderSpinner } from 'shared/ui/spinners'

/**
 * Uploads Manager
 * @description A simple Uploaded files panel with selectable and removable rows 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class UploadsManager {

  /**
   * Create an Uploads Manager instance
   * @param {Object} params Instance parameters
   * @param {string} params.removeUrl Url to clear one or more uploads
   * @param {string} params.removeAllUrl Url to clear all uploads
   */
  constructor({
    removeUrl,
    removeAllUrl,
  }) {

    Object.assign(this, {
      removeUrl,
      removeAllUrl,
      table: this._initTable()
    });

    this._setListeners();

  }

  /**
   * Get the uploads wrapping element
   * @return {JQuery Element} Wrapping parent element
   */
  get div() {
    return $( '#uploads-body' );
  }

  /**
   * Remove the given rows - items in the Uploads table
   * @param {DataTable Rows} items One or more DT Row objects to remove
   */
  remove(items) {

    // No items selected
    if ( items.count() === 0 )
      return;

    let { url, data } = this._makeParams( items );

    // User confirmation for deletion
    $confirm({
      dangerous: true,
      callback: () => {

        this._loading( true );

        // Delete request
        $delete({
          url,
          data,
          done: () => items.remove().draw(),
          always: () => this._loading( false )
        });

      }
    });

  }


  /*** Private ***/

  /**
   * Set event listeners, handlers
   */
  _setListeners() {

    // Select all button click
    this.div.find( '#select-all-files' )
            .on( 'click', () => this.table.rows().select() );

    // Deselect all button click
    this.div.find( '#deselect-all-files' )
            .on( 'click', () => this.table.rows().deselect() );

    // Remove selected button click
    this.div.find( '#remove-selected-files')
            .on( 'click', () => this.remove( this.table.rows({ selected: true }) ) );

  }

  /**
   * Generate the url and data parameters for remove request based on data
   * @param {DataTable Rows} items One or more DT Row objects to remove
   * @return {Object} Object containing the request url and data properties
   */
  _makeParams(items) {

    return {
      url: items.count() === this.table.rows().count() ?
                   this.removeAllUrl :
                   this.removeUrl,
      data: {
        upload: {
          files: items.data()
                      .toArray()
                      .map( r => r[0] === '' ? r[1] : (r[1] + '.' + r[0]) )
        }
      }
    }

  }

  /**
   * Toggle the loading state of the Uploads panel
   * @param {boolean} enable Desired loading state of the panel
   */
  _loading(enable) {

    this.table.processing( enable );

    this.div.find( '.btn' )
            .toggleClass( 'disabled', enable );

  }

  /**
   * Initialize the Uploads panel
   * @return {DataTable} Styled and selectable Datatable panel
   */
  _initTable() {

    return this.div.find( '#uploaded-files' ).DataTable({
      pageLength: pageLength,
      lengthMenu: pageSettings,
      processing: true,
      searching: false,
      paging: false,
      select: 'multi',
      scrollY: 400,
      scrollCollapse: true,
      scrollX: true,
      info: false,
      language: {
        infoFiltered: '',
        emptyTable: 'No files in the Uploads directory.',
        processing: renderSpinner( 'small' )
      }
    });

  }

}
