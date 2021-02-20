import { managedItemRef, unmanagedItemRef } from 'shared/ui/strings'
import { renderIcon } from 'shared/ui/icons'

/*** Renderers for Buttons ***/

/**
 * Returns HTML for a button linking to item's history
 * @param {Object} params Button parameters
 * @param {string} params.url Path to the item's history
 * @param {string} params.id Button id, optional
 * @param {string} params.icon Button icon name (without 'icon-' prefix)
 * @param {string} params.color Button color css class, optional
 * @param {string} params.ttip Button tooltip text, optional
 * @param {string} params.ttipClasses Tooltip CSS classes, optional
 * @param {boolean} params.disabled Button disabled state, optional
 * @return {string} formatted button HTML
 */
function iconBtn({
  url = '#',
  id,
  icon,
  color = '',
  ttip,
  ttipClasses = 'ttip-top',
  disabled = false
  }) {
  return `<a href='${url}' ${ id ? ` id='${ id }' ` : '' } class='btn icon-only ${ color } ${ disabled ? 'disabled' : '' } ${ ttip ? 'ttip' : '' }'>
            ${ ttip ? `<span class='ttip-text ${ ttipClasses } shadow-small text-medium text-small'>${ ttip }</span>` : ''}
            ${ renderIcon({ iconName: icon }) }
         </a>`;

}

/**
 * Returns HTML for a Token Timeout button
 * @param {string} size Button size class [default='small']
 * @return {string} formatted button HTML
 */
function tokenTimeoutBtn(size = 'small') {
  return `<a href="#" class="ico-btn-sec small token-timeout">
            <span class="circular-badge">
              <span class="icon-lock"></span>
            </span>
            <span class="ico-btn-sec-text text-tiny"></span>
          </a>`;
}

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
  return `<a href='${url}' class='btn light btn-xs'> Show </a>`;
}

/**
 * Returns HTML for a button linking to an managed/unamanaged item
 * @param {string} url path to the item's history
 * @param {Object} item Unmanaged / Managed Item data object
 * @param {Object} parent Optional Managed Item data object
 * @param {boolean} newTab Set true to open link in a new tab, optional [default = false]
 * @return {string} Reference link HTML
 */
function itemReferenceBtn(url, item, parent, newTab = false) {

  const text = parent ? 
    unmanagedItemRef( item, parent ) : 
    managedItemRef( item )

  return `<a href='${ url }' ${ newTab ? 'target="_blank"' : '' } class='bg-label highlightable'>
            ${ text }
          </a> `

}

export {
  historyBtn,
  itemReferenceBtn,
  showBtn,
  tokenTimeoutBtn,
  iconBtn
}
