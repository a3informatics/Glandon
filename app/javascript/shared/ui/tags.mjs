import colors from 'shared/ui/colors'

/*** Tags Helpers and Renderers ***/

/**
 * Master Tag HEX color map
 */
const tagColorsMap = {
  'SDTM': colors.lightRed,
  'QS': colors.fadedRed,
    'QS-FT': colors.fadedRed,
    'COA': colors.fadedRed,
    'QRS': colors.fadedRed,
  'CDASH': colors.lightOrange,
  'ADaM': colors.oliveGreen,
  'Protocol': colors.accentAquaDark,
  'SEND': colors.accentPurple,
  'CDISC': colors.accent1,
  'Define-XML': colors.primaryBright,
  'default': colors.primaryLight
}

/**
 * Gets HEX color based on Tag name
 * @param {string} tag Tag text
 * @return {string} HEX color for a CDISC Tag / default color for any other tag
 */
function getColorByTag(tag) {
  return tag in tagColorsMap ? tagColorsMap[tag] : tagColorsMap.default;
}

/**
 * Styles tag elements outline with assgined color
 * @param {string} selector Selector of target elements (with parent)
 */
function tagOutlines(selector = ".labels-inline-wrap .tag") {

  // Iterate over tag elements
  $.each( $(selector), (i, el) => {

    // Get color based on text of the tag
    let tagColor = getColorByTag( $(el).text() );

    $( el ).css( 'border-color', tagColor );

  });

}

/**
 * Converts tags string into inline tags with a color-coded badge
 * @param {string} tagsString Tags separated by ;
 * @return {string} formatted inline tags HTML, 'None' if tagsString empty
 */
function renderTagsInline(tagsString) {

  // Return 'None' when there are no tags
  if (!tagsString)
    return 'None';

  let tags = tagsString.split('; '),
      output = '';

  // Render HTML badge for each tag
  for (const tag of tags) {
    output += `<span class='min-badge-item'>` +
              `<span class='circular-badge tiny' style='background: ${getColorByTag(tag)}'></span>` +
               tag +
            `</span>`;
  }

  return output;
}

/**
 * Get HTML for a single styled Tag label
 * @param {string} tagLabel Name of the Tag
 * @return {string} Single Tag label HTML
 */
function renderTag(tagLabel, { cssClasses = '', id = '' } = {}) {

  return `<span class='bg-label tag ${ cssClasses }'
                style='border-color: ${ getColorByTag( tagLabel ) }'
                data-id='${ id }'>
            ${ tagLabel }
          </span>`;

}

export { 
  getColorByTag,
  tagOutlines,
  renderTagsInline,
  renderTag
}
