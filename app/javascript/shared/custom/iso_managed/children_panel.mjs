import CustomPropsTablePanel from 'shared/base/custom_properties/cp_table_panel'

import { dtButtonColumn, dtIndicatorsColumn } from 'shared/helpers/dt/dt_columns'
import { dtChildrenColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtCLExtensibleColumn } from 'shared/helpers/dt/dt_columns'

/**
 * Children Table Panel
 * @description Lists children items of a managed item, supports Custom Properties
 * @extends CustomPropsTablePanel module
 * @requires table [@id = 'children']
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ChildrenPanel extends CustomPropsTablePanel {

  /**
   * Create a Children Panel
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table (Optional)
   * @param {string} params.url Url of source data
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {integer} params.count Count of items fetched in one request [default = 5000]
   * @param {Array} params.extraColumns Additional column definitions besides owner, identifier, or label. Optional
   * @param {boolean} params.deferLoading Set to true if data load should be deferred. Load data has to be called manually in this case. Optional
   * @param {boolean} params.cache Specify if the panel data should be cached. Optional.
   * @param {Array} params.buttons DT buttons definitions objects, optional
   * @param {boolean} params.customPropsEnabled Enables or disables Custom Properties functionality [default = false]
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
    customPropsEnabled = false
  }) {

    super({
      tablePanelOpts: {
        selector, url, param, count, extraColumns,
        deferLoading, cache, buttons
      },
      enabled: customPropsEnabled
    });

  }


  /** Private **/


  /**
   * Update Definition column width, called on Custom Properties columns visiblity change
   * @override parent
   * @param {boolean} visible New state of the Custom Property columns, false if invisible
   */
  _onColumnsToggle(visible) {

    super._onColumnsToggle( visible );

    // Retain definition column width (otherwise shrinks width too much)
    this.$wrapper.find( 'th:contains("Definition")' )
                 .toggleClass( 'th-xwide', visible );


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
