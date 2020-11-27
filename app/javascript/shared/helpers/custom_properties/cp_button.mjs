import { customBtn } from 'shared/helpers/dt/utils'

/**
 * Custom Properties Button module
 * @description Custom-property button related functionality and renderers
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CPButton {

  /**
   * Create a Custom Properties Button instance
   * @param {string} selector Unique selector of table to which the button belongs to
   * @param {function} onClick Callback to CP button click event
   */
  constructor({
    selector,
    onClick = () => {}
  }) {

    Object.assign( this, {
      selector: `${ selector }_wrapper`,
      onClick
    });

  }

  /**
   * Enable CP button
   */
  enable() {
    this.$.removeClass( 'disabled' );
  }

  /**
   * Disable CP button
   */
  disable() {
    this.$.addClass( 'disabled' );
  }

  /**
   * Toggle CP button loading state
   * @param {boolean} enable Set to true to enable loading, false otherwise
   */
  loading(enable) {

    this.$.toggleClass( 'el-loading', enable );

    if ( enable )
      this.text = this.strings.loading;

  }

  /**
   * Change CP button text
   * @param {string} text New text value
   */
  set text(text) {
    this.$.text( text );
  }

  /**
   * Get the button element
   * @return {JQuery Element} CP Button element
   */
  get $() {
    return $( this.selector ).find( '.custom-props-btn' );
  }

  /**
   * Get Custom Property button definition
   * @return {Object} DataTable custom button definition object
   */
  get definition() {

    return customBtn({
      text: this.strings.show,
      cssClasses: 'btn-xs white custom-props-btn',
      action: e => this.onClick()
    });

  }

  /**
   * Get Custom Property button strings
   * @return {Object} Custom Property button show, hide and loading strings
   */
  get strings() {

    return {
      show: 'Show Custom Properties',
      hide: 'Hide Custom Properties',
      loading: 'Loading...'
    }

  }

}
