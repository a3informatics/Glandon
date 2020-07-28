import ModalView from 'shared/base/modal_view'

import ItemsPicker from 'shared/ui/items_picker/items_picker'
import Validator from 'shared/ui/validator'
import { managedConceptRef } from 'shared/ui/strings'
import { $post } from 'shared/helpers/ajax'

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
   * @param {function} params.onCreated Callback executed when BC gets created, result passed as function argument
   */
   constructor({
     selector = '#new-bc-modal',
     onCreated
   } = {}) {
    super({ selector });

    Object.assign(this, {
      templatePicker: this._initPicker(),
      onCreated: onCreated || this._defaultOnCreated
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


  /**
   * Validate inputs and execute a server request to create a new BC
   */
  _createBC() {
    // Perform validation
    if ( Validator.validate(this.form, this._validationRules) ) {
      // Disable submit button
      this._loading(true);

      // POST request to create new BC, handle result
      $post({
        url: createBCUrl,
        data: { biomedical_concept_instance: this._formData },
        errorDiv: this.modal.find('#new-bc-error'),
        done: (result) => {
          this.onCreated(result);
          this.dismiss();
        },
        always: () => this._loading(false)
      })
    }
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
   * Toggle loading state on the modal (disables buttons)
   * @param {boolean} enable value representing the desired loading state
   */
  _loading(enable) {
    this.modal.find('.btn').toggleClass('disabled', enable)
    this.modal.find('#new-bc-submit').toggleClass('el-loading', enable)
  }

  /**
   * Get the user-specified values for a new BC from the form
   * @return {Object} key-vaue pairs of parameters and values
   */
  get _formData() {
    return {
      identifier: this.form.find('#new-bc-identifier').val(),
      label: this.form.find('#new-bc-label').val(),
      template_id: this.form.find('#new-bc-template').attr('data-id'),
    }
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
   * Default onCreated callback, redirects to the history path
   */
  _defaultOnCreated(result) {
    if (result)
      location.href = result;
    else
      location.reload();
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
