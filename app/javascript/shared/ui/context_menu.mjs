/**
 * Render a whole Context Menu with items
 * @param {Object} params Context Menu parameters
 * @param {string} params.menuId ID of the menu. Preferably unique.
 * @param {Array} params.menuItems Objects containing item data (see _renderMenuItem for required fields)
 * @param {Object} params.menuStyle Specify color and side classes
 * @returns {string} Formatted HTML of a Context Menu
 */
function render({
  menuId,
  menuItems = [],
  menuStyle = {
    color: "",
    side: ""
  }
}) {
  return `<span id="${menuId}" class="icon-context-menu text-normal" tabindex="1">` +
            `<div class="context-menu ${menuStyle.color || ""} ${menuStyle.side || ""} shadow-small collapsed scroll-styled">` +
              _renderItems(menuItems) +
            `</div>` +
          `</span>`;
}

/**
 * Render child items within the menu
 * @param {Array} params.menuItems Objects containing item data (see _renderMenuItem for required fields)
 * @returns {string} Formatted HTML of a menu child items
 */
function _renderItems(menuItems) {
  let html = ``;

  for(const menuItem of menuItems){
    html += _renderMenuItem(menuItem);
  }

  return html;
}

/**
 * Render a single menu item
 * @param {Object} params Item parameters
 * @param {string} params.url Href of the menu item link
 * @param {string} params.icon Icon class of the menu item
 * @param {string} params.text Menu item text
 * @param {string} params.target Optional, use when url should not be inside of 'href' (e.g. for modals)
 * @param {boolean} params.disabled Optional, set to true if item should be disabled
 * @param {string} params.id Optional id of the item
 * @param {string} params.dataToggle Specify if modal should be toggled. Optional
 * @returns {string} Formatted HTML of a menu item
 */
function _renderMenuItem({
  url,
  icon,
  text,
  target,
  disabled = false,
  id = "",
  dataToggle = ""
}) {
  disabled = disabled || (url === "");

  return `<a href = "${target || url}"` +
            `id = "${id}"` +
            `class = "option ${(disabled ? "disabled" : "") || ''}"` +
            `data-toggle = "${dataToggle}" >` +
              `<span class="${icon} text-small"></span>` +
              `<span class="text-small">${text}</span>` +
         `</a>`;
}

export { render }