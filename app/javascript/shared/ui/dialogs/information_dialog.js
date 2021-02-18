/**
 * Information Dialog
 * @description Allows to display a simple dismissable dialog
 * @see partial This dialog's HTML structure is matches shared/information_dialog.html.erb. When changing, you must change both
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class InformationDialog {

  /**
   * Create a Managed Item Selector
   * @param {Object} params Instance parameters
   * @param {string} params.title Title text of the dialog
   * @param {string} params.subtitle Subtitle (body) text of the dialog
   * @param {boolean} params.dangerous Style the dialog with red border [default = false]
   * @param {boolean} params.wide Increase dialog width [default = false]
   * @param {function} params.onShow Optional callback to when dialog gets shown
   * @param {(string | JQuery Element)} params.div DIV selector of dialog element if already appended in DOM, optional
   */
  constructor({
    title = 'Information',
    target = 'body',
    subtitle = '',
    dangerous = false,
    wide = false,
    onShow = () => {},
    div
  }) {
    Object.assign(this, { title, target, subtitle, dangerous, wide, onShow, div } );

    this.id = this._makeId();
  }

  /**
   * Append dialog to DOM, set event handlers and show animation
   */
  show() {
    if (this.div)
      this._adjustDisplay();
    else
      $(this.target).prepend( this._renderDialog() );

    this._setListeners();

    // Wait before starting animation
    setTimeout(() => $(this.id).addClass("cd-show"), 0);

    // On show callback, wait for animation finish
    setTimeout(() => this.onShow(), 300);

    return this;
  }

  /**
   * Remove listeners and hide / remove dialog
   */
  dismiss = () => {
    // Remove event handlers
    this._removeListeners();

    $(this.id).removeClass("cd-show");

    // Remove element from dom if rendered with JS
    if (!this.div)
      setTimeout(() => $(this.id).remove(), 200);
  }

  /**
   * Sets new text (subtitle) to the dialog
   * @param {string} newText new value to be rendered
   */
  setText(newText) {
    this.subtitle = newText;
    $(this.id).find(".cd-subtitle").html(newText);
  }


  /** Private **/

  /**
   * Sets event listeners and handlers (dismiss click and key press)
   */
  _setListeners() {
    // Dismiss button click
    $(`${this.id} #id-dismiss-button`).on('click', this.dismiss);

    // Dismiss with keyboard
    $(window).on("keyup", this._onKeyPress);
  }

  /**
   * Key press event handler, dismisses dialog on Escape key
   * @param {event} e original key event
   */
  _onKeyPress = (e) => {
    // Check for Escape key
    if(e.keyCode === 27 || e.which === 27)
      this.dismiss();
  }

  /**
   * Removes event listeners and handlers (dismiss click and key press)
   */
  _removeListeners() {
    $(`${this.id} #id-dismiss-button`).off('click', this.dismiss);
    $(window).off("keyup", this._onKeyPress);
  }

  /**
   * Renders styled dialog HTML with contents with instance parameters
   * @return {string} Rendered dialog HTML
   */
  _renderDialog() {
    return `<div id="${this.id.replace('#','')}" class="cd-wrap ${ (this.wide ? 'wide' : '') }">` +
              `<div class="cd-body shadow-medium ${ (this.dangerous ? 'danger' : '') }">` +
                `<div class="cd-title text-xnormal text-link">${this.title}</div>` +
                `<div class="cd-subtitle scroll-styled text-small font-light">${this.subtitle}</div>` +
                `<div class="cd-footer">` +
                  `<button id="id-dismiss-button" class="btn grey medium">Dismiss</button>` +
                `</div>` +
              `</div>` +
           `</div>`
  }

  /**
   * Adjust dialog position in DOM when a modal is opened
   */
  _adjustDisplay() {
    if ( $(".modal-open").find($(this.id)).length > 0 )
      $("body").append( $(`.modal-open ${this.id}`) );
  }

  /**
   * Generate an id for the dialog
   * @return {string} dialog element id referring to its div
   */
  _makeId() {
    if (this.div)
      return `#${$(this.div).attr('id')}`
    else
      return `#information-dialog-${ $(".cd-wrap").length+ 1 }`
  }

}
