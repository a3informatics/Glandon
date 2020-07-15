import TablePanel from 'shared/base/table_panel';

import { dtFormShowColumns } from 'shared/helpers/dt_column_collections'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt'

/**
 * Form Show Panel
 * @description Shows form data
 * @extends TablePanel class from shared/base/table_panel
 * @requires table [@id = 'show']
 * @author Samuel Banas <sab@s-cubed.dk>
 * @author Clarisa Romero <car@s-cubed.dk>
 */
export default class ShowPanel extends TablePanel {

  /**
   * Create a Form Show Panel
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table (Optional)
   * @param {string} params.url Url of source data
   * @param {string} params.param Strict parameter name required for the controller params
   */
  constructor({
    selector = "#show-panel #show",
    url,
    param = "form",
  }) {
    super({
      selector,
      url,
      param,
      paginated: true,
      order: [[0, "asc"]],
      buttons: [csvExportBtn(), excelExportBtn()]
    });
  }

  /** Private **/

  /** Initializers and defaults **/

  /**
   * Extend default DataTable init options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {
    const options = super._tableOpts;

    options.createdRow = (r, data, idx) => {
      if (data.is_group || data.is_sub_group)
        $(r).addClass(data.is_group ? "row-title" : "row-subtitle");
    }

    return options;
  }

  /**
   * Get default column definitions for IsoManaged items
   * @return {Array} Array of DataTable column definitions
   */
  get _defaultColumns() {
    return dtFormShowColumns();
  }
}
