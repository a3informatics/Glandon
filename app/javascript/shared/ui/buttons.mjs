import { managedConceptRef, unmanagedConceptRef } from 'shared/ui/strings'

/*** Renderers for Buttons ***/

/**
 * Returns HTML for a button linking to item's history
 * @param {string} url path to the item's history
 * @return {string} formatted button HTML
 */
function historyBtn(url) {
  return `<a href='${url}' class='btn white btn-xs'><span class='icon-old'></span> History </a>`;
}

/**
 * Returns HTML for a button linking to item's show
 * @param {string} url path to the item's show
 * @return {string} formatted button HTML
 */
function showBtn(url) {
  return `<a href='${url}' class='btn blue btn-xs'><span></span> Show </a>`;
}

/**
 * Returns HTML for a button linking to an managed/unamanaged item
 * @param {string} url path to the item's history
 * @param {Object} item Unmanaged / Managed Concept data object
 * @param {Object} parent Optional Managed Concept data object
 * @param {boolean} newTab Set true to open link in a new tab, optional [default = false]
 * @return {string} Reference link HTML
 */
function termReferenceBtn(url, item, parent, newTab = false) {
  const text = parent ? unmanagedConceptRef(item, parent) : managedConceptRef(item);
  return `<a href='${url}' ${newTab ? 'target="_blank"' : ''} class='bg-label highlightable'>${text}</a> `;
}

export {
  historyBtn,
  termReferenceBtn,
  showBtn
}
