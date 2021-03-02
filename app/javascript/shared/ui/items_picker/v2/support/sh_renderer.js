/**
 * Selection Handler Renderer
 * @description Collection of helper functions for rendering the UI elements of an Items Picker Selection Handler
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SHRenderer {

  /**
   * Create new SH Renderer instance 
   * @param {string} selector Unique Selection Handler selector
   */
  constructor(selector) {
    this.selector = selector
  }

  /**
   * Render Selection Handler contents in the Picker 
   * @param {string} selector Unique Selection Handler selector
   */
  renderSelectionHandler() {

    const preview = $( '<span>' ).addClass( 'bg-label bordered text-small' )
                                 .attr( 'id', 'selection-preview' ),

          viewBtn = this._button({
            id: 'view-selection',
            text: 'View',
            icon: 'view'
          }),

          clearBtn = this._button({
            id: 'clear-selection',
            text: 'Clear',
            icon: 'times'
          })

    
    this.content.html([ preview, viewBtn, clearBtn ])

    return this

  }


  /*** Private ***/


  /**
   * Render a small icon button
   * @param {string} id Button id
   * @param {string} text Button text
   * @param {string} icon Button icon name (without icon- prefix)
   * @return {JQuery Element} Custom button for appending to the DOM 
   */
  _button({
    id,
    text,
    icon
  }) {

    const _icon = $( '<span>' ).addClass( `icon-${ icon } text-tiny` )

    return $( '<button>' ).addClass( 'btn btn-xs white' )
                          .attr( 'id', id )
                          .append( [ _icon, ' ', text ] )

  }


  /*** Getters ***/


  /**
   * Get the content (main) element
   * @return {JQuery Element} Main content element
   */
  get content() {
    return $( this.selector ) 
  }

}