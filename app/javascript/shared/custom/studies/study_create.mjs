import CreateItemView from 'shared/base/create_item_view'

import ItemsPicker from 'shared/ui/items_picker/items_picker'
import { managedItemRef } from 'shared/ui/strings'

/**
 * Create a Study Modal View
 * @description Allows to create a new Study from parameters with custom callback
 * @extends CreateItemView base Create Item View class
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CreateStudyView extends CreateItemView {

  /**
   * Create a Modal View
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the modal element
   * @param {function} params.onCreated Callback executed when Study gets created, result passed as function argument
   * @param {function} params.onShow Callback executed when modal shown
   * @param {function} params.onHide Callback executed when modal hidden
   */
   constructor({
     selector = '#new-study-modal',
     onCreated,
     onShow = () => { },
     onHide = () => { }
   } = {}) {

    super({
      selector, onCreated, param: 'study',
      createItemUrl: createStudyUrl
    });

    Object.assign(this, {
      templatePicker: this._initPicker(),
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
    this.form.find( 'input' )
             .removeAttr( 'data-id' );

  }


  /** Private **/


  /**
   * Set event listeners and handlers
   */
  _setListeners() {

    super._setListeners();

    // On Protocol selector click event
    this.form.find( '#new-item-template' ).on( 'click', () =>
      this.templatePicker.show()
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
   * Adds Protocol template into the Modal
   * @param {Object} protocol selected Protocol Template data object
   */
  _onSelectTemplate(protocol) {

    this.form.find( '#new-item-template' )
             .val( managedItemRef( protocol ) )
             .attr( 'data-id', protocol.id );

  }

  /**
   * Get the user-specified values for a new Study from the form
   * @return {Object} key-vaue pairs of parameters and values
   */
  get _formData() {

    let formData = super._formData;

    return Object.assign( formData, {
      protocol_id: this.form.find( '#new-item-template' ).attr( 'data-id' ),
    });

  }

  /**
   * Initialize an ItemsPicker instance for Study Template selection
   * Call only once
   * @return {ItemsPicker} new instance of ItemsPicker
   */
  _initPicker() {

    return new ItemsPicker({
      id: 'new-study',
      types: ['protocol'],
      onSubmit: selection => this._onSelectTemplate( selection.asObjectsArray()[0] )
    });

  }

  /**
   * Get validation rules for all fields in the Create Study form
   * @return {Object} validation rules compatible with Validator
   */
  get _validationRules() {

    let validationRules = super._validationRules;

    return Object.assign( validationRules, {
      template: {
        'value': 'not-empty',
        'data-id': 'not-empty'
      }
    } );

  }

}
