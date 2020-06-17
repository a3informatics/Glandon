/**
 * Returns HTML for a button linking to item's history
 * @param {string} url path to the item's history
 * @return {string} formatted button HTML
 */
function renderHistoryBtn(url) {
  return `<a href='${url}' class='btn light btn-xs'><span class='icon-old text-white'></span> History </a>`;
}

export {
  renderHistoryBtn
}
