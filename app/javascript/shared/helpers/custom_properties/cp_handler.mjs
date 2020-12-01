import CPButton from 'shared/helpers/custom_properties/cp_button'
import { columnByDataType } from 'shared/helpers/dt/dt_custom_properties'
import { $get } from 'shared/helpers/ajax'
import { alerts } from 'shared/ui/alerts'
import { selectorToId } from 'shared/helpers/utils'

/**
 * Custom Properties Handler module
 * @description Custom-property related functionality for a TablePanel-based module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CustomPropsHandler {

  /**
   * Create a Custom Properties Handler instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique Table selector (which includes the target table id denoted by #)
   * @param {boolean} params.enabled Enables or disables Custom Properties functionality [default = true]
   * @param {integer} params.afterColumn Column index to insert Custom Property columns after
   * @param {function} params.onColumnsToggle Function to execute when the CP columns are toggled, visibility boolean passed as the first argument
   */
  constructor({
    selector,
    enabled = true,
    afterColumn,
    onColumnsToggle = () => {}
  }) {

    const { accessPolicy, dataUrl } = this._getOptions( selectorToId( selector ) );

    Object.assign( this, {
      dataUrl, afterColumn, onColumnsToggle,
      enabled: (enabled && accessPolicy),
      visible: false,
      button: new CPButton({
        selector,
        onClick: () => this._onBtnClick()
      })
    });

  }

  /**
   * Set the table instance to Custom Properties Handler
   * @param {TablePanel} table Table Panel instance to handle
   */
  set table(table) {

    if ( !table || !this.enabled )
      return;

    this.tablePanel = table;

  }

  /**
   * Check if Handler custom property data and definitions are present
   * @return {boolean} True if CP data is loaded and definitions are not empty
   */
  get hasData() {
    return ( this.customProps != null ) && ( this.customProps.definitions.length > 0 );
  }

  /**
   * Reset Custom Props handler to initial state - remove cp columns and data
   * Destroys and reinits TablePanel
   */
  reset() {

    if ( !this.enabled || !this.hasData )
      return;

    this._destroyExecuteInit( () => {

      // Delete customProps data
      delete this.customProps;

      // Remove Custom Property header columns
      $( `${ this.tablePanel.selector } thead th.custom-prop` ).remove();

    });

  }

  /**
   * Add the Custom Properties button to a given set of DT buttons
   * @param {Array} oButtons Source set of DT buttons (will not be altered)
   * @return A copy of the oButtons collection with the CP button attached at the end
   */
  addButton(oButtons) {

    if ( this.enabled )
      return [...oButtons, this.button.definition ]
    else
      return oButtons;

  }


  /*** Data ***/


  /**
   * Fetch Custom Property data from the server
   */
  loadData() {

    this.button.loading( true );

    $get({
      url: this.dataUrl,
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

    if ( !this.hasData )
      return;

    // Make a copy of the original columns array
    oColumns = [...oColumns];

    // Insert CP columns into the columns array
    oColumns.splice(
      this.afterColumn + 1,
      0,
      ...this._columns
    );

    return oColumns;

  }

  /**
   * Merge Table data with Custom Property data
   * Alters the given tableData collection
   * @param {Array} tableData Raw Table data collection to merge CP Data into
   */
  mergeData(tableData) {

    if ( !this.hasData )
      return;

    tableData.forEach( dataItem => {

      // Find Custom Property data for current Code List Item
      const itemCustomProps = this.customProps.data.find( d => 
        d.item_id === dataItem.id 
      );

      // Assign Custom Property data to Code List Item if found 
      itemCustomProps && Object.assign( dataItem, { 
        custom_properties: itemCustomProps 
      });

    });

  }


  /*** Renderers ***/


  /**
   * Render Custom Properties in this instance's table panel (destroys and reinits table)
   * Destroys and reinits TablePanel
   */
  _render() {

    this._destroyExecuteInit( tableData => {

      // Render Custom Property header columns
      this._renderHeaders();

      // Merge table data with cp data
      this.mergeData( tableData );

    });

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
    if ( this.hasData )
      this._toggleColumns( !this.visible );

    // Load CP data if none present
    else
      this.loadData();

  }


  /*** Support ***/


  /**
   * Destroys the current DataTable instance, performs specified action and re-initializes DataTable with cached data
   * @param {function} action Function to execute while TablePanel instance destroyed, passed cached tableData as argument
   */
  _destroyExecuteInit(action = () => {}) {

    // Cache table data
    const tableData = this.tablePanel.rowDataToArray;

    // Destroy DataTable instance
    this.tablePanel.destroy();

    // Run action
    action( tableData );

    // Re-initialize table and render data
    this.tablePanel.deferLoading = true;
    this.tablePanel.initialize();
    this.tablePanel._render( tableData );

  }

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

  /**
   * Get Custom Property column definitions (mapped from CP definitions)
   * @return {Array} Custom Property DT column definitions
   */
  get _columns() {

    return this.customProps.definitions.map( def =>
      columnByDataType( def.datatype )( def.name )
    );

  }

  /**
   * Get Custom Property options from the hidden input element from DOM
   * Should only be called once as DOM can change
   * @return {object} Custom property options containing 'dataUrl' and 'accessPolicy' values
   */
  _getOptions(id) {

    const $opts = $( `input#custom-props-opts-${id}` );

    return {
      dataUrl: $opts.attr( 'data-url' ),
      accessPolicy: $opts.attr( 'data-access-policy' ) == 'true'
    }

  }

}
