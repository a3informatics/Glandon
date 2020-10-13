import TablePanel from 'shared/base/table_panel'

import { $get } from 'shared/helpers/ajax'
import { renderSpinner } from 'shared/ui/spinners'

/**
 * Ad Hoc Report Viewer
 * @description A simple DT-based Ad Hoc Report Viewer
 * @extends TablePanel base module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ReportViewer extends TablePanel {

  /**
   * Create a Reports Viewer instance
   * @param {Object} params Instance parameters
   * @param {string} params.dataUrl Report data url
   * @param {string} params.statusUrl Report progress status url
   * @param {integer} params.statusInterval Report progress request check interval in ms
   */
  constructor({
    dataUrl,
    statusUrl,
    statusInterval = 10000
  }) {

    super({
      url: dataUrl,
      selector: 'table#results',
      order: [[0, "asc"]],
      deferLoading: true
    })

    Object.assign( this, {
      statusUrl,
      statusInterval
    });

    this.getStatus();

  }

  /**
   * Get the report progress status and handle response. Repeats each statusInterval if report status is running.
   */
  getStatus() {

    this._loading( true, 'Database query running' );

    $get({
      url: this.statusUrl,
      done: r => {

        if ( r.running )
          setTimeout( () => this.getStatus(), 10000 );

        // Load report data if not running
        else {
          this._loading( true, 'Loading results' );
          this.loadData();
        }

      }
    });

  }


  /*** Private ***/


  /**
   * Change panel's loading state
   * @param {boolean} enable value corresponding to the desired loading state on/off
   * @param {string} text Text to display with loading, optional
   */
  _loading(enable, text) {

    if ( text )
      $( '#results_processing' ).html( renderSpinner( 'small', text ) );

    super._loading( enable );

  }

  /**
   * DT initialization options, custom
   * @return {object} Customized DataTable options
   */
  get _tableOpts() {

    let opts = super._tableOpts;

    delete opts.columns;
    opts.scrollX = true;

    return opts;

  }

}
