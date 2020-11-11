import CPTablePanel from 'shared/base/custom_props_table_panel'

import { dtButtonColumn, dtIndicatorsColumn } from 'shared/helpers/dt/dt_columns'
import { dtChildrenColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtCLExtensibleColumn } from 'shared/helpers/dt/dt_columns'

/**
 * Children Panel
 * @description Lists children items of a managed item.
 * @extends TablePanel class from shared/base/table_panel
 * @requires table [@id = 'children']
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ChildrenPanel extends CPTablePanel {

  /**
   * Create a Children Panel
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
    selector = "#children-panel #children",
    url,
    param,
    count = 5000,
    extraColumns = [],
    deferLoading = false,
    cache = true,
    buttons = [],
    cpEnabled = false
  }) {

    super({
      selector, url, param, count,
      extraColumns, cache, buttons, cpEnabled
    });

  }


  /** Private **/


  /**
   * Toggle Custom Propety columns UI, maintain width of the item definition column
   * @param {boolean} visible Target Custom Property columns visibility state
   */
  _toggleCPColumns(visible) {

    // Retain definition column width (otherwise shrinks width too much)
    this.$wrapper.find( 'th:contains("Definition")' )
                 .toggleClass( 'th-xwide', visible );

    super._toggleCPColumns( visible );


  }

  /**
   * Get default column definitions for Children items
   * @return {Array} Array of DataTable column definitions
   */
  get _defaultColumns() {

    let childrenColumns = dtChildrenColumns();

    // Add 'extensible' column for thesaurus children
    if ( this.param === 'thesauri' )
      childrenColumns.splice( 4, 0, dtCLExtensibleColumn() );

    return childrenColumns;

  }

  /**
   * Extend default DataTable init options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {

    let options = super._tableOpts;

    options.columns = [
        ...options.columns,
        dtIndicatorsColumn({ withoutVersions: true }),
        dtButtonColumn('show')
    ];

    options.language.emptyTable = 'No child items.';

    return options;

  }

}
