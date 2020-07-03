/*** Renderers for Icons ***/

/**
 * Returns HTML for an inline clickable Remove icon
 * @param {boolean} disabled show button as disabled [default = false]
 * @param {boolean} ttip with or without tooltip
 * @param {string} ttipText text of the tooltip (ttip must be true)
 * @return {string} formatted button HTML
 */
function removeIconInline({ disabled = false, ttip = false, ttipText = "" } = {}) {
  let cssClasses = `remove in-line clickable text-accent-2 ${disabled ? 'disabled' : ''}`;

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
  let cssClasses = `edit in-line clickable text-link ${disabled ? 'disabled' : ''}`;

  return _renderIcon({
    iconName: 'edit',
    ttip,
    ttipText,
    ttipClasses: 'ttip-table left',
    cssClasses
  });
}

/**
 * Returns HTML for an true/false icon
 * @param {boolean} value type of icon to be returned
 * @return {string} formatted icon HTML
 */
function checkMarkIcon(value) {
  if (value)
    return _renderIcon({
      iconName: 'sel-filled text-normal',
      cssClasses: 'text-link'
    });
  else
    return _renderIcon({
      iconName: 'times-circle text-normal',
      cssClasses: 'text-accent-2'
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
  return `<span class='icon-${iconName} ${cssClasses} ${ttip ? 'ttip' : ''}' style='${style}'>` +
            (ttip ? `<span class='ttip-text shadow-small text-medium ${ttipClasses}'> ${ttipText} </span>` : '') +
         `</span>`;
}

export {
  editIconInline,
  removeIconInline,
  checkMarkIcon
}
