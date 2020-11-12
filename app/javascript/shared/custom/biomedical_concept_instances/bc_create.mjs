import CreateItemView from 'shared/base/create_item_view'

import ItemsPicker from 'shared/ui/items_picker/items_picker'
import { managedConceptRef } from 'shared/ui/strings'

/**
 * Create Biomedical Concept Modal View
 * @description Allows to create a new Biomedical Concept from parameters with custom callback
 * @requires _new_biomedical_concept.html.erb partial
 * @extends CreateItemView base Create Item View class
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CreateBCView extends CreateItemView {

  /**
   * Create a Modal View
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the modal element
   * @param {function} params.onCreated Callback executed when BC gets created, result passed as function argument
   * @param {function} params.onShow Callback executed when modal shown
   * @param {function} params.onHide Callback executed when modal hidden
   */
   constructor({
     selector = '#new-bc-modal',
     onCreated,
     onShow = () => { },
     onHide = () => { }
   } = {}) {
    super({ selector, onCreated, param: 'biomedical_concept_instance', createItemUrl: createBCUrl });

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
    this.form.find('input').removeAttr('data-id');
  }


  /** Private **/


  /**
   * Set event listeners and handlers
   */
  _setListeners() {
    super._setListeners();

    // On Template selector click event
    this.form.find('#new-item-template').on('click', () => this.templatePicker.show() );
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
   * Adds template into the Modal
   * @param {Object} template selected template data object
   */
  _onSelectTemplate(template) {
    this.form.find('#new-item-template').val( managedConceptRef(template) )
                                      .attr('data-id', template.id);
  }

  /**
   * Get the user-specified values for a new BC from the form
   * @return {Object} key-vaue pairs of parameters and values
   */
  get _formData() {
    let formData = super._formData;

    return Object.assign( formData, {
      template_id: this.form.find('#new-item-template').attr('data-id'),
    } );
  }

  /**
   * Initialize an ItemsPicker instance for BC Template selection
   * Call only once
   * @return {ItemsPicker} new instance of ItemsPicker
   */
  _initPicker() {
    return new ItemsPicker({
      id: 'new-bc',
      types: ['biomedical_concept_template'],
      onSubmit: (selection) => this._onSelectTemplate( selection.asObjectsArray()[0] )
    })
  }

  /**
   * Get validation rules for all fields in the Create BC form
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
