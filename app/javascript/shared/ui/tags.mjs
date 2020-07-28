/*** Renderers for Tags ***/

/**
 * Master Tag HEX color map
 */
const tagColorsMap = {
  'SDTM': '#f29c8c',
  'QS': '#e4aca1',
    'QS-FT': '#e4aca1',
    'COA': '#e4aca1',
    'QRS': '#e4aca1',
  'CDASH': '#eec293',
  'ADaM': '#b6d58f',
  'Protocol': '#93c9b5',
  'SEND': '#a9aee0',
  'CDISC': '#9dc0cf',
  'default': '#6d91a1'
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

export { 
  getColorByTag,
  colorizeTagOutlines,
  renderTagsInline
}
