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
   * @param {string} params.tablePanelOptions Options for the base table panel, required
   * @param {boolean} params.multiple Enable / disable selection of multiple rows [default = false]
   * @param {boolean} params.showSelectionInfo Enable / disable selection info on the table
   * @param {boolean} params.ownershipColorBadge Enable / disable showing a color-coded ownership badge
   * @param {boolean} params.allowAll Specifies whether buttons to select / deselect all rows should be rendered
   * @param {function} params.onSelect Callback on row(s) selected, optional
   * @param {function} params.onDeselect Callback on row(s) deselected, optional
   */
  constructor({
    tablePanelOptions = {},
    multiple = false,
    showSelectionInfo = true,
    ownershipColorBadge = false,
    allowAll = false,
    onSelect = () => { },
    onDeselect = () => { },
  }) {

    Object.assign( tablePanelOptions, { deferLoading: true } );

    super({
      tablePanelOptions,
      multiple, showSelectionInfo, ownershipColorBadge,
      onSelect, onDeselect, allowAll
    });

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
    options.scrollX = true;

    return options;
  }

}
