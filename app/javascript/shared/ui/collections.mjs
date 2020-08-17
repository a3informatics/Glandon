import { termReferenceBtn } from 'shared/ui/buttons'
import { managedConceptRef, unmanagedConceptRef } from 'shared/ui/strings'

/*** Renderers for verious Collections ***/

/**
 * Returns formatted collection of terminology references based on type
 * @param {Array} data Array of items containing the show_path, reference and context parameters
 * @param {string} type Format type - 'display' for HTML, anything else for raw strings
 * @param {boolean} newTab Set true to open link in a new tab, optional [default = false]
 * @return {string} formatted HTML / text
 */
function termReferences(data = [], type, newTab = false) {
  return type === 'display' ? _termReferenceBtns(data, newTab) : _termReferenceStrings(data);
}

/** Private **/

/**
 * Returns HTMl for a collection of wrapped termReference buttons
 * @param {Array} data Array of items containing the show_path, reference and context parameters
 * @param {boolean} newTab Set true to open link in a new tab, optional [default = false]
 * @return {string} formatted HTML
 */
function _termReferenceBtns(data = [], newTab = false) {
  let html = '<div class="bg-labels-wrap">';

  for (const d of data) {
    html += termReferenceBtn(d.show_path, d.reference, d.context, newTab);
  }

  html += '</div>'

  return html;
}

/**
 * Returns formatted text for a collection of terminology references separated by ;
 * @param {Array} data Array of items containing the show_path, reference and context parameters
 * @return {string} formatted text
 */
function _termReferenceStrings(data = []) {
  let texts = [];

  for (const d of data) {
    if (d.context)
      texts.push(unmanagedConceptRef(d.reference, d.context))
    else
      texts.push(managedConceptRef(d.reference))
  }

  return texts.join('; ');
}

export {
  termReferences
}
