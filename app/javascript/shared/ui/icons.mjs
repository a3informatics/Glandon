import { getRdfType, getRdfName } from 'shared/helpers/rdf_types'
import { isCDISC } from 'shared/helpers/utils'

/*** Icon Renderers ***/

const icons = {
  /**
   * Returns HTML for an true/false icon
   * @param {boolean} value type of icon to be returned
   * @return {string} formatted icon HTML
   */
  checkMarkIcon(value) {
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
}

/*** Inline Icon Renderers ***/

const iconsInline = { 
  /**
   * Returns HTML for an inline clickable Remove icon
   * @param {boolean} disabled show button as disabled [default = false]
   * @param {boolean} ttip with or without tooltip
   * @param {string} ttipText text of the tooltip (ttip must be true)
   * @return {string} formatted button HTML
   */
  removeIcon({ disabled = false, ttip = false, ttipText = "" } = {}) {
    let cssClasses = `remove in-line clickable text-accent-2 ${disabled ? 'disabled' : ''}`;

    return _renderIcon({
      iconName: 'times',
      ttip,
      ttipText,
      ttipClasses: 'ttip-table left',
      cssClasses
    });
  },
  /**
   * Returns HTML for an inline clickable Edit icon
   * @param {boolean} disabled show button as disabled [default = false]
   * @param {boolean} ttip with or without tooltip
   * @param {string} ttipText text of the tooltip (ttip must be true)
   * @return {string} formatted button HTML
   */
  editIcon({ disabled = false, ttip = false, ttipText = "" } = {}) {
    let cssClasses = `edit in-line clickable text-link ${disabled ? 'disabled' : ''}`;

    return _renderIcon({
      iconName: 'edit',
      ttip,
      ttipText,
      ttipClasses: 'ttip-table left',
      cssClasses
    });
  }
}

/*** Renderers for Item RDF Types, Icons and Colors ***/

const iconTypes = { 
  /**
   * Defines an RDF Type - Icon, Char & Color map, and fetches these values based on type argument
   * @param {string} type Item RDF type to get the icon & color details for
   * @param {Object} params optional ownership specifying parameter (for CDISC color override)
   * @return {Object} Object containing icon, char and color definitions for the type argument
   */
  typeIconsColorsMap(type, params = {}) {
    const typeDefsMap = {}

    iconTypeMap[getRdfType('C_TH')] = {
      icon: 'icon-terminology',
      char: '\ue909',
      color: '#6d91a1'
    }
    iconTypeMap[getRdfType('C_TH_CL')] = {
      icon: 'icon-codelist',
      char: '\ue952',
      color: '#9dc0cf'
    }
    iconTypeMap[getRdfType('C_TH_SUBSET')] = {
      icon: 'icon-subset',
      char: '\ue941',
      color: '#9dc0cf'
    }
    iconTypeMap[getRdfType('C_TH_EXT')] = {
      icon: 'icon-extension',
      char: '\ue945',
      color: '#9dc0cf'
    }
    iconTypeMap[getRdfType('C_TH_CLI')] = {
      icon: 'icon-codelist-item',
      char: '\ue958',
      color: '#9dc0cf'
    }
    iconTypeMap[getRdfType('FORM')] = {
      icon: 'icon-forms',
      char: '\ue91c',
      color: '#96d6bc'
    }
    iconTypeMap[getRdfType('BC')] = {
      icon: 'icon-biocon',
      char: '\ue90b',
      color: '#989df1'
    }
    iconTypeMap[getRdfType('BCT')] = {
      icon: 'icon-biocon-template',
      char: '\ue969',
      color: '#adb2f6'
    }
    iconTypeMap['unknown'] = {
      icon: 'icon-help',
      char: '\ue94e',
      color: '#c4c4c4'
    }

    const result = type in iconTypeMap ? iconTypeMap[type] : iconTypeMap['unknown'];

    // Override color if CDISC owned
    if(isCDISC(params))
      result.color = '#f5d684';

    return result;
  },
  /**
   * Renders colored item type icon based on the argument rdf type and params
   * @param {string} type Item RDF type to render the icon fo r
   * @param {Object} params style parameters
   * @param {string} params.size text size css class
   * @param {boolean} params.ttip set to true to render tooltip
   * @param {string} params.owner owner name for color override of cdisc items
   * @return {string} rendered icon HTML
   */
  renderIcon(type, params) {
    let size = params.size || "text-xnormal",
        iconParams = this.typeIconsColorsMap(type, params),
        output = '';

    output += `<span class="${iconParams.icon} ${size} ${params.ttip ? 'ttip' : ''}" style="color: ${iconParams.color}">`
    if (params.ttip)
      output +=   `<span class="ttip-text ttip-table shadow-small text-medium text-small">${getRdfName(type)}</span>`
    output += `</span>`

    return output;
  },
  /**
   * Renders colored item type badge with icon based on the argument rdf type and params
   * @param {string} type Item RDF type to render the icon fo r
   * @param {Object} params style parameters
   * @param {string} params.size circular-badge size css class
   * @param {boolean} params.ttip set to true to render tooltip
   * @param {string} params.owner owner name for color override of cdisc items
   * @return {string} rendered icon badge HTML
   */
  renderIconBadge(type, params) {
    let size = params.size || "small",
        iconParams = this.typeIconsColorsMap(type, params),
        output = '';

    output += `<span class="circular-badge text-white ${size} ${params.ttip ? 'ttip' : ''}" style="background: ${iconParams.color}">`
    output +=   `<span class="${iconParams.icon} text-xnormal"></span>`
    if (params.ttip)
      output += `<span class="ttip-text shadow-small text-medium text-small">${getRdfName(type)}</span>`
    output += `</span>`

    return output;
  }
}

/*** Private ***/

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
  icons,
  iconsInline,
  iconTypes
}
