import EditablePanel from 'shared/base/editable_panel'

import ItemsPicker from 'shared/ui/items_picker/items_picker'
import { $post } from 'shared/helpers/ajax'

import { dtFieldsInit } from 'shared/helpers/dt/dt_fields'
import { dtBCEditColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtBCEditFields } from 'shared/helpers/dt/dt_field_collections'
import { getDeepestValue } from 'shared/helpers/utils'

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
   * @param {function} params.extendTimer Callback for Timer extend called on any Edit action
   */
  constructor({
    urls,
    selector = "table#editor",
    loadCallback = () => {},
    extendTimer = () => {}
  }) {
    // Initialize custom DataTable Editor fields
    dtFieldsInit(['truefalse', 'picker']);

    super({ selector, dataUrl: urls.data, updateUrl: urls.update, param: 'biomedical_concept_instance',
            columns: dtBCEditColumns(), fields: dtBCEditFields(), deferLoading: true, loadCallback });

    Object.assign(this, { extendTimer });
  }


  /** Private **/


  /**
   * Sets event listeners, handlers
   */
  _setListeners() {
    // Call super's _setListeners
    super._setListeners();

    // Format the updated data before sending to the server
    this.editor.on('preSubmit', (e, d, type) => {
      if (type === 'edit')
        this._formatUpdateData(d);
    });

    // Reload data button click event
    $('#refresh-bc-editor').on('click', () => this.refresh())
  }

  /**
   * Format the update data to be compatible with server
   * @param {object} d DataTables Editor data object
   */
  _formatUpdateData(d) {
    const propertyId = Object.keys(d.data)[0];
    const edited = getDeepestValue(d.data);

    // Map item references to an array of ids
    if ( Array.isArray(edited.value) && edited.value.length )
      edited.value = edited.value.map((d) => d.reference.id)

    d[this.param] = {
      property_id: propertyId
    }
    d[this.param][edited.property] = edited.value;

    delete d.data;
  }

  /**
   * Extends the Token Timer on any edit action
   * @override super's _onEdited
   */
  _onEdited(e, json) {
    this.extendTimer();
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
        multiple: true,
        emptyEnabled: true
      });
  }

}
