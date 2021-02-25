import { rdfTypesMap } from "shared/helpers/rdf_types"
import { alerts } from 'shared/ui/alerts'

/**
 * Items Picker Helper
 * @description Collection of helper functions for an Items Picker 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class IPHelper {

  /**
   * Validate a collection of Picker item types
   * @param {array} types Collection of types to validate (must come from the RdfTypesMap in order to be accepted)
   * @return {boolean} True if types validated, false if not  
   */
  static validateTypes(types) {

    if ( !types.length )
      return false 

    for ( const type of types ) {

      if ( !Object.values( rdfTypesMap ).includes( type ) )
        return false 

      if ( rdfTypesMap.UNKNOWN === type )
        return false 
      
    }

    return true 

  }

  /**
   * Call on a Picker error occurs 
   * @param {string} uiMsg Message to show to the user 
   * @param {string} debug Message to show in the console for debugging pruposes, optional 
   */
  static onError({
    uiMsg = 'An error occurred in the Items Picker module.',
    debug
  } = {}) {

    alerts.error( uiMsg )
    debug && console.error( debug )

  }

  /**
   * Convert type to Selector ID (serves as tab-wrapper id too)
   * @param {object} type RDF type definition object 
   * @return {string} Selector ID 
   * @static
   */
  static typeToSelectorId(type) { 
    return `selector-${ type.param }` 
  }

  /**
   * Convert type to Tab ID (serves as tab-option id)
   * @param {object} type RDF type definition object 
   * @return {string} Tab ID 
   * @static
   */
  static typeToTabId(type) {
    return `tab-${ type.param }`
  }

  /**
   * Convert a Tab or Selector ID to type object
   * @param {string} type Tab ID or Selector id string 
   * @return {object} RDF type definition object 
   * @static
   */
  static idToType(id) {
    return id.split('-')[1]
  }

}