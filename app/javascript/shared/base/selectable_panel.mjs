import TablePanel from 'shared/base/table_panel'

import { isCDISC } from 'shared/helpers/utils'
import { selectAllBtn, deselectAllBtn } from 'shared/helpers/dt/utils'

/**
 * Base Selectable Panel (Table)
 * @description Extensible Selectable DataTable panel
 * @extends TablePanel class from shared/base/table_panel
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SelectablePanel extends TablePanel {

  /**
   * Create a Selectable Panel
   * @param {Object} params Instance parameters
   * @param {string} params.tablePanelOptions Options for the base table panel, required
   * @param {boolean} params.showSelectionInfo Enable / disable selection info on the table
   * @param {boolean} params.ownershipColorBadge Enable / disable showing a color-coded ownership badge
   * @param {boolean} params.allowAll Specifies whether buttons to select / deselect all rows should be rendered
   * @param {function} params.onSelect Callback on row(s) selected, passes selected row instances as argument, optional
   * @param {function} params.onDeselect Callback on row(s) deselected, passes deselected row instances as argument, optional
   * @param {Object} args Optional additional arguments
   */
  constructor({
    tablePanelOptions = {},
    multiple = false,
    showSelectionInfo = true,
    ownershipColorBadge = false,
    allowAll = false,
    onSelect = () => { },
    onDeselect = () => { }
  }) {

    if ( allowAll )
      Object.assign( tablePanelOptions, { buttons: [ selectAllBtn(), deselectAllBtn() ] });

    super(
      { ...tablePanelOptions },
      { multiple, showSelectionInfo, ownershipColorBadge, onSelect,
        onDeselect, allowAll }
    );

  }

  /**
   * Enables row selection for the user
   */
  enableSelect() { 
    if (this.multiple)
      this.table.select.style('multi');
    else
      this.table.select.style('single');
  }

  /**
   * Disables row selection for the user
   */
  disableSelect() { 
    this.table.select.style('api');
  }

  /**
   * Select one or more rows without trigerring the onSelect callback
   * @param {?} rows DT rows selector
   */
  selectWithoutCallback(rows) {
    this.skipSelectCallback = true;
    this.table.rows(rows).select();
    this.skipSelectCallback = false;
  }

  /**
   * Deselect one or more rows without trigerring the onSelect callback
   * @param {?} rows DT rows selector
   */
  deselectWithoutCallback(rows) {
    this.skipSelectCallback = true;
    this.table.rows(rows).deselect();
    this.skipSelectCallback = false;
  }

  /**
   * Get selected rows
   * @return {DataTables Rows} currently selected rows
   */
  get selected() {
    return this.table.rows({selected: true});
  }

  /**
   * Get selected rows' data objects
   * @return {Array} array of data objects of the currently selected rows
   */
  get selectedData() {
    return this.selected.data();
  }


  /** Private **/


  /**
   * Sets event listeners, handlers
   */
  _setListeners() {
    super._setListeners();

    // Row(s) selected
    this.table.on('select', (e, dt, t, indexes) => this._onSelect(indexes));

    // Row(s) deselected
    this.table.on('deselect', (e, dt, t, indexes) => this._onDeselect(indexes));
  }

  /**
   * Called when one or more rows are selected. Calls instance's onSelect by default
   * Override for custom behavior
   * @param {Array} indexes collection of zero-based indexes of the selected rows
   */
  _onSelect(indexes) { 
    if (!this.skipSelectCallback)
      this.onSelect(this.table.rows(indexes));
  }

  /**
   * Called when one or more rows are deselected. Calls instance's onDeselect by default
   * Override for custom behavior
   * @param {Array} indexes collection of zero-based indexes of the deselected rows
   */
  _onDeselect(indexes) {
    if (!this.skipSelectCallback)
      this.onDeselect(this.table.rows(indexes));
  }

  /**
   * Button definitions for select & deselect all rows
   * @return {Array} select & deselect all rows button definitions
   */
  get _allButtons() {
    return [ selectAllBtn() ];
  }

  /**
   * Extend default DataTable init options with select options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {
    const options = super._tableOpts;

    options.columns = [...this.extraColumns];
    options.language.emptyTable = "No items found.";
    // Selection settings
    options.select = {
      style: this.multiple ? 'multi' : 'single',
      info: this.showSelectionInfo
    }

    // Row owner styling
    if (this.ownershipColorBadge)
      options.createdRow = (row, data, idx) => {
        $(row).addClass( isCDISC(data) ? 'row-cdisc y' : 'row-sponsor b' );
      }

    return options;
  }
}
