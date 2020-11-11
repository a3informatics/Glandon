import TablePanel from 'shared/base/table_panel'

import { customBtn } from 'shared/helpers/dt/utils'
import { columnByDataType } from 'shared/helpers/dt/dt_custom_property_columns'
import { $get } from 'shared/helpers/ajax'
import { alerts } from 'shared/ui/alerts'

/**
 * Custom Properties Table Panel
 * @description Extended Table Panel with custom-property columns which can be toggled
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CPTablePanel extends TablePanel {

  /**
   * Create a Custom Properties Table Panel
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table
   * @param {string} params.url Url of source data
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {int} params.count Count of items fetched in one request
   * @param {Array} params.extraColumns Additional column definitions
   * @param {boolean} params.deferLoading Set to true if data load should be deferred. Load data has to be called manually in this case
   * @param {boolean} params.cache Specify if the panel data should be cached. Optional.
   * @param {boolean} params.paginated Specify if the loadData call should be paginated. Optional, default = true
   * @param {Array} params.order DataTables deafult ordering specification, optional. Defaults to first column, descending
   * @param {Array} params.buttons DT buttons definitions objects, empty by default
   * @param {Object} params.tableOptions Custom DT options object, will be merged with this instance's _tableOpts, optional
   * @param {function} params.loadCallback Callback to data fully loaded, receives table instance as argument, optional
   * @param {boolean} params.cpEnabled Specifies whether the Custom Property toggle should be enabled
   * @param {element} params.errorDiv Custom element to display flash errors in, optional
   * @param {Object} args Optional additional arguments for extending classes
   */
  constructor({
    selector,
    url,
    param,
    count,
    extraColumns = [],
    deferLoading,
    cache = true,
    paginated = true,
    order = [[0, "desc"]],
    buttons = [],
    tableOptions = {},
    loadCallback = () => {},
    cpEnabled = true,
    afterColumn = 5,
    errorDiv
  }) {

    super({
      selector, url, param, count, extraColumns, cache,
      paginated, order, buttons, tableOptions, loadCallback,
      autoHeight: true, errorDiv
    }, {
      customProps: {
        enabled: cpEnabled,
        visible: false,
        afterColumn,
        btnText: {
          show: 'Show Custom Properties',
          hide: 'Hide Custom Properties',
          loading: 'Loading...'
        }
      }
    });

  }

  /**
   * Initialize the Table Panel, disable Custom Properties button
   */
  initialize() {

    super.initialize();
    this.$cpBtn.addClass( 'disabled' );

  }


  /*** Private ***/


  /**
   * Executed when table data fully loaded, enable Custom Properties button
   */
  _onDataLoaded() {

    super._onDataLoaded();
    this.$cpBtn.removeClass( 'disabled' );

  }


  /*** Custom Property Data ***/


  /**
   * Fetch Custom Property definitions and data from the server, merge and render
   */
  _loadCPs() {

    // Enable loading state on the CP button
    this.$cpBtn.addClass('el-loading')
               .text( this.customProps.btnText.loading );

    // TODO: Load
    $get({
      url: customPropsUrl,
      rawResult: true,
      done: r => {

        // No data returned
        if ( r.definitions.length === 0 ) {

          alerts.warning( 'No Custom Property data available.' );
          this._toggleCPColumns( false );
          return;

        }

        this.customProps.definitions = r.definitions.sort( (a, b) => a.label.localeCompare( b.label ) )
                                                    .sort( (a, b) => b.datatype.localeCompare( a.datatype ) );
        this._mergeCPData( this.rowDataToArray, r.data );
        this._renderCPs();

        // Toggle Custom Property column visibility
        this._toggleCPColumns( true );

      },
      // Remove loading state from button
      always: () => this.$cpBtn.removeClass('el-loading')
    });

  }

  /**
   * Merge table data collection with the Custom Property data
   * @param {Array} tableData Native table data collection
   * @param {Array} cpData Custom Property data to be merged into tableData
   */
  _mergeCPData(tableData, cpData) {

    tableData.forEach( dataItem => Object.assign(
      dataItem,
      cpData.find( d => d.id === dataItem.id )
    ));

  }

  /**
   * Merge Custom Property col defs with original col defs starting from an index specified by afterColumn
   * @param {Array} oColumns Original DT column definitions
   */
  _mergeCPColumnDefs(oColumns) {

    let columns = this.customProps.definitions.map( def => columnByDataType( def.datatype )( def.name ) ).reverse(),
        index = this.customProps.afterColumn + 1;

    oColumns.splice( index, 0, ...columns );

  }


  /*** Custom Property Render ***/


  /**
   * Destroy instance table, add CP data and re-initialize table
   */
  _renderCPs() {

    // Cache table data
    let tableData = this.rowDataToArray;

    // Destroy DataTable instance
    this.destroy();

    // Render Custom Property headers
    this.customProps.definitions.reverse().forEach( def =>
      this._renderCPHeader( def )
    );

    // Re-initialize table and render data
    this._initTable();
    this._render( tableData );

  }

  /**
   * Render a single Custom Property header in the instance DataTable
   * @param {object} definition Custom Property definition data object
   */
  _renderCPHeader(definition) {

    $( '<th>' ).text( definition.label )
               .addClass( 'custom-prop nowrap' )
               .insertAfter( `${ this.selector } thead th:eq(${ this.customProps.afterColumn })` );

  }

  /**
   * Toggle Custom Propety columns UI
   * @param {boolean} visible Target Custom Property columns visibility state
   */
  _toggleCPColumns(visible) {

    this.customProps.visible = visible;

    this.table.columns( '.custom-prop' )
              .visible( visible );

    this.$cpBtn.text( visible ?
      this.customProps.btnText.hide :
      this.customProps.btnText.show
    );

    this.table.columns.adjust();

  }


  /*** Custom Property Events ***/


  /**
   * Custom Property button onClick handler load data or toggle columns' state
   */
  _onCPBtnClick() {

    // Return if custom properties are disabled
    if ( !this.customProps.enabled )
      return;

    // Load CP data if none available
    if ( !this.customProps.definitions )
      this._loadCPs();

    // Otherwise toggle CP columns visibility
    else
      this._toggleCPColumns( !this.customProps.visible );

  }


  /*** Support ***/


  /**
   * Get Custom Property button elemenmt
   * @return {JQuery Element} Custom Property button
   */
  get $cpBtn() {
    return this.$wrapper.find( '.custom-props-btn' );
  }

  /**
   * Get Custom Property button definition object
   * @return {Object} DataTable custom button definition object
   */
  get _cpBtnDefinition() {

    return customBtn({
      text: 'Show Custom Properties',
      cssClasses: 'btn-xs white custom-props-btn',
      action: e => this._onCPBtnClick()
    });

  }

  /**
   * Custom DataTable initialization options
   * @return {Object} DataTable initialization options object
   */
  get _tableOpts() {

    let options = super._tableOpts;

    // Add Custom Properties button to table buttons
    if ( this.customProps.enabled )
      options.buttons = [
        ...options.buttons,
        this._cpBtnDefinition
      ];

    // Merge custom property column definitions with default columns if available
    if ( this.customProps.definitions )
      this._mergeCPColumnDefs( options.columns );

    // Enable horizontal scroll when table data wide
    options.scrollX = true;

    return options;

  }

}
