import ModalView from 'shared/base/modal_view'

import Validator from 'shared/ui/validator'
import { $post } from 'shared/helpers/ajax'

/**
 * Create Item Extensible Base View
 * @description Allows to create a new Item from parameters with custom callback
 * @extends ModalView base Modal View class
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CreateItemView extends ModalView {

  /**
   * Create a Modal View
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the modal element
   * @param {string} params.param Item's strong param name
   * @param {function} params.onCreated Callback executed when item gets created, result passed as function argument
   */
   constructor({
     selector,
     createItemUrl,
     param,
     onCreated
   } = {}) {
    super({ selector });

    Object.assign(this, {
      createItemUrl,
      param,
      onCreated: onCreated || this._defaultOnCreated,
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
    this.form.find('input').val('');
  }


  /**
   * Get form element from the Modal View
   * @return {JQuery Element} wrapping form element
   */
  get form() {
    return this.modal.find('form');
  }


  /** Private **/


  /**
   * Validate inputs and execute a server request to create a new Item
   */
  _createItem() {
    // Perform validation
    if ( Validator.validate(this.form, this._validationRules) ) {

      // Build data structure
      let data = {}
      data[this.param] = this._formData;

      // Disable submit button
      this._loading(true);

      // POST request to create new Item, handle result
      $post({
        url: this.createItemUrl,
        data: data,
        errorDiv: this.modal.find('.error-modal'),
        done: (result) => {
          this.onCreated(result);
          this.hide();
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
    this.modal.find('#new-item-submit').on('click', () => this._createItem());

    // On Clear button click event
    this.modal.find('#new-item-clear').on('click', () => this.clear());
  }


  /**
   * Resets Modal to its initial state when hidden
   * @override _onHideComplete in ModalView for custom behavior
   */
  _onHideComplete() {
    this.clear();
  }

  /**
   * Toggle loading state on the modal (disables buttons)
   * @param {boolean} enable value representing the desired loading state
   */
  _loading(enable) {
    this.modal.find('.btn').toggleClass('disabled', enable)
    this.modal.find('#new-item-submit').toggleClass('el-loading', enable)
  }

  /**
   * Get the user-specified values for a new Item from the form
   * Default fields are identifier and label, extend method to add more
   * @return {Object} key-vaue pairs of parameters and values
   */
  get _formData() {
    return {
      identifier: this.form.find('#new-item-identifier').val(),
      label: this.form.find('#new-item-label').val()
    }
  }

  /**
   * Default onCreated callback, redirects to the history path or refreshes
   */
  _defaultOnCreated(result) {
    if (result)
      location.href = result.history_path;
    else
      location.reload();
  }

  /**
   * Get validation rules for all fields in the Create Item form
   * Default fields are identifier and label, extend method to add more
   * @return {Object} validation rules compatible with Validator
   */
  get _validationRules() {
    return {
      identifier: { 'value': 'not-empty' },
      label: { 'value': 'not-empty' }
    }
  }

}
