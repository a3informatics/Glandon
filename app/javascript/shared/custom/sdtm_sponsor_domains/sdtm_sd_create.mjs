import CreateItemView from 'shared/base/create_item_view'

import ItemsPicker from 'shared/ui/items_picker/items_picker'
import { managedConceptRef } from 'shared/ui/strings'

/**
 * Create SDM Sponsor Domain Modal View
 * @description Allows to create a new SDTM Sponsor Domain from parameters with custom callback
 * @requires shared/sdtm_sponsor_domains/create_modal.html.erb partial
 * @extends CreateItemView base Create Item View class
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CreateSDTMSDView extends CreateItemView {

  /**
   * Create a Modal View
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the modal element
   * @param {function} params.onCreated Callback executed when SDTM gets created, result passed as function argument
   * @param {function} params.onShow Callback executed when modal shown
   * @param {function} params.onHide Callback executed when modal hidden
   */
   constructor({
     selector = '#new-sdtm-sd-modal',
     onCreated,
     onShow = () => { },
     onHide = () => { }
   } = {}) {

    super({ 
      selector, onCreated, 
      param: 'sdtm_sponsor_domain', 
      createItemUrl: createSDTMSDUrl 
    });

    Object.assign(this, {
      itemPicker: this._initPicker(),
      onShow,
      onHide
    });

  }

  /**
   * Clears the Modal
   */
  clear() {

    super.clear();

    // Clear extra form fields
    this.form.find('input')
             .removeAttr('data-id');

  }


  /** Private **/


  /**
   * Set event listeners and handlers
   */
  _setListeners() {

    super._setListeners();

    // On 'Base on' selector click event
    this.form.find('#new-item-base-on').on('click', () => 
      this.itemPicker.show() 
    );

  }

  /**
   * Calls the onShow callback when modal shows
   * @override _onShow in ModalView for custom behavior
   */
  _onShow() {
    this.onShow();
  }

  /**
   * Calls the onHide callback when modal hides
   * @override _onHide in ModalView for custom behavior
   */
  _onHide() {
    this.onHide();
  }

  /**
   * Adds Base on selection into the Modal
   * @param {Object} template selected template data object
   */
  _onSelectBaseOn(item) {

    this.form.find('#new-item-base-on').val( managedConceptRef(item) )
                                       .attr('data-id', item.id);

  }

  /**
   * Get the user-specified values for a new SDTM from the form
   * @return {Object} key-vaue pairs of parameters and values
   */
  get _formData() {

    let formData = super._formData;

    return Object.assign( formData, {
      base_on_id: this.form.find('#new-item-base-on').attr('data-id'),
    } );

  }

  /**
   * Initialize an ItemsPicker instance for SDTM Base selection
   * Call only once
   * @return {ItemsPicker} new instance of ItemsPicker
   */
  _initPicker() {

    return new ItemsPicker({
      id: 'new-sdtm-sd',
      types: ['sdtm_ig_domain', 'sdtm_class'],
      onSubmit: selection => this._onSelectBaseOn( selection.asObjectsArray()[0] )
    })

  }

  /**
   * Get validation rules for all fields in the Create SDTM SD form
   * @return {Object} validation rules compatible with Validator
   */
  get _validationRules() {

    let validationRules = super._validationRules;

    return Object.assign( validationRules, {
      'base-on': {
        'value': 'not-empty',
        'data-id': 'not-empty'
      }
    } );

  }

}
