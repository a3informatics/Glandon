/**
 * IP Selector Renderer
 * @description Collection of helper functions for rendering the UI elements of an Items Picker Selector
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class IPSRenderer {

  /**
   * Create new IPS Renderer instance 
   * @param {string} selector Unique Item Selector selector
   */
  constructor(selector) {
    this.selector = selector
  }
  
  /**
   * Render the content of a Managed Selector tab
   */
  renderManagedSelector() {

    const browseCard = this._card( 'Browse' ),
          selectCard = this._card( 'Select' ),

          indexTable = this._indexTable(),
          historyTable = this._historyTable()

    browseCard.find('.card-content')
              .append( indexTable )

    selectCard.find('.card-content')
              .append( historyTable )

    this.content.html( 
      browseCard.add( selectCard ) 
    )

  }


  /*** Private ***/


  /**
   * Render a single card-block with a title 
   * @param {string} name Card title 
   * @return {JQuery Element} Rendered card 
   */
  _card(name) {

    const card =    $( '<div>' ).addClass( 'col-md-6 card wide' ),
          content = $( '<div>' ).addClass( 'card-content' ),
          title =   $( '<div>' ).addClass( 'ci-card-title text-xnormal text-link' )
                                .text( name )

    card.append( content.append( title ) )

    return card                       

  }

  /**
   * Render an empty index table 
   * @return {JQuery Element} Rendered table 
   */
  _indexTable() {

    return $( '<table>' ).addClass( 'table table-row-clickable table-invisible no-mark no-select-icon' )
                         .attr( 'id', 'index' )

  }

  /**
   * Render an empty history table 
   * @return {JQuery Element} Rendered table 
   */
  _historyTable() {

    return $( '<table>' ).addClass( 'table table-row-clickable table-invisible no-mark no-select-icon' )
                         .attr( 'id', 'history' )

  }


  /*** Getters ***/


  /**
   * Get the content wrapper element 
   * @return {JQuery Element} Content element of the current Selector  
   */
  get content() {
    return $( this.selector ) 
  }


}