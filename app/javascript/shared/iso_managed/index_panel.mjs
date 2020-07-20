import TablePanel from 'shared/base/table_panel'

import { dtHistoryColumn } from 'shared/helpers/dt/dt_columns'

/**
 * Index Panel
 * @description Lists any type of IsoManaged items.
 * @extends TablePanel class from shared/base/table_panel
 * @requires table [@id = 'index']
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class IndexPanel extends TablePanel {

  /**
   * Create an Index Panel
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table (Optional)
   * @param {string} params.url Url of source data
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {int} params.count Count of items fetched in one request [default = 5000]
   * @param {Array} params.extraColumns Additional column definitions besides owner, identifier, or label. Optional
   * @param {boolean} params.deferLoading Set to true if data load should be deferred. Load data has to be called manually in this case. Optional
   * @param {boolean} params.cache Specify if the panel data should be cached. Optional.
   */
  constructor({
    selector = "#index-panel #index",
    url,
    param,
    count = 5000,
    extraColumns = [],
    deferLoading = false,
    cache = true,
    buttons = []
  }) {
    super({ selector, url, param, count, extraColumns, cache, buttons });
  }

  /** Private **/

  /**
   * Get CSS class for the table row based on item owner
   * @param {string} owner owner of the item
   * @return {string} CSS class name for CDISC / sponsor row style
   */
  _rowClassByOwner(owner){
    return owner.toLowerCase() === 'cdisc' ? 'row-cdisc' : 'row-sponsor';
  }

  /**
   * Get default column definitions for IsoManaged items
   * @return {Array} Array of DataTable column definitions
   */
  get _defaultColumns() {
    return [
      {data : "owner"},
      {data : "identifier"},
      {data : "label"}
    ];
  }

  /**
   * Extend default DataTable init options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {
    const options = super._tableOpts;

    options.columns = [...this._defaultColumns, ...this.extraColumns, dtHistoryColumn() ];
    options.language.emptyTable = "No items found.";
    options.createdRow = (row, data, idx) => {
      $(row).addClass(this._rowClassByOwner(data.owner));
    }

    return options;
  }

}
