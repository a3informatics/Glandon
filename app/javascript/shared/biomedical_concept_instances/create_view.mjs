import ModalView from 'shared/base/modal_view'

import ItemsPicker from 'shared/ui/items_picker/items_picker'
import { managedConceptRef } from 'shared/ui/strings'
import Validator from 'shared/ui/validator'

/**
 * Create Biomedical Concept Modal View
 * @description Allows to create a new Biomedical Concept from parameters with custom callback
 * @requires _new_biomedical_concept.html.erb partial
 * @extends ModalView base Modal View class
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CreateBCView extends ModalView {

  /**
   * Create a Modal View
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the modal element
   * @param {function} params.onCreate Callback executed when BC gets created, result passed as function argument
   */
   constructor({
     selector = '#new-bc-modal',
     onCreate
   } = {}) {
    super({ selector });

    Object.assign(this, {
      templatePicker: this._initPicker(),
      onCreate: onCreate || this._defaultOnCreate
    });

    this._setListeners();
  }

  /**
   * Clears the Modal
   */
  clear() {
    // Clear form validation results
    Validator._clear(this.form);
    // Clear form values
    this.form.find('input').val('').removeAttr('data-id');
  }

  /**
   * Get form element from the Create BC Modal View
   * @return {JQuery Element} wrapping form element
   */
  get form() {
    return this.modal.find('#new-bc-form');
  }


  /** Private **/


  _defaultOnCreate(data) {
    if (data.history_path)
      location.href = data.history_path;
    else
      location.reload();
  }

  /**
   * Set event listeners and handlers
   */
  _setListeners() {
    // On Submit button click event
    this.modal.find('#new-bc-submit').on('click', () => this._createBC());

    // On Clear button click event
    this.modal.find('#new-bc-clear').on('click', () => this.clear());

    // On Template selector click event
    this.form.find('#new-bc-template').on('click', () => this.templatePicker.show() );
  }

  /**
   * Validate inputs and execute a server request to create a new BC
   */
  _createBC() {
    // Perform validation
    if( Validator.validate({ form: this.form, rules: this._validationRules }) )
      console.log("passed");
  }

  /**
   * Resets Modal to its initial state when hidden
   * @override _onHideComplete in ModalView for custom behavior
   */
  _onHideComplete() {
    this.clear();
  }

  /**
   * Adds template into the Modal
   * @param {Object} template selected template data object
   */
  _onSelectTemplate(template) {
    this.form.find('#new-bc-template').val( managedConceptRef(template) )
                                      .attr('data-id', template.id);
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
    return {
      identifier: { 'value': 'not-empty' },
      label: { 'value': 'not-empty' },
      template: {
        'value': 'not-empty',
        'data-id': 'not-empty'
      }
    }
  }

}
