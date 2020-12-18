import { getRdfNameByType } from 'shared/helpers/rdf_types'
import { isCDISC } from 'shared/helpers/utils'
import colors from 'shared/ui/colors'
import { isCharLetter } from 'shared/helpers/strings'
import UiRdfMap from 'shared/ui/support/ui_rdf_map'


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

    if ( value === 'true' || value === true )
      return renderIcon({
        iconName: 'sel-filled text-normal',
        cssClasses: cssClasses || 'text-link',
        focusable
      })

    else
      return renderIcon({
        iconName: 'times-circle text-normal',
        cssClasses: cssClasses || 'text-accent-2',
       focusable
      })

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

    let cssClasses = `remove in-line clickable text-accent-2 ${ disabled ? 'disabled' : '' }`

    return renderIcon({
      iconName: 'trash',
      ttipClasses: 'ttip-table left text-small',
      ttip, ttipText, cssClasses
    })

  },

  /**
   * Returns HTML for an inline clickable Edit icon
   * @param {boolean} disabled show button as disabled [default = false]
   * @param {boolean} ttip with or without tooltip
   * @param {string} ttipText text of the tooltip (ttip must be true)
   * @return {string} formatted button HTML
   */
  editIcon({ disabled = false, ttip = false, ttipText = "" } = {}) {

    let cssClasses = `edit in-line clickable text-link ${ disabled ? 'disabled' : '' }`

    return renderIcon({
      iconName: 'edit',
      ttipClasses: 'ttip-table left text-small',
      ttip, ttipText, cssClasses
    })

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

    let result = type in UiRdfMap ?
                  UiRdfMap[ type ] :
                  UiRdfMap[ 'unknown' ]

    // Make a copy of result and override its color if is CDISC owned
    if ( isCDISC( params ) )
      result = Object.assign( {}, result, { color: colors.accent1 } )

    return result

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
        iconParams = this.typeIconMap( type, params )
     
    return `<span 
              class="${ iconParams.icon } ${ size } ${ params.ttip ? 'ttip' : '' }" 
              style="color: ${ iconParams.color }">
                ${ params.ttip ? `<span class="ttip-text ttip-table shadow-small text-medium text-small">${ getRdfNameByType(type) }</span>` : '' }
            </span>`

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
        iconParams = this.typeIconMap( type, params )

    return `<span 
              class="circular-badge text-white ${ size } ${ params.ttip ? 'ttip' : '' }" 
              style="background: ${ iconParams.color }">
                <span class="${ iconParams.icon } text-xnormal"></span>
                ${ params.ttip ? `<span class="ttip-text shadow-small text-medium text-small">${ getRdfNameByType(type) }</span>` : '' }
            </span>`

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
    return `<span class='font-bold ${ cssClasses } ${ ttip ? 'ttip' : '' }'>
              ${ ttip ? `<span class='ttip-text shadow-small text-medium ${ ttipClasses }'> ${ ttipText } </span>` : '' }
              ${ iconName }
            </span>`

  return `<span 
            class='icon-${iconName} ${cssClasses} ${ttip ? 'ttip' : ''}' 
            style='${style}' ${focusable ? "tabindex='1'" : ""}>
              ${ ttip ? `<span class='ttip-text shadow-small text-medium ${ ttipClasses }'> ${ttipText} </span>` : '' }
          </span>`
}

export {
  icons,
  iconsInline,
  iconTypes,
  renderIcon
}
