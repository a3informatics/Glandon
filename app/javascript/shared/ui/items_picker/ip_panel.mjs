import SelectablePanel from 'shared/base/selectable_panel'

/**
 * Custom Item Picker Panel implementation
 * @description A selectable panel that can be used in the Item Picker modal with custom DT init settings
 * @extends SelectablePanel class from shared/base/selectable_panel
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class IPPanel extends SelectablePanel {

  /**
   * Create a Item Picker Panel
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table
   * @param {string} params.url Url of source data
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {int} params.count Count of items fetched in one request
   * @param {Array} params.extraColumns Additional column definitions
   * @param {boolean} params.paginated Specify if the loadData call should be paginated. Optional, default = true
   * @param {Array} params.order DataTables deafult ordering specification, optional. Defaults to first column, descending
   * @param {function} params.loadCallback Callback to data fully loaded, optional
   * @param {element} params.errorDiv Custom element to display flash errors in, optional
   * @param {boolean} params.multiple Enable / disable selection of multiple rows [default = false]
   * @param {boolean} params.showSelectionInfo Enable / disable selection info on the table
   * @param {boolean} params.ownershipColorBadge Enable / disable showing a color-coded ownership badge
   * @param {function} params.onSelect Callback on row(s) selected, optional
   * @param {function} params.onDeselect Callback on row(s) deselected, optional
   */
  constructor({
    selector,
    url,
    param,
    count,
    extraColumns = [],
    paginated = true,
    order = [[0, "desc"]],
    loadCallback = () => {},
    errorDiv,
    multiple = false,
    showSelectionInfo = true,
    ownershipColorBadge = false,
    onSelect = () => { },
    onDeselect = () => { },
  }) {
    super({ selector, url, param, count, extraColumns, deferLoading: true, paginated, order, loadCallback, errorDiv,
      multiple, showSelectionInfo, ownershipColorBadge, onSelect, onDeselect });
  }


  /** Private **/


  /**
   * Extend default SelectablePanel init options with UI changes
   * @return {Object} DataTable options object
   */
  get _tableOpts() {
    const options = super._tableOpts;

    options.pageLength = 10;
    options.lengthChange = false;
    options.scrollY = 400;
    options.scrollCollapse = true;
    options.autoWidth = true;


    return options;
  }

}
