import EditablePanel from 'shared/base/editable_panel'

import ItemsPicker from 'shared/ui/items_picker/v2/items_picker'
import { alerts } from 'shared/ui/alerts'

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
    dtFieldsInit( ['boolean', 'picker'] );

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

    let [data] = super._preformatUpdateData( d )

    // Map item references to an array of ids
    if ( Array.isArray( data.has_coded_value ) )
      data.has_coded_value = data.has_coded_value.map( i => Object.assign( {}, {
        id: i.reference.id,
        context_id: i.context.id
       }) 
      )

    // Format update data
    d[ this.param ] = {
      property_id: data.id,
      ...data
    }

    // Clear unused structures
    delete d.data;

  }

  /**
   * Formats the updated data returned from the server before being added to Editor
   * @override for custom behavior
   * @param {object} _oldData Data object sent to the server
   * @param {object} newData Data returned from the server
   */
  _postformatUpdatedData(_oldData, newData) {

    // Render new data
    this._render( newData, true, 'full-hold' )

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
   * Displays Terminology picker error as alert because inline error cannot be shown in that case (editor closes) 
   * @extends _onSubmitted parent implementation
   * @param {object} json JSON data returned from the server
   */
  _onSubmitted(json) {

    const name = json?.fieldErrors[0]?.name;

    if ( name === 'has_coded_value' )
      alerts.error( `Terminology: ${ json.fieldErrors[0].status }` );

    super._onSubmitted( json );

  }

  /**
   * Initializes Items Pickers to use in an Editable Panel
   * @override super's _initPickers
   */
  _initPickers() {

    super._initPickers();

    // Initializes Terminology Reference Picker
    this.editor.pickers[ 'refPicker' ] = new ItemsPicker({
      id: 'bc-term-ref',
      types: [ ItemsPicker.allTypes.TH_CLI ],
      multiple: true,
      submitEmpty: true,
      description: `Find Items to add to the selection or modify the existing selection by clicking on View. <br>
                    <i> You can also submit an empty selection </i>`,
      submitText: 'Submit selection',
      onShow: () => this.keysDisable(),
      onHide: () => {
        this.editor.close();
        this.keysEnable();
      }
    }).initialize() 

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
    // options.keys.blurable = false;

    return options;

  }

}
