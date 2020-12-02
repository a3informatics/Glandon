import CustomPropsEditablePanel from 'shared/base/custom_properties/cp_editable_panel'

import { dtChildrenColumns } from 'shared/helpers/dt/dt_column_collections'

/**
 * Simple Subset Panel
 * @description DataTable-based Subset Panel based on a Custom Properties Editable Panel
 * @extends CustomPropsEditablePanel module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SubsetPanel extends CustomPropsEditablePanel {

  /**
   * Create a SubsetPanel instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the subset table
   * @param {object} params.urls Must contain urls for 'data' and 'update'
   * @param {function} params.loadCallback Callback executed on data loaded
   * @param {function} params.onReorder Callback executed on row reorder
   */
  constructor({
    selector,
    urls,
    loadCallback = () => {},
    onReorder = () => {}
  }) {

    super({
      tablePanelOpts: {
        param: 'subset',
        dataUrl: urls.data,
        updateUrl: urls.update,
        selector, loadCallback,
      },
      afterColumn: 6
    });

    Object.assign(this, {
      onReorder
    });

  }


  /*** Private ***/


  /**
   * Sets event listeners, handlers
   * Used for table related listeners only
   */
  _setTableListeners() {

    super._setTableListeners();

    // On Subset row reordered event handler
    this.table.on( 'row-reordered', (e, d, c) =>
      this.onReorder( d, c.triggerRow )
    );

  }

  /**
   * Formats the update data to be compatible with server
   * @param {object} d DataTables Editor data object
   */
  _preformatUpdateData(d) {

    let fData = super._preformatUpdateData( d );

    // If data present, the edited field is *not* a custom property 
    if ( d.data ) 
      d.edit = { 
        ...fData[0],
        with_custom_props: this.handler.visible 
      }

    // Provide the parent (code list) id to the server 
    Object.assign( d.edit, { 
      parent_id: this.id 
    });

    delete d.data;
    return fData;

  }

  /**
   * Formats the updated data returned from the server before being added to Editor
   * @override for custom behavior
   * @param {object} _oldData Data object sent to the server
   * @param {object} newData Data returned from the server
   */
  _postformatUpdatedData(_oldData, newData) {

    // Merge and update edited row data
    const editedRow = this.table.row( this.editor.modifier().row ),
          { ordinal } = editedRow.data(),
          mergedData = Object.assign( {}, editedRow.data(), newData[0], { ordinal } );

    editedRow.data( mergedData );

  }


  /*** Support ***/


  /**
   * Get Subset Panel default column definitions
   * @return {Array} Subset Panel column definitions collection
   */
  get _defaultColumns() {

    return [
      {
        data: 'ordinal',
        orderable: false
      },
      ...dtChildrenColumns({ orderable: false })
    ];

  }

  /**
   * Extend default DataTable init options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {

    const options = super._tableOpts;

    options.rowReorder = {
      dataSrc: 'ordinal',
      selector: 'td:first-child',
      snapX: true
    }

    options.order = [[ 0,'asc' ]];

    return options;

  }

}
