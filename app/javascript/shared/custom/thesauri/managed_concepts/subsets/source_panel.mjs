import SelectablePanel from 'shared/base/selectable_panel'

import CustomPropsHandler from 'shared/helpers/custom_properties/cp_handler'
import { dtChildrenColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtIndicatorsColumn } from 'shared/helpers/dt/dt_columns'

/**
 * Simple Source Panel for Subset Editor
 * @description DataTable-based Source Panel (for Subset) based on a SelectablePanel
 * @extends SelectablePanel module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SourcePanel extends SelectablePanel {

  /**
   * Create a SourcePanel instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the subset table
   * @param {string} params.url Source Panel data url
   * @param {function} params.loadCallback Callback executed on data loaded
   * @param {function} params.onSelect Callback executed on row select
   * @param {function} params.onDeselect Callback executed on row deselect
   * @param {function} params.onDeselectAll Callback executed on all rows deselect
   */
  constructor({
    selector,
    url,
    loadCallback = () => {},
    onSelect = () => {},
    onDeselect = () => {},
    onDeselectAll = () => {}
  }) {

    super({
      // Selectable Panel options
      multiple: true,
      allowAll: true,
      onSelect, onDeselect, loadCallback,

      // Default Table Panel options
      tablePanelOptions: {
        selector, url,
        param: 'managed_concept',
        autoHeight: true
      }
    }, {
      onDeselectAll,

      // Custom Props Handler init
      handler: new CustomPropsHandler({
        selector,
        enabled: true,
        afterColumn: 5,
        onColumnsToggle: visible => loadCallback()
      })
    });

    // Disable CP Button inititally, until the data fully loads
    this.handler.button.disable();

  }

  /**
   * Initialize the Table Panel
   */
  initialize() {

    super.initialize();

    // Pass this instance to customPropsHandler
    this.handler.table = this;

  }

  /**
   * Refresh (reload) table data, resets handler to initial state
   * @param {string} url optional, specify data source url
   */
  refresh(url) {

    super.refresh(url);

    this.handler.reset();
    // Disable CP Button until the data fully loads
    this.handler.button.disable();

  }


  /*** Private ***/


  /**
   * Executed when table data fully loaded, enable Custom Properties button
   */
  _onDataLoaded() {

    super._onDataLoaded();

    // Enable CP Button after data loaded
    this.handler.button.enable();

  }

  /**
   * Custom deselectAll callback
   */
  _deselectAll() {
    this.onDeselectAll();
  }


  /*** Support ***/


  /**
   * Get Source Panel default column definitions
   * @return {Array} Source Panel column definitions collection
   */
  get _defaultColumns() {

    return [
      ...dtChildrenColumns(),
      dtIndicatorsColumn()
    ];

  }

  /**
   * Extend default DataTable init options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {

    const options = super._tableOpts;

    options.scrollX = true;

    // Add Custom Properties button to table buttons
    options.buttons = this.handler.addButton( options.buttons );

    // Add Custom Properties columns if CP data available
    if ( this.handler.hasData )
      options.columns = this.handler.mergeColumns( options.columns );

    return options;

  }

}
