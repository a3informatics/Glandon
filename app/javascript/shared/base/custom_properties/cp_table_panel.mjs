import TablePanel from 'shared/base/table_panel'

import CustomPropsHandler from 'shared/helpers/custom_properties/cp_handler'

/**
 * Custom Properties Table Panel
 * @description Simple Table Panel extension with Custom Properties functionality
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CustomPropsTablePanel extends TablePanel {

  /**
   * Create a Custom Properties Table Panel instance
   * @param {Object} params Instance parameters
   * @param {Object} params.tablePanelOpts Specify general Table Panel options
   * @param {boolean} params.enabled Enables or disables Custom Properties functionality [default = true]
   * @param {integer} params.afterColumn Column index to insert Custom Property columns after [default = 5]
   * @param {function} params.onColumnsToggle Function to execute when the CP columns are toggled, visibility boolean passed as the first argument
   */
  constructor({
    tablePanelOpts = {},
    enabled = true,
    afterColumn = 5,
    onColumnsToggle = () => {}
  }) {

    super({
      ...tablePanelOpts,
      autoHeight: true
    }, {
      handler: new CustomPropsHandler({
        enabled,
        afterColumn,
        onColumnsToggle: visible => this._onColumnsToggle( visible )
      })
    });

  }

  /**
   * Initialize the Table Panel, disable Custom Properties button
   */
  initialize() {

    super.initialize();

    // Pass this instance to customPropsHandler
    this.handler.table = this;

    // Disable CP Button inititally, until the data fully loads
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
   * Callback to when Custom Property columns are toggled
   * @override for custom functionality
   * @param {boolean} visible New state of the Custom Property columns, false if invisible
   */
  _onColumnsToggle(visible) { }


  /*** Support ***/


  /**
   * Custom DataTable initialization options
   * @return {Object} DataTable initialization options object
   */
  get _tableOpts() {

    let options = super._tableOpts;

    // Enable horizontal scroll when table data wide
    options.scrollX = true;

    // Add Custom Properties button to table buttons
    if ( this.handler.enabled )
      options.buttons = [
        ...options.buttons,
        this.handler.button.definition
      ];

    if ( this.handler.enabled && this.handler.customProps )
      options.columns = this.handler.mergeColumns( options.columns );


    return options;

  }

}
