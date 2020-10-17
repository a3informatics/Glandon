import TablePanel from 'shared/base/table_panel'

import { $delete } from 'shared/helpers/ajax'
import { $confirm } from 'shared/helpers/confirmable'

import { dtTrueFalseColumn } from 'shared/helpers/dt/dt_columns'
import { iconBtn, showBtn } from 'shared/ui/buttons'

/**
 * Imports Manager Panel
 * @description Simple DT-based display and remove Imports manager
 * @extends TablePanel base module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ImportsManager extends TablePanel {

  /**
   * Create an Imports Manager instance
   * @param {Object} params Instance parameters
   * @param {string} params.dataUrl Imports data url
   * @param {string} params.deleteAllUrl Delete all imports url
   * @param {integer} params.refreshRate Data reload rate in ms, optional
   */
  constructor({
    dataUrl,
    deleteAllUrl,
    refreshRate = 10000,
  }) {

    super({
      selector: '#imports-index #main',
      url: dataUrl,
      param: 'imports',
      paginated: false,
      order: [[1, 'asc']]
    },
    {
      refreshRate,
      deleteAllUrl
    });

    // Periodically refresh data
    this._startRefreshInterval();

  }

  /**
   * Remove one or all Imports
   * @param {DataTable Row} row DT Row containing the Import to be removed
   * @param {boolean} removeAll Optional flag to remove all Imports at once [default=false]
   */
  removeImport(row, removeAll = false) {

    $confirm({
      dangerous: true,
      callback: () => {

        this._loading( true );

        $delete({
          url: removeAll ? this.deleteAllUrl : row.data().import_path,
          done: () => {

            this._startRefreshInterval(); // Restart refresh interval

            // Update UI upon removal
            removeAll ?
              this.clear() :
              row.remove().draw();

          },
          always: this._loading( false )
        });

      }
    })

  }

  /**
   * Get the parent div
   * @return {JQuery Element} Imports panel parent div
   */
  get div() {
    return $( '#imports-index' );
  }


  /*** Private ***/


  /**
   * Set event listeners, handlers
   */
  _setListeners() {

    // Remove single import table click event
    $( this.selector ).on( 'click', '.remove-import', e =>
            this.removeImport( this._getRowFrom$( e.currentTarget ) ) );

    // Remove all imports click event
    this.div.find( '#remove-all-imports' )
            .on( 'click', () => this.removeImport( null, true ) );

  }

  /**
   * Start the interval that refreshes the panel data based on the instance's refreshRate
   */
  _startRefreshInterval() {

    // Clear interval if already exists
    if ( this.refreshInterval )
      clearInterval( this.refreshInterval );

    this.refreshInterval = setInterval( () => this.refresh(), this.refreshRate );

  }


  /**
   * Change panel's loading state
   * @param {boolean} enable value corresponding to the desired loading state on/off
   */
  _loading(enable) {

    super._loading( enable );

    this.div.find( '.btn' )
            .toggleClass( 'disabled', enable );

  }

  /**
   * Get default column definitions for Imports panel
   * @return {Array} Array of DataTable column definitions
   */
  get _defaultColumns() {

    return [
      { data: 'id', orderable: false },
      { data: 'owner' },
      { data: 'identifier' },
      { data: 'input_file' },
      dtTrueFalseColumn( 'complete', { orderable: false } ),
      dtTrueFalseColumn( 'success', { orderable: false } ),
      dtTrueFalseColumn( 'auto_load', { orderable: false } ),
      // Rendr show & delete Import buttons
      {
        orderable: false,
        render: (data, t, r, m) => {

          let showButton = showBtn( r.import_path ),
              deleteButton = iconBtn({
                color: 'red remove-import',
                icon: 'trash'
              });

          return `<div style='white-space: nowrap;'>
                    ${showButton} ${deleteButton}
                  </div>`;

        }
      }
    ];

  }

  /**
   * Import panel table options
   * @return {Object} Custom DataTable initialization options object
   */
  get _tableOpts() {

    let opts = super._tableOpts;

    opts.searching = false;
    opts.paging = false;
    opts.info = false;
    opts.scrollY = 500;
    opts.scrollX = true;
    opts.scrollCollapse = true;

    return opts;

  }

}
