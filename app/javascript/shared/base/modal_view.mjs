/**
 * Base Modal View
 * @description Extensible Base for a Modal View
 * @requires modal functionality from bootstrap 3
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ModalView {

  /**
   * Create a Modal View
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the modal element
   * @param {Object} args Optional additional arguments for extending classes
   */
  constructor({ selector }, args = {} ) {
    Object.assign(this, {
      selector, 
      isOpen: false,
      ...args
    });

    this._setModalListeners();
  }

  /**
   * Get JQuery modal element from instance selector
   * @return {JQuery Element} defined by instance selector string
   */
  get modal() {
    return $(this.selector);
  }

  /**
   * Show the modal
   */
  show() {
    this.modal.modal('show');
  }

  /**
   * Hide the modal
   */
  hide() {
    this.modal.modal('hide');
  }


  /** Private **/

  /**
   * Sets event listeners, handlers
   * Override and extend to add custom listeners
   */
  _setModalListeners() {
    // Called immediately, before fade-in animation
    this.modal.on('show.bs.modal', () => {
      this.isOpen = true;
      this._onShow();
    });

    // Called after modal visible
    this.modal.on('shown.bs.modal', () => this._onShowComplete());

    // Called immediately, before fade-out animation
    this.modal.on('hide.bs.modal', () => {
      this._onHide();
      this.isOpen = false;
    });

    // Called after modal hidden fully
    this.modal.on('hidden.bs.modal', () => this._onHideComplete());
  }

  /**
   * Executed immediately, before animations
   * Override for custom behavior
   */
  _onShow() { }

  /**
   * Executed after modal visible
   * Override for custom behavior
   */
  _onShowComplete() { }

  /**
   * Executed immediately, before animations
   * Override for custom behavior
   */
  _onHide() { }

  /**
   * Executed after modal hidden
   * Override for custom behavior
   */
  _onHideComplete() { }
}
