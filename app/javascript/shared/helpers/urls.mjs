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

export { thSearchUrlFromMIS }
