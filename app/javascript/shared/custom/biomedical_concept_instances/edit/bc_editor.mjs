import EditablePanel from 'shared/base/editable_panel'

import ItemsPicker from 'shared/ui/items_picker/items_picker'
import { $post } from 'shared/helpers/ajax'

import { dtFieldsInit } from 'shared/helpers/dt/dt_fields'
import { dtBCEditColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtBCEditFields } from 'shared/helpers/dt/dt_field_collections'

/**
 * Biomedical Concept Editor
 * @description DataTable-based Editor of a Biomedical Concept (CRUD actions)
 * @extends EditablePanel base class
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class BCEditor extends EditablePanel {

  /**
   * Create a BC Editor instance
   * @param {Object} params Instance parameters
   * @param {object} params.urls Must contain urls for 'data', 'update',
   * @param {string} params.selector JQuery selector of the target table
   * @param {function} params.loadCallback Callback to data fully loaded, receives table instance as argument, optional
   * @param {function} params.loadingCallback Callback when Editor's _loading function is called, receives identical argument, optional
   * @param {function} params.onEdited Callback executed on any edit action
   */
  constructor({
    urls,
    selector = "table#editor",
    loadCallback = () => {},
    loadingCallback = () => {},
    onEdited = () => {}
  }) {

    // Initialize custom DataTable Editor fields
    dtFieldsInit( ['truefalse', 'picker'] );

    // Initialize super with custom options
    super({ selector, dataUrl: urls.data, updateUrl: urls.update, param: 'biomedical_concept_instance',
            columns: dtBCEditColumns(), fields: dtBCEditFields(), idSrc: 'has_complex_datatype.has_property.id',
            deferLoading: true, loadCallback, order: [[2, "desc"]] });

    Object.assign( this, { onEdited, loadingCallback } );

  }

  /**
   * Set new bcInstance to the Editor
   * @param {Object} bcInstance new bcInstance object
   */
  setBCInstance(bcInstance) {

    this.bcInstance = bcInstance;

    // Update Editor instance's data and update urls
    this.setDataUrl( this.bcInstance.dataUrl );
    this.setUpdateUrl( this.bcInstance.updateUrl );

  }

  /**
   * Enable the Editor Key & Click interaction
   */
  kEnable() {
    this.table.keys.enable();
  }

  /**
   * Disable the Editor Key & Click interaction
   */
  kDisable() {
    this.table.keys.disable();
  }


  /** Private **/


  /**
   * Set event listeners, handlers
   */
  _setListeners() {

    // Call super's _setListeners
    super._setListeners();

    // Reload data button click event
    $('#refresh-bc-editor').on('click', () => this.refresh() );

  }

  /**
   * Format the update data structure for server compatibility
   * @param {object} d DataTables Editor data object
   */
  _preformatUpdateData(d) {

    let id = Object.keys(d.data)[0],
        data = Object.values(d.data)[0],
        fieldName = this.editor.displayed()[0];

    // Map item references to an array of ids
    if ( fieldName === 'has_coded_value' && Array.isArray( data.has_coded_value ) )
      data.has_coded_value = data.has_coded_value.map( (i) =>
        Object.assign( {}, { id: i.reference.id, context_id: i.context.id } )
      )

    // Format update data
    d[this.param] = {}
    Object.assign(d[this.param], { property_id: id }, data )

    // Clear unused structures
    delete d.data;

  }

  /**
   * Formats the updated data returned from the server before being added to Editor
   * @override for custom behavior
   * @param {object} oldData Data object sent to the server
   * @param {object} newData Data returned from the server
   */
  _postformatUpdatedData(oldData, newData) {

    // Copy the current focus index object
    let focusCell = { ...this.table.cell( { focused: true } ).index() };

    // Render new data and re-focus to the copied cell index
    this._render( newData, true );
    this.table.cell( focusCell ).focus();

  }

  /**
   * Calls the onEdited callback function
   * @override super's _onEdited
   */
  _onEdited(e, json) {

    if ( this.onEdited )
      this.onEdited();

  }

  /**
   * Initializes Items Pickers to use in an Editable Panel
   * @override super's _initPickers
   */
  _initPickers() {

    super._initPickers();

    // Initializes Terminology Reference Picker
    this.editor.pickers["termPicker"] = new ItemsPicker({
      id: 'bc-term-ref',
      types: ['unmanaged_concept'],
      submitText: 'Submit selection',
      multiple: true,
      emptyEnabled: true,
      onShow: () => this.kDisable(),
      onHide: () => {
        this.editor.close();
        this.kEnable();
      }
    });

  }

  /**
   * Extends super's _loading, trigger instance's loadingCallback function
   * @param {boolean} enable value corresponding to the desired loading state on/off
   */
  _loading(enable) {
    super._loading(enable);
    this.loadingCallback(enable);
  }

  /**
   * Extend default Editable Panel options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {

    let options = super._tableOpts;

    options.rowId = (d) => {
      return d.has_complex_datatype.has_property.id
    }
    options.keys.blurable = false;

    return options;

  }

}
