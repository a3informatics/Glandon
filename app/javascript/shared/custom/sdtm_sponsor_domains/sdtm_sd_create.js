import CreateItemView from 'shared/base/create_item_view'

import ItemsPicker from 'shared/ui/items_picker/v2/items_picker'
import { managedItemRef } from 'shared/ui/strings'

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

    // On Base selector click event
    this.form.find('#new-item-base').on('click', () => 
      this.itemPicker.show() 
    )

    // On Prefix input, cast to uppercase 
    this.form.find('#new-item-prefix').on('input', e => 
      e.target.value = e.target.value.toUpperCase() 
    )

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
   * Adds Base selection into the Modal
   * @param {Object} template selected template data object
   */
  _onSelectBase(item) {

    this.form.find('#new-item-base').val( managedItemRef(item) )
                                    .attr('data-id', item.id);

  }

  /**
   * Get the user-specified values for a new SDTM from the form
   * @return {Object} key-vaue pairs of parameters and values
   */
  get _formData() {

    let formData = super._formData;

    return Object.assign( formData, {
      prefix: this.form.find('#new-item-prefix').val(),
      based_on_id: this.form.find('#new-item-base').attr('data-id')
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
      types: [ ItemsPicker.allTypes.SDTM_DOMAIN, ItemsPicker.allTypes.SDTM_CLASS ],
      description: 'Select an IG Domain / Class to base the new SDTM Sponsor Domain on',
      onSubmit: selection => this._onSelectBase( selection.asObjects()[0] )
    })

  }

  /**
   * Get validation rules for all fields in the Create SDTM SD form
   * @return {Object} validation rules compatible with Validator
   */
  get _validationRules() {

    let validationRules = super._validationRules;

    return Object.assign( validationRules, {
      base: {
        value: 'not-empty',
        'data-id': 'not-empty'
      },
      prefix: {
        value: 'not-empty',
        'max-length': 2
      }
    } );

  }

}
