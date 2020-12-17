export default class D3Tooltip { 

  /**
   * Init instance with d3 module
   * @param {D3} d3 Reference to the d3 library
   */
  constructor(d3) {
    this.d3 = d3;
  }

  /**
   * Create a new tooltip div in the page body
   */
  new() {

    let tooltip = $( '<div>' ).addClass( 'graph-tooltip shadow-small' );
    $( 'body' ).append( tooltip );

  }

  /**
   * Show (render) the tooltip and update its position
   * @param {string} html Tooltip HTML content to render
   */
  show(html) {

    let coords = this._coords;

    this.tooltip.html( html )
                .css( 'left', `${ coords.x }px`  )
                .css( 'top', `${ coords.y }px` )
                .show();

  }

  /**
   * Hide the tooltip element
   */
  hide() {

    this.tooltip.hide();

  }

  /**
   * Remove the tooltip from the DOM
   */
  destroy() {

    this.tooltip.remove();

  }

  /**
  * Get the tooltip element
  * @return {JQuery Element} Tooltip HTML element
  */
  get tooltip() {

    return $('.graph-tooltip');

  }

  /**
   * Get the tooltip coordinates relative to the D3 mouse event
   * @return {Object} Object containing the tooltip's new x and y coordinates
   */
  get _coords() {

    let event = this.d3.event,
        isOut = event.pageX + this.tooltip.width() >= window.innerWidth - 40;

    return {
      x: ( isOut ? event.pageX - this.tooltip.width() : event.pageX ),
      y: event.pageY - this.tooltip.height() - 30
    }

  }

}