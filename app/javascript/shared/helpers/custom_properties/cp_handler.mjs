import { columnByDataType } from 'shared/helpers/dt/dt_custom_property_columns'
import { $get } from 'shared/helpers/ajax'
import { alerts } from 'shared/ui/alerts'
import CPButton from 'shared/helpers/custom_properties/cp_button'

/**
 * Custom Properties Handler module
 * @description Custom-property related functionality for a TablePanel-based module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CustomPropsHandler {

  /**
   * Create a Custom Properties Handler instance
   * @param {Object} params Instance parameters
   * @param {boolean} params.enabled Enables or disables Custom Properties functionality [default = true]
   * @param {integer} params.afterColumn Column index to insert Custom Property columns after
   * @param {function} params.onColumnsToggle Function to execute when the CP columns are toggled, visibility boolean passed as the first argument
   */
  constructor({
    enabled = true,
    afterColumn,
    onColumnsToggle = () => {}
  }) {

    Object.assign( this, {
      button: CPButton,
      enabled,
      afterColumn,
      onColumnsToggle,
      visible: false
    });

    // Set CP Button's onClick handler to this instances'
    this.button.onClick = () => this._onBtnClick();

  }

  /**
   * Set the table instance to Custom Properties Handler
   * @param {TablePanel} table Table Panel instance to handle
   */
  set table(table) {

    if ( !table )
      return;

    this.tablePanel = table;

    // Set the CPButton unique selector
    this.button.selector = `${ table.selector }_wrapper`;

  }


  /*** Data ***/


  /**
   * Fetch Custom Property data from the server
   */
  loadData() {

    this.button.loading( true );

    $get({
      url: customPropsUrl,
      rawResult: true,
      done: r => {

        if ( r && r.definitions.length )
          this._onDataLoaded( r );

        // No data returned
        else {
          alerts.warning( 'No Custom Property data found.' );
          this._toggleColumns( false );
        }

      },
      always: () => this.button.loading( false )
    });

  }

  /**
   * Merge Custom Property columns with Table columns on index specified by afterColumn
   * @param {Array} oColumns Original DT columns
   * @return {Array} Merged columns collection
   */
  mergeColumns(oColumns) {

    if ( !this.customProps || !this.customProps.definitions )
      return;

    // Map CP definitions to DT columns
    let { definitions } = this.customProps,
        columns = definitions.map( def => columnByDataType( def.datatype )( def.name ) ),
        index = this.afterColumn + 1;

    // Make a copy of the original columns array
    oColumns = [...oColumns];

    // Insert CP columns into the columns array
    oColumns.splice( index, 0, ...columns );

    return oColumns;

  }

  /**
   * Merge Table data with Custom Property data
   * Alters the given tableData collection
   * @param {Array} tableData Raw Table data collection to merge CP Data into
   */
  mergeData(tableData) {

    if ( !this.customProps || !this.customProps.data )
      return;

    tableData.forEach( dataItem => Object.assign(
      dataItem,
      this.customProps.data.find( d => d.id === dataItem.id )
    ));

  }


  /*** Renderers ***/


  /**
   * Render Custom Properties in this instance's table panel
   */
  _render() {

    // Cache table data
    const tableData = this.tablePanel.rowDataToArray;

    // Destroy DataTable instance
    this.tablePanel.destroy();

    // Render Custom Property header columns
    this._renderHeaders();

    // Merge table data with cp data
    this.mergeData( tableData );

    // Re-initialize table and render data
    this.tablePanel._initTable();
    this.tablePanel._render( tableData );

  }

  /**
   * Render the Custom Property column headers in the instance DataTable
   */
  _renderHeaders() {

    let { definitions } = this.customProps,

        // Reduce definitions into rendered jQuery header elements
        $headers = definitions.reduce( ($elements, definition) =>
          $elements.add(
            this._renderHeader( definition )
          ),
          $()
        );

    // Insert rendered headers into DOM, after header with specified index
    $headers.insertAfter( `${ this.tablePanel.selector } thead th:eq(${ this.afterColumn })` );

  }

  /**
   * Render a single Custom Property header
   * @param {object} definition Custom Property definition data object
   */
  _renderHeader(definition) {

    return $( '<th>' ).text( definition.label )
                      .addClass( 'custom-prop nowrap' );

  }


  /*** Events ***/


  /**
   * Process and render data on CP data, executed on CP data fetch
   * @param {object} result Raw data result object with definitions and data properties
   */
  _onDataLoaded(result) {

    Object.assign( this, {
      customProps: result
    });

    this._render();

    // Toggle Custom Property column visibility
    this._toggleColumns( true );

  }

  /**
   * Handle CP load and display, executed on CP Button click,
   */
  _onBtnClick() {

    // Return if custom properties are disabled
    if ( !this.enabled )
      return;

    // Toggle CP columns visibility if customProps data is available
    if ( this.customProps )
      this._toggleColumns( !this.visible );

    // Load CP data if none present
    else
      this.loadData();

  }


  /*** Support ***/


  /**
   * Toggle Custom Propety columns visibility and update UI
   * @param {boolean} visible Target Custom Property columns visibility state
   */
  _toggleColumns(visible) {

    // Update the visible property
    this.visible = visible;

    // Toggle custom-prop columns visibility
    this.tablePanel.table.columns( '.custom-prop' )
                         .visible( visible );

    // Update CP Button text
    this.button.text = visible ?
      this.button.strings.hide :
      this.button.strings.show;

    // On columns toggle callback
    this.onColumnsToggle && this.onColumnsToggle( visible );

    // Adjust column widths
    this.tablePanel.table.columns
                         .adjust();

  }

}
