/**
 * Check if a given value is contained in a text
 * @param {string} value String to find in text
 * @param {string} text Text to search in
 * @return {boolean} True if value found in string
 */
function findInString(value, text) {
  return text.toLowerCase().includes( value.toLowerCase() );
}

/**
 * Shorten a long string if more than maxLength and add '...' at the end
 * @param {string} text String to crop
 * @param {integer} maxLength Maximum string length before cropping, optional [default=30]
 * @return {string} Cropped text if over maxLength limit, otherwise returns text
 */
function cropText(text, maxLength = 30) {
  return text.length > 30 ? `${ text.substring(0, 30) }...` : text;
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
