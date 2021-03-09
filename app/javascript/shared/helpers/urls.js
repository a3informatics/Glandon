/**
 * Builds a history data URL of a Managed Item
 * @param {string} url Base url with placeholders
 * @param {Object} itemData Item data object containing identifier and scope_id
 * @return {string} Encoded url history url pointing to the item
 */
function makeHistoryUrl(url, itemData) {
  return url.replace('miHistoryId', itemData.identifier).replace('miScopeId', itemData.scope_id);
}

/**
 * Builds a children data URL of a Managed Concept
 * @param {string} url Base url with placeholders
 * @param {Object} itemData Item data object containing the managed concept's id
 * @return {string} Encoded url children url pointing to the managed concept
 */
function makeMCChildrenUrl(url, itemData) {
  return url.replace('miClId', itemData.id);
}

/**
 * Encode an object into query string and attach to given base url
 * @param {string} url Base url 
 * @param {Object} data Data object to be encoded into url
 * @return {string} Encoded url
 */
function encodeDataToUrl(url, data) {
  return url + '?' + $.param( data )
} 

export {
  makeHistoryUrl,
  makeMCChildrenUrl,
  encodeDataToUrl
}
