/*** Renderers for Buttons and Icons ***/

/**
 * Returns HTML for a button linking to item's history
 * @param {string} url path to the item's history
 * @return {string} formatted button HTML
 */
function renderHistoryBtn(url) {
  return `<a href='${url}' class='btn white btn-xs'><span class='icon-old'></span> History </a>`;
}

/**
 * Returns HTML for an inline clickable Remove icon
 * @param {boolean} disabled show button as disabled [default = false]
 * @param {boolean} ttip with or without tooltip
 * @param {string} ttipText text of the tooltip (ttip must be true)
 * @return {string} formatted button HTML
 */
function removeIconInline({ disabled = false, ttip = false, ttipText = "" } = {}) {
  let cssClasses = `remove in-line text-accent-2 ${disabled ? 'disabled' : ''}`;

  return _renderIcon({
    iconName: 'times',
    ttip,
    ttipText,
    ttipClasses: 'ttip-table left',
    cssClasses
  });
}

/**
 * Returns HTML for an inline clickable Edit icon
 * @param {boolean} disabled show button as disabled [default = false]
 * @param {boolean} ttip with or without tooltip
 * @param {string} ttipText text of the tooltip (ttip must be true)
 * @return {string} formatted button HTML
 */
function editIconInline({ disabled = false, ttip = false, ttipText = "" } = {}) {
  let cssClasses = `edit in-line text-link ${disabled ? 'disabled' : ''}`;

  return _renderIcon({
    iconName: 'edit',
    ttip,
    ttipText,
    ttipClasses: 'ttip-table left',
    cssClasses
  });
}

/**
 * Returns HTML for a generic inline icon button based on parameters
 * @return {string} formatted button HTML
 */
function _renderIcon({
  iconName,
  cssClasses = "",
  ttip = false,
  ttipText,
  ttipClasses = "",
  style = ""
}) {
  return `<span class='clickable icon-${iconName} ${cssClasses} ${ttip ? 'ttip' : ''}' style='${style}'>` +
            (ttip ? `<span class='ttip-text shadow-small text-medium ${ttipClasses}'> ${ttipText} </span>` : '') +
         `</span>`;
}

export {
  renderHistoryBtn,
  editIconInline,
  removeIconInline
}
