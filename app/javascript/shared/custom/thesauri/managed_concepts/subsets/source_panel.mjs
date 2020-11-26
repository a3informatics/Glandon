import SelectablePanel from 'shared/base/selectable_panel'

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
      tablePanelOptions: {
        selector, url,
        param: 'managed_concept',
        autoHeight: true
      },
      multiple: true,
      allowAll: true,
      onSelect, onDeselect, loadCallback
    });

    Object.assign( this, {
      onDeselectAll
    });

  }


  /*** Private ***/


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

    return options;

  }

}
