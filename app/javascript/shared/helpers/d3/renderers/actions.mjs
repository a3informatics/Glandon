import * as d3Lib from 'd3'

const D3Actions = { 

  /**
   * Create a new actions div in the page body
   */
  new(selector, buttons) {

    // Set container reference as object property
    this.container = $( selector );

    let actions = $( '<div>' ).addClass( 'node-actions' ),
        buttonWrapper = $( '<div>').addClass( 'btns-wrap' );

    // Append buttons' html to wrapper
    for ( let button of buttons ) {
      buttonWrapper.append( button );
    }

    // Append to DOM
    actions.append( buttonWrapper );
    $( `${selector} #d3` ).append( actions );

  },

  /**
   * Show (render) the actions and update its position
   * @param {string} html Tooltip HTML content to render
   */
  show(node) {

    if ( !node )
      return;
      
    let coords = this._coords(node);

    this.actions.css( 'left', `${ coords.x }px`  )
                .css( 'top', `${ coords.y }px` )
                .css( 'border-color', node.color )
                .show();

  },

  /**
   * Hide the actions element
   */
  hide() {

    this.actions.hide();

  },

  /**
   * Remove the actions from the DOM
   */
  destroy() {

    this.actions.remove();

  },

  /**
  * Get the actions element
  * @return {JQuery Element} Actions element
  */
  get actions() {

    return $('.node-actions');

  },

  /**
   * Get the actions coordinates relative to the D3 mouse event
   * @return {Object} Object containing the actions's new x and y coordinates
   */
  _coords(node) {

    let nc = node.coordinates, // Node coordinates
        co = this.container.offset() // Container offset

    return {
      x: nc.left + (nc.width / 2) - ( this.actions.width() / 2 ) - co.left,
      y: nc.top + nc.height + 2 - co.top
    }

  }

}

export {
  D3Actions
}
