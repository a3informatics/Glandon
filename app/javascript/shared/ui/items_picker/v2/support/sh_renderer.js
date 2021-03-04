import IPHelper from './ip_helper' 
import { rdfTypesMap as types } from 'shared/helpers/rdf_types'
import { unmanagedItemRef, managedItemRef } from 'shared/ui/strings'

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

  /**
   * Build the View Selection dialog contents
   * @param {Array} selection Selection of item data  
   * @param {Array} types Allowed Picker types   
   * @param {function} onItemClick Item click handler, element passed as argument
   * @return {JQuery Element} View Selection dialog content    
   */
  buildSelectionDialog({
    selection = [], 
    types = [], 
    onItemClick = () => {}
  }) {

    // Selection empty 
    if ( !selection.length )
      return 'Selection is empty'
    
    const content = $( '<div>' ).append( this._dialogHint )

    for ( const type of types ) {

      // Filter Selected items to the current Type only 
      const itemsByType = selection.filter( item => item.rdf_type === type.rdfType )

      if ( !itemsByType.length )
        continue 

      // Render Type title and items
      const title = this._typeTitle( type ),
            items = this._itemLabels( itemsByType, onItemClick )

      content.append([ title, '<br>', items ])
    
    }

    return content

  }

  /**
   * Get Item Reference string 
   * @param {Object} item Reference item data object 
   * @return {string} Standard Reference string based on item type    
   */
  static referenceString(item) {

    if ( item.rdf_type === types.TH_CLI.rdfType )
      return unmanagedItemRef( item, item._context )

    return managedItemRef( item )
  
  }


  /*** Private ***/
  

  /*** Selection Dialog ***/


  /**
   * Render Type as title in Selection Dialog
   * @param {Object} type Type definition object 
   * @return {JQuery Element} Rendered Type title element     
   */
  _typeTitle(type) {

    return $( '<div>' ).addClass( 'label-styled label-w-margin' )
                       .text( IPHelper.pluralize( type.name ) )
  
  }

  /**
   * Render Items data as clickable labels in Selection Dialog
   * @param {Array} items Item data objects
   * @param {function} onItemClick Item click handler
   * @return {JQuery Element} Rendered Items elements wrapped in a div     
   */
  _itemLabels(items, onItemClick) {

    return items.reduce( ( wrapper, item ) => 
      wrapper.append( this._itemLabel( item, onItemClick ) ),
      $( '<div>' )
    )
       
  } 

  /**
   * Render single Item data as clickable label in Selection Dialog
   * @param {object} item Item data object
   * @param {function} onClick Item click handler, element passed as argument
   * @return {JQuery Element} Rendered Item element     
   */
  _itemLabel(item, onClick) {

    return $( '<div>' ).addClass( 'bg-label removable label-w-margin' )
                       .attr( 'data-id', item.id )
                       .click( ({ currentTarget }) => onClick($( currentTarget )) )
                       .html( SHRenderer.referenceString( item ) )

  }

  /**
   * Get the Hint element in Selection Dialog
   * @return {JQuery Element} Text hint div     
   */
  get _dialogHint() {

    return $( '<div>' ).addClass( 'text-xtiny' )
                       .text( 'Click on an item to remove it from the selection.' )

  }


  /*** Other elements ***/


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