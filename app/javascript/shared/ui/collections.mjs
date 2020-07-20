/*** Renderers for verious Collections ***/

import { termReferenceBtn } from 'shared/ui/buttons'
import { managedConceptRef, unmanagedConceptRef } from 'shared/ui/strings'

/**
 * Returns formatted collection of terminology references based on type
 * @param {Array} data Array of items containing the show_path, reference and context parameters
 * @param {string} type Format type - 'display' for HTML, anything else for raw strings
 * @return {string} formatted HTML / text
 */
function termReferences(data = [], type) {
  return (type === 'display' ? _termReferenceBtns(data) : _termReferenceStrings(data));
}

/** Private **/

/**
 * Returns HTMl for a collection of wrapped termReference buttons
 * @param {Array} data Array of items containing the show_path, reference and context parameters
 * @return {string} formatted HTML
 */
function _termReferenceBtns(data = []) {
  let html = '<div class="bg-labels-wrap">';

  for (const d of data) {
    html += termReferenceBtn(d.show_path, d.reference, d.context);
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
