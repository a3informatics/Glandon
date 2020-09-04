/*** Renderers for Spinners ***/

/**
 * @require spinner_full_page .scss to be included in pages where using full page spinner renderer
 */

/**
 * Render a Spinner with optionally given text
 * @param {string} size desired spinner size ('tiny'/'small'/'medium'/'large')
 * @param {string} text text to render, optional
 * @return {string} formatted Spinner HTML
 */
function renderSpinner(size, text = '') {
  let spinner = `<div class='spinner-container'>` +
                  `<div class='lds-css ng-scope'>` +
                    `<div class='spinner-el ${size}'>` +
                      `<div></div><div></div><div><div></div></div><div><div></div></div>` +
                    `</div>` +
                    (text == '' ? text : `<div class='spinner-text'>${text}</div>`) +
                  `</div>` +
               `</div>`

  return spinner;
}

/**
 * Render a full-page Spinner with optionally given text
 * @param {string} text text to render, optional
 * @return {string} formatted Spinner HTML
 */
function renderFullPageSpinner(text = '') {
  let spinner = renderSpinner('medium', text);

  return spinner.replace('spinner-container', 'fp-spinner-wrap')
                .replace('spinner-txt', 'fp-spinner-msg');
}

/**
 * Render a Spinner within an element
 * The element cannot not already have a direct child spinner - duplicate render
 * @param {( string | JQuery Element )} element Selector / element to append the spinner to
 * @param {string} size Desired spinner size ('small'/'medium'/'large')
 * @param {string} text Spinner text, optional
 */
function renderSpinnerIn$(element, size, text = '') {
  if ( !$(element).children('.spinner-container').length )
    $(element).append(renderSpinner(size, text));
}

/**
 * Remove a Spinner from an element
 * @param {( string | JQuery Element )} element selector / element to remove the spinner from
 */
function removeSpinnerFrom$(element) {
  $(element).find('.spinner-container').remove();
}

/**
 * Render a spinner with text placed on the side
 * @param {string} size desired spinner size ('small'/'medium'/'large')
 * @param {string} text text to render, optional
 */
function renderSpinnerSideText(size, text) {
  return renderSpinner(size, text).replace('spinner-container', 'spinner-container txt-right');
}

/**
 * Enable / disable the .el-loading class on an element
 * @param {(string / JQUery Element)} element selector / element to toggle the class on
 * @param {boolean} enable value representing the desired loading state being enabled / disabled
 */
 function toggleSpinner$(element, enable) {
  $(element).toggleClass("el-loading", enable);
}

export {
  renderSpinner,
  renderFullPageSpinner,
  renderSpinnerIn$,
  removeSpinnerFrom$,
  renderSpinnerSideText,
  toggleSpinner$
}
