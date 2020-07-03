/*** Renderers for verious Collections ***/

import { termReferenceBtn } from 'shared/ui/buttons'

/**
 * Returns HTMl for a collection of wrapped termReference buttons
 * @param {Array} data Array of items containing the show_path, reference and context parameters
 * @return {string} formatted HTML
 */
function termReferenceBtns(data) {
  let html = '<div class="bg-labels-wrap">';
  for (const d of data) {
    html += termReferenceBtn(d.show_path, d.reference, d.context);
  }
  html += '</div>'

  return html;
};

export {
  termReferenceBtns
}
