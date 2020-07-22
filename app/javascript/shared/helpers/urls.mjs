/**
 * Builds a thesauri search URL based on the user selection from ManagedItemsSelect (MIS)
 * @param {?} sel User selection returned by MIS
 * @return {string} Encoded url to search / search_multiple with enceded data
 */
function thSearchUrlFromMIS(sel) {
  let url, data;

  if(Array.isArray(sel) && sel.length === 1)
    url = searchUrl.replace('thId', sel[0])

  else {
    let data = { thesauri: {} };
    if(typeof sel === 'string')
      data.thesauri.filter = sel;
    else
      data.thesauri.id_set = sel;
    url = `${searchMultiUrl}?${$.param(data)}`;
  }

  return url;
}

/**
 * Builds a history data URL of a Managed Item
 * @param {string} url Base url with placeholders
 * @param {Object} itemData Item data object containing identifier and scope_id
 * @return {string} Encoded url history url pointing to the item
 */
function makeHistoryUrl(url, itemData) {
  return url.replace('miHistoryId', itemData.identifier).replace('miScopeId', itemData.scope_id);
}

export {
  thSearchUrlFromMIS,
  makeHistoryUrl
}
