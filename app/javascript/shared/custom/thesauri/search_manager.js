import { encodeDataToUrl } from 'shared/helpers/urls'
import ItemsPicker from 'shared/ui/items_picker/v2/items_picker'

/**
 * Search Manager 
 * @description Simple module for Thesaurus Search selection & redirect
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SearchManager {

  /**
   * Initialize a new Items Picker Instance and set properties
   * Picker show() is invoked when 'Search Terminologies' button is clicked (through its href target)
   */
  static initialize() {

    const searchPicker = new ItemsPicker({
      id: 'th-search',
      multiple: true,
      types: [ ItemsPicker.allTypes.TH ],
      description: 'Select one or more Terminology version in which to search, or choose to search in all Latest / Current versions',
      submitText: 'Search Selected',
      buttons: SearchManager.buttons,
      onSubmit: s => SearchManager.searchByIds( s.asIDs() )
    })

  }

  /**
   * Redirect to correct Search Terminology page by specified Thesaurus ids
   * @param {array} ids One or more Thesaurus ids to search in 
   */
  static searchByIds(ids) {

    if ( ids.length === 1 )
      location.href = searchUrls.single.replace( 'thID', ids[0] )
    else 
      location.href = encodeDataToUrl( searchUrls.multiple, { thesauri: { id_set: ids } })

  }

  /**
   * Get Custom Picker buttons that redirect to Search Latest and Search Current pages 
   * @return {array} Items Picker button definitions 
   */
  static get buttons() {
    
    return [{ 
      id: 'search-latest',
      text: 'Search in Latest',
      onClick: () => location.href = searchUrls.latest
    }, {
      id: 'search-current',
      text: 'Search in Current',
      onClick: () => location.href = searchUrls.current
    }]

  }

}