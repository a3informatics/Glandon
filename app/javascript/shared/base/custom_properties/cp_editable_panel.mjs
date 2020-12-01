import EditablePanel from 'shared/base/editable_panel'

import CustomPropsEditableHandler from 'shared/helpers/custom_properties/cp_editable_handler'

/**
 * Custom Properties Editable Panel
 * @description Editable Panel extension with Custom Properties functionality
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CustomPropsEditablePanel extends EditablePanel {

  /**
   * Create a Custom Properties Table Panel instance
   * @param {Object} params Instance parameters
   * @param {Object} params.tablePanelOpts Specify general Table Panel options
   * @param {boolean} params.enabled Enables or disables Custom Properties functionality [default = true]
   * @param {integer} params.afterColumn Column index to insert Custom Property columns after [default = 5]
   * @param {function} params.onColumnsToggle Callback to when the CP columns are toggled, visible {boolean} passed as argument
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
      onColumnsToggle,
      
      handler: new CustomPropsEditableHandler({
        enabled, 
        afterColumn,
        selector: tablePanelOpts.selector,
        onColumnsToggle: visible => 
          this._onColumnsToggle( visible )
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
   * Callback to when Custom Property columns are toggled
   * @override for custom functionality
   * @param {boolean} visible New state of the Custom Property columns, false if invisible
   */
  _onColumnsToggle(visible) { 

    if ( this.onColumnsToggle )
      this.onColumnsToggle( visible );
  
  }

  /**
   * Formats the update data to be compatible with server
   * Applies special formatting if the edited field is a Custom Property
   * @param {object} d DataTables Editor data object being altered
   * @return {Array} Formatted data
   */
  _preformatUpdateData(d) {

    let fData = super._preformatUpdateData( d ),
        field = this.currentField;

    // Check if Custom Property value is being updated
    if ( this._isCustomProperty( field ) ) {

      // Format the data object and clear other data from the d object
      d.edit = this._formatData( fData[0], field );
      delete d.data;

    }

    return fData;

  }


  /*** Support ***/


  /**
   * Format update data of a Custom Property 
   * @param {object} data Preformatted, data object containing the edits and the id of the item 
   * @param {string} field Name of the currently edited field 
   * @return {object} Formatted CP data
   */
  _formatData(data, field) {
  
    return {
      custom_property: {
        id: data.id,
        value: data[field]
      }
    }
  
  }

  /**
   * Check if given field is a Custom Property
   * @param {string} field Field to check
   * @return {boolean} True if given field is a Custom Property
   */
  _isCustomProperty(field) {

    return ( this.handler.hasData ) &&
           ( this.handler.customProps
                       .definitions
                       .find( def => def.name === field ) != undefined )

  }

  /**
   * Check if current field is editable - true for custom properties
   * @param {object} modifier Contains the reference to the cell being edited
   * @returns {boolean} true/false ~~ enable/disable editing for the cell
   */
  _editable(modifier) {
    return this._isCustomProperty( this.fieldFromColumn( modifier.column ) );
  }

  /**
   * Custom Editor initialization options
   * @return {Object} Editor options object
   */
  get _editorOpts() {

    let options = super._editorOpts;

    if ( this.handler.hasData )
      options.fields = this.handler.mergeFields( options.fields );

    return options;

  }

  /**
   * Custom DataTable initialization options
   * @return {Object} DataTable initialization options object
   */
  get _tableOpts() {

    let options = super._tableOpts;

    // Enable horizontal scroll when table data wide
    options.scrollX = true;

    // Add Custom Properties button to table buttons
    options.buttons = this.handler.addButton( options.buttons );

    // Add Custom Properties columns if CP data available
    if ( this.handler.hasData )
      options.columns = this.handler.mergeColumns( options.columns );

    return options;

  }

}
