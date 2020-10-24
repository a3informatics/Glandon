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
function colorizeTagOutlines(selector) {

  // Iterate over tag elements
  $.each( $(selector), (i, el) => {

    // Get color based on val / text of the tag
    const tagColor = getColorByTag( $(el).val() || $(el).text() );

    // Apply CSS
    $(el).css('background', 'transparent')
         .css('box-shadow', `inset 0 0 0 2px ${tagColor}`);
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
  colorizeTagOutlines,
  renderTagsInline,
  renderTag
}
