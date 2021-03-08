import { itemReferenceBtn } from 'shared/ui/buttons'
import { managedItemRef, unmanagedItemRef } from 'shared/ui/strings'


/*** Renderers for verious Collections ***/


/**
 * Returns formatted collection of Item references based on type
 * @param {Array} data Array of items containing the show_path, reference and context parameters
 * @param {string} type Format type - 'display' for HTML, anything else for raw strings
 * @param {boolean} newTab Set true to open link in a new tab, optional [default = false]
 * @return {string} formatted HTML / text
 */
function itemReferences(data = [], type, newTab = false) {

  if ( !data || data.length < 1 )
    return ''

  return type === 'display' ? 
    _itemReferenceBtns( data, newTab ) : 
    _itemReferenceStrings( data )

}


/** Private **/


/**
 * Returns HTMl for a collection of wrapped itemReference buttons
 * @param {Array} data Array of items containing the show_path, reference and context parameters
 * @param {boolean} newTab Set true to open link in a new tab, optional [default = false]
 * @return {string} Formatted Item reference buttons HTML
 */
function _itemReferenceBtns(data = [], newTab = false) {

  data = Array.isArray(data) ? data : [data]

  const refButtons = data.map( item => 
    itemReferenceBtn( item.show_path, item.reference, item.context, newTab ) 
  )

  return `<div class="bg-labels-wrap">
          ${ refButtons.join(' ') }
          </div>`

}

/**
 * Returns formatted text for a collection of terminology references separated by ;
 * @param {Array} data Array of items containing the show_path, reference and context parameters
 * @return {string} Formatted item references as a string
 */
function _itemReferenceStrings(data = []) {

  data = Array.isArray(data) ? data : [data]
 
  const refStrings = data.map( item =>
    item.context ? 
      unmanagedItemRef( item.reference, item.context ) :
      managedItemRef( item.reference )
  )

  return refStrings.join('; ')

}

export {
  itemReferences
}
