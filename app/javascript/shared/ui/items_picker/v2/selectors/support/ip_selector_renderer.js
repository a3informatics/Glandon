import { conceptRef, managedItemRef } from 'shared/ui/strings'
import IPHelper from '../../support/ip_helper'

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
   * @param {string} historyCardTitle Title of the history card 
   */
  renderManagedSelector({
    historyCardTitle = 'Select'
  } = {}) {

    const browseCard = this._card({ 
            name: 'Browse', 
            id: 'index' 
          }),

          historyCard = this._card({ 
            name: historyCardTitle, 
            id: 'history' 
          })

    this.content.html([ browseCard, historyCard ])

  }

  /**
   * Render the content of an Unmanaged Selector tab
   */
  renderUnmanagedSelector() {

    // Render Managed Selector first 
    this.renderManagedSelector({
      historyCardTitle: 'Pick Version'
    })

    const childrenCard = this._card({ 
            name: 'Select', 
            id: 'children',
            hidden: true  
          })

    this.content.append( childrenCard )

  }

  /**
   * Render item reference as a subtitle in a given selector card
   * @param {string} id Card id to render subtitle in 
   * @param {object | undefined | null} item Item reference data, if a falsey value, will empty the subtitle 
   */
  renderSubtitle(id, item) {

    const subtitle = this.content.find( '#' + IPHelper.cardId( id ) )
                                 .find( '.ip-card-subtitle' )
    
    if ( item )
      subtitle.text( 
        item.has_identifier ? managedItemRef( item ) : conceptRef( item ) 
      )
    else 
      subtitle.empty()

  }


  /*** Private ***/


  /**
   * Render a single card-block with a title, subtitle, content, and a table
   * @param {string} name Card title 
   * @param {string} id Card id - match containing table id
   * @param {boolean} hidden Card hidden property, optional
   * @return {JQuery Element} Rendered card 
   */
  _card({ name, id, hidden = false }) {

    const card = $( '<div>' ).addClass( 'col-md-6 card wide' )
                             .prop( 'id', IPHelper.cardId(id) )
                             .prop( 'hidden', hidden ),

          subtitle = $( '<span>' ).addClass( 'ip-card-subtitle text-medium text-xtiny' )
                                  .css( 'margin', '0 10px' ),

          title = $( '<div>' ).addClass( 'ci-card-title text-xnormal text-link' )
                              .append([ name, subtitle ]),

          content = $( '<div>' ).addClass( 'card-content' )
                                .append([ title, this._table(id) ])
                        
    return card.append( content )                       

  }

  /**
   * Render an empty table
   * @param {string} id Table id  
   * @return {JQuery Element} Rendered table 
   */
  _table(id) {

    return $( '<table>' ).addClass( 'table table-row-clickable table-invisible no-mark no-select-icon' )
                         .prop( 'id', id )

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