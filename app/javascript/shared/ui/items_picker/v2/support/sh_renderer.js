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
  renderHandler() {

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

    
    this.content.html([ 'Selected: ', preview, viewBtn, clearBtn ])

    return this

  }

  /**
   * Render Selection Handler preview value  
   * @param {string} value Selection preview value (count | reference string)
   */
  renderPreview(value, options) {

    if ( value === undefined || value === null )
      return

    // Render value in preview 
    this.content.find( '#selection-preview' )
                .html( value )

    // Show / hide the selection view button depending on the multiple option 
    this.content.find( '#view-selection' )
                .toggle( options.multiple )

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