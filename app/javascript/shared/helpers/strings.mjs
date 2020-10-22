/**
 * Check if a given value is contained in a text
 * @param {string} value String to find in text
 * @param {string} text Text to search in
 * @return {boolean} True if value found in string
 */
function findInString(value, text) {

  if ( typeof text === 'string' )
    return text.toLowerCase().includes( value.toLowerCase() );
  else
    return false

}

/**
 * Shorten a long string if more than maxLength and add '...' at the end
 * @param {string} text String to crop
 * @param {integer} maxLength Maximum string length before cropping, optional [default=30]
 * @return {string} Cropped text if over maxLength limit, otherwise returns text
 */
function cropText(text, maxLength = 30) {

  if ( typeof text === 'string' )
    return text.length > maxLength ? `${ text.substring(0, maxLength) }...` : text;
  else
    return text

}

/**
 * Check if a character is a letter
 * @param {string} char Character to check
 * @return {boolean} True if character is an english alphabet letter
 */
function isCharLetter(char) {
  return char.length === 1 && char.toUpperCase() != char.toLowerCase();
}

export {
  findInString,
  cropText,
  isCharLetter,
}
