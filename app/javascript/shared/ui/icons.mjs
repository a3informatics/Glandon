import { getRdfType, getRdfName } from 'shared/helpers/rdf_types'
import { isCDISC } from 'shared/helpers/utils'
import colors from 'shared/ui/colors'
import { isCharLetter } from 'shared/helpers/strings'

/*** Icon Renderers ***/

const icons = {
  /**
   * Returns HTML for an true/false icon
   * @param {boolean} value type of icon to be returned
   * @param {string} cssClasses custom css classes, optional
   * @param {boolean} focusable set to true to include tabindex in icon
   * @return {string} formatted icon HTML
   */
  checkMarkIcon(value, cssClasses = '', focusable = false ) {
    if (value)
      return renderIcon({
        iconName: 'sel-filled text-normal',
        cssClasses: cssClasses || 'text-link',
        focusable
      });
    else
      return renderIcon({
        iconName: 'times-circle text-normal',
        cssClasses: cssClasses || 'text-accent-2',
       focusable
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

    return renderIcon({
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

    return renderIcon({
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
   * Fetches mapped Icon, Char and Color object based on type argument
   * @param {string} type Item RDF type to get the icon & color details for
   * @param {Object} params optional ownership specifying parameter (for CDISC color override)
   * @return {Object} Object containing icon, char and color definitions for the type argument
   */
  typeIconMap(type, params = {}) {
    const result = type in _typeIconMap ? _typeIconMap[type] : _typeIconMap['unknown'];

    // Override color if CDISC owned
    if ( isCDISC(params) )
      result.color = colors.accent1;

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
        iconParams = this.typeIconMap(type, params),
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
        iconParams = this.typeIconMap(type, params),
        output = '';

    output += `<span class="circular-badge text-white ${size} ${params.ttip ? 'ttip' : ''}" style="background: ${iconParams.color}">`
    output +=   `<span class="${iconParams.icon} text-xnormal"></span>`
    if (params.ttip)
      output += `<span class="ttip-text shadow-small text-medium text-small">${getRdfName(type)}</span>`
    output += `</span>`

    return output;
  }
}

/*** Generic Renderer ***/

/**
 * Returns HTML for a generic inline icon button based on parameters
 * @return {string} formatted button HTML
 */
function renderIcon({
  iconName,
  cssClasses = "",
  ttip = false,
  ttipText,
  ttipClasses = "",
  style = "",
  focusable = false
}) {

  if ( isCharLetter(iconName) )
    return `<span class='font-bold ${cssClasses} ${ttip ? 'ttip' : ''}'> ` +
            (ttip ? `<span class='ttip-text shadow-small text-medium ${ttipClasses}'> ${ttipText} </span>` : '') +
            `${ iconName }`+
            `</span>`;

  return `<span class='icon-${iconName} ${cssClasses} ${ttip ? 'ttip' : ''}' style='${style}' ${focusable ? "tabindex='1'" : ""}>` +
            (ttip ? `<span class='ttip-text shadow-small text-medium ${ttipClasses}'> ${ttipText} </span>` : '') +
         `</span>`;
}

/**
 * Defines an RDF Type - Icon, Char & Color map
 */
const _typeIconMap = {}

_typeIconMap[getRdfType('TH')] = {
  icon: 'icon-terminology',
  char: '\ue909',
  color: colors.primaryLight
}
_typeIconMap[getRdfType('TH_CL')] = {
  icon: 'icon-codelist',
  char: '\ue952',
  color: colors.primaryBright
}
_typeIconMap[getRdfType('TH_SUBSET')] = {
  icon: 'icon-subset',
  char: '\ue941',
  color: colors.primaryBright
}
_typeIconMap[getRdfType('TH_EXT')] = {
  icon: 'icon-extension',
  char: '\ue945',
  color: colors.primaryBright
}
_typeIconMap[getRdfType('TH_CLI')] = {
  icon: 'icon-codelist-item',
  char: '\ue958',
  color: colors.primaryBright
}
_typeIconMap[getRdfType('FORM')] = {
  icon: 'icon-forms',
  char: '\ue91c',
  color: colors.accentAqua
}
_typeIconMap[getRdfType('BC')] = {
  icon: 'icon-biocon',
  char: '\ue90b',
  color: colors.accentPurple
}
_typeIconMap[getRdfType('BCT')] = {
  icon: 'icon-biocon-template',
  char: '\ue969',
  color: colors.accentPurpleLight
}
_typeIconMap[getRdfType('NORMAL_GROUP')] = {
  icon: '',
  char: 'G',
  color: colors.lightOrange
}
_typeIconMap[getRdfType('COMMON_GROUP')] = {
  icon: '',
  char: 'C',
  color: colors.lightOrange
}
_typeIconMap[getRdfType('COMMON_ITEM')] = {
  icon: '',
  char: 'I',
  color: colors.fadedRed
}
_typeIconMap[getRdfType('TEXTLABEL')] = {
  icon: '',
  char: 'T',
  color: '#7dbca1'
}
_typeIconMap[getRdfType('PLACEHOLDER')] = {
  icon: '',
  char: 'P',
  color: colors.greyLight
}
_typeIconMap[getRdfType('QUESTION')] = {
  icon: '',
  char: 'Q',
  color: colors.secondaryLight
}
_typeIconMap[getRdfType('MAPPING')] = {
  icon: '',
  char: 'M',
  color: colors.accentAquaDark
}
_typeIconMap[getRdfType('BC_QUESTION')] = {
  icon: 'icon-biocon',
  char: '\ue90b',
  color: colors.accentPurpleLight
}
_typeIconMap[getRdfType('TC_REF')] = {
  icon: 'icon-codelist',
  char: '\ue952',
  color: colors.primaryBright
}
_typeIconMap[getRdfType('TUC_REF')] = {
  icon: 'icon-codelist-item',
  char: '\ue958',
  color: colors.primaryBright
}
_typeIconMap['unknown'] = {
  icon: 'icon-help',
  char: '\ue94e',
  color: colors.greyLight
}

export {
  icons,
  iconsInline,
  iconTypes,
  renderIcon
}
