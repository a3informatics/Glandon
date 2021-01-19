import TablePanel from 'shared/base/table_panel'

import { dtManagedItemsColumns } from 'shared/helpers/dt/dt_column_collections'
import { hasColumn } from 'shared/helpers/dt/utils'

/**
 * Managed Items Panel
 * @description Lists a collection of version-based Managed Items of various rdf types 
 * @extends TablePanel class from shared/base/table_panel
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ManagedItemsPanel extends TablePanel {

  /**
   * Create a Managed Items Panel instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique selector of the parent element
   * @param {string} params.url Url of source data
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {int} params.count Count of items fetched in one request [default = 5000]
   * @param {boolean} params.deferLoading Set to true if data load should be deferred. Load data has to be called manually in this case. Optional
   * @param {boolean} params.paginated Paginated request option, optional [default = false]
   * @param {object} params.tableOptions DataTable custom options, optional 
   * @param {array} params.buttons Buttons to add to the table, optional
   */
  constructor({
    selector,
    url,
    param,
    count = 5000,
    deferLoading = false,
    paginated = false,
    tableOptions = {},
    buttons = []
  }) {

    super({ 
      selector: `${ selector } #managed-items`,
      order: [[1, "asc"]],
      url, param, count, 
      deferLoading, paginated, tableOptions, buttons 
    })

  }
  

  /** Private **/


  /**
   * Get default column definitions for IsoManaged items
   * @return {Array} Array of DataTable column definitions
   */
  get _defaultColumns() {

    const withType = hasColumn( this.selector, 'Type' )
    return dtManagedItemsColumns( {}, withType )

  }

}
