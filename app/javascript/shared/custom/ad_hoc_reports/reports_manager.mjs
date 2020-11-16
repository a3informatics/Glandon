import TablePanel from 'shared/base/table_panel'

import { dtTrueFalseColumn, dtContextMenuColumn, dtDateTimeColumn } from 'shared/helpers/dt/dt_columns'
import { render as renderMenu } from 'shared/ui/context_menu'
import { $confirm } from 'shared/helpers/confirmable'
import { $delete } from 'shared/helpers/ajax'
import ItemsPicker from 'shared/ui/items_picker/items_picker'

/**
 * Ad Hoc Reports Index Manager
 * @extends TablePanel base module
 * @description A simple DT-based Ad Hoc Reports Manager allowing to run and remove reports
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ReportsManager extends TablePanel {

  /**
   * Create a Reports Manager instance
   * @param {Object} params Instance parameters
   * @param {string} params.dataUrl Reports index data url
   * @param {boolean} params.deleteAllowed Specifies whether the user may remove reports
   */
  constructor({
    dataUrl,
    deleteAllowed
  }) {

    super({
      selector: '#reports-index #main',
      url: dataUrl,
      paginated: false,
      param: 'ad_hoc_report',
      cache: false,
      order: [[0, 'asc']]
    });

    Object.assign( this, {
      deleteAllowed,
      itemsPicker: new ItemsPicker({
        id: 'report-param',
        types: [ 'thesauri' ]
      })
    });

  }

  /**
   * Delete a Report if permitted, handle response
   * @param {DataTable Row} row Reference to the DT Row in which the target report is located
   */
  deleteReport(row) {

    if ( !this.deleteAllowed )
      return;

    // Require user confirmation
    $confirm({
      dangerous: true,
      callback: () => {

        this._loading( true );

        // Execute delete request
        $delete({
          url: row.data().report_path,
          done: () => row.remove().draw(),
          always: () => this._loading( false )
        });

      }
    })

  }

  /**
   * Init and open Items Picker for user to select Report targets - parameters
   * @param {Object} report Report data object
   */
  pickTargets(report) {

    let { description, type } = report.parameters[0];

    this.itemsPicker.disableTypesExcept( [type] )
                    .setDescription( description );

    // On submit handler - redirect with parameters
    this.itemsPicker.onSubmit = s => {

      let ids = s.asIDsArray();

      if ( ids.length )
        location.href = this._reportUrlWithParameters( report, ids );

    }

    this.itemsPicker.show();

  }


  /*** Private ***/


  /**
   * Set event listeners and handlers
   */
  _setListeners() {

    // Report delete button click
    this._clickListener({
      target: ".context-menu a:contains('Delete')",
      handler: e => this.deleteReport( this._getRowFrom$( e.currentTarget ) )
    });

    // Parameterized Report run button click
    this._clickListener({
      target: ".context-menu a:contains('Run')[href='#']",
      handler: e => this.pickTargets( this._getRowDataFrom$( e.currentTarget ) )
    });

  }

  /**
   * Generate a Run URL for given parametrized Report with data
   * @param {Object} report Report data object
   * @param {Object} data Parameters data (array of target item ids)
   * @return {string} Run report url with encoded data
   */
  _reportUrlWithParameters(report, parameters) {

    let data = {}
    data[this.param] = { query_params: parameters }

    return `${ report.run_path }?${ $.param(data)}`;

  }

  /**
   * Context menu builder for each Report instance
   * @param {Object} data Report data object
   * @return {string} Rendered Context Menu for Report instance
   */
  _buildContextMenu(data) {

    let menuStyle = {
            side: 'left',
            color: 'blue'
          },
          menuItems = [{
            url: data.parameters.length ? null : data.run_path,
            icon: 'icon-history',
            target: data.parameters.length ? '#' : null,
            text: 'Run'
          },
          {
            url: data.results_path,
            icon: 'icon-copy',
            text: 'Results'
          }];

    if ( this.deleteAllowed )
      menuItems.push({
        target: '#',
        icon: 'icon-trash',
        text: 'Delete'
      })

    return renderMenu({ menuItems, menuStyle });

  }

  /**
   * Get default column definitions for Reports panel
   * @return {Array} Array of DataTable column definitions
   */
  get _defaultColumns() {

    return [
      { data: 'label' },
      { render: (data, t, r, m) => r.parameters.length ? r.parameters[0].name : 'None' },
      dtDateTimeColumn('last_run'),
      dtTrueFalseColumn( 'active', { orderable: false } ),
      dtContextMenuColumn( this._buildContextMenu.bind( this ) )
    ];

  }

}
