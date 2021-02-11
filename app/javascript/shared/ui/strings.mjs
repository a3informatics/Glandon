/*** Renderers for shared Strings ***/


/**
 * Returns String representation of an Iso Concept
 * @param {Object} c Concept data object, fields: (label, identifier)
 * @return {string} Concept as a string reference
 */
function conceptRef(c) {
  return `${ c.label } (${ c.identifier })`
}

/**
 * Returns String representation of a Managed Item
 * @param {Object} mi Managed Item data object, fields: (notation || label, identifier, semantic_version)
 * @return {string} Managed Item as a string reference
 */
function managedItemRef(mi) {

  mi = _handleNestedProperties(mi)
  return `${ mi.notation || mi.label } ${ mi.identifier } v${ mi.semantic_version }`

}

/**
 * Returns String representation of an Unmanaged Item
 * @param {Object} ui Unmanaged Item data object, fields: (notation || label, identifier)
 * @param {Object} mi Managed Item data object, fields: (notation || label, identifier, semantic_version)
 * @return {string} Unmanaged Item as a string reference
 */
function unmanagedItemRef(ui, mi) {

  ui = _handleNestedProperties(ui)
  return `${ ui.notation || ui.label} ${ui.identifier } <span class="text-xtiny">(${ managedItemRef(mi) })</span>`

}


/** Private **/


/**
 * Helper, transforms data structure by bringing semantic_version and identifier fields to object's base level from the has_identifier property
 * @param {Object} data item data object
 * @return {Object} transformed object with properties in base level
 */
function _handleNestedProperties(data) {

  if ( data.has_identifier ) 

    return Object.assign( {}, data, {
      semantic_version: data.has_identifier.semantic_version,
      identifier: data.has_identifier.identifier
    })
  
  return data 

}

export {
  unmanagedItemRef,
  managedItemRef,
  conceptRef
}
