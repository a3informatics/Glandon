import { $get } from 'shared/helpers/ajax'

/*** Renderers for Indicators ***/

/**
 * Master Indicator icon & text map. Add new indicators here
 */
const indicatorDefinitions = {
  current: { icon: 'icon-current', ttip: 'Current version' },
  extended: { icon: 'icon-extend', ttip: 'Item is extended' },
  extends: { icon: 'icon-extension', ttip: 'Item is an extension' },
  version_count: { icon: 'icon-multi', ttip: '%n% versions' },
  subset: { icon: 'icon-subset', ttip: 'Item is a subset' },
  subsetted: { icon: 'icon-subsetted', ttip: 'Item is subsetted' },
  annotations: { icon: 'icon-note-filled', ttip: '%n% change notes and<br/> %i% change instructions' },
  ranked: { icon: 'icon-rank', ttip: 'Item is ranked' },
  paired: { icon: 'icon-pair', ttip: 'Item is paired' }
}

/**
 * Renders Indicators as HTML icons or raw strings
 * @param {Object} data Server-fetched indicator data
 * @param {string} type Render type. 'display' for HTML, anything else for raw strings
 * @param {object} filter Filters to be applied to indicator data, optional
 * @return {string} formatted HTML / text
 */
function renderIndicators(data, type, filter) {
  
  // Return empty if no indicator data
  if ( _.isEmpty(data) || _.isNull(data) )
    return ''

  if ( filter )
    data = filterIndicators( data, filter );

  // Otherwise render indicator HTML / text
  let output = type === 'display' ? '<div class="indicators-wrap">' : '';

  for ( const [name, value] of Object.entries(data) ) {

    let icon = indicatorDefinitions[name].icon,
        text = indicatorDefinitions[name].ttip;

    switch (name) {
      case 'version_count':

        // Skip indicator for display type when item has less than 2 versions
        if (type === 'display' && value <= 1)
          continue

        // Handle singular / plural
        if (value === 1)
          text = text.replace('versions', 'version')

        // Replace placeholder with version count
        text = text.replace('%n%', value)

        break
      case 'annotations':

        // Skip indicator when both change notes and instructions counts are 0
        if (value.change_notes || value.change_instructions)
          // Replace placeholders and handle singular / plural
          text = text.replace('%n%', value.change_notes)
            .replace('%i%', value.change_instructions)
            .replace('notes', value.change_notes === 1 ? 'note' : 'notes')
            .replace('instructions', value.change_instructions === 1 ? 'instruction' : 'instructions');
        else
          continue

        break
      default:

        // Skip indicator when its value is false
        if (!value)
          continue

        break
    }

    if (type === 'display')
      output += _renderIndicator(icon, text) // Renders as an icon
    else
      output += `${text}. ` // Renders as a string
  }

  output += type === 'display' ? '</div>' : '';

  return output;
}

/**
 * Fetches Indicator data of an IsoConcept and appends HTML into target element
 * @param {string} url Server url for indicators fetch
 * @param {Element} target element to append Indicators HTML to
 */
function fetchItemIndicators(url, target) {
  indicatorsProcessing(true);

  $get({
    url: url,
    cache: false,
    done: (r) => $(target).html( renderIndicators(r.data.indicators) ),
    always: () => indicatorsProcessing(false)
  });

  function indicatorsProcessing(enable) {
    $(target).toggleClass('shiny-processing', enable)
                    .css('width', enable ? '100px' : 'auto')
                    .css('height', enable ? '25px' : 'auto');
  }
}

/**
 * Filtering of indicator data based on parameter object. Add more cases if needed
 * @param {Object} data Server-fetched indicator data
 * @param {Object} params filtering parameters
 * @param {boolean} params.withoutVersions specifies if version_count should be omitted from the Indicator data object
 * @return {Object} filtered Indicators data
 */
function filterIndicators(data, params = {}) {
  if (params.withoutVersions)
    return _.omit(data, 'version_count');
}

/**
 * Renders a single indicator icon HTML with a tooltip
 * @param {string} icon class name of Indicator's icon
 * @param {string} text text inside of Indicator's tooltip
 * @return {string} indicator icon HTML
 */
function _renderIndicator(icon, text) {
  return `<span class='${icon} indicator ttip'>` +
            `<span class='ttip-text shadow-small'>${text}</span>` +
         `</span>`;
}

export {
  renderIndicators,
  fetchItemIndicators,
  filterIndicators
}
