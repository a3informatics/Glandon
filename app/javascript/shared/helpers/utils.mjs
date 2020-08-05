/**
 * Get the deepest *property* - (first non-object) *value* pair of a nested object recursively
 * @param {object} object Nested object to search through
 * @param {string} property Property name (for recursion, leave empty when calling)
 * @return {object} Contains property name under the 'property' key and the first non-object value found under the 'value' key
 */
function getDeepestValue(object, property) {
  if (typeof object !== 'object' || Array.isArray(object)){
    return { property, value: object }
  }
  for ( let prop in object ) {
    return getDeepestValue(object[prop], prop)
  }
}

/**
 * Check if data instance mentions CDISC ownership
 * @param {?} data Can be owner string or object containing the owner key
 * @return {boolean} Value of cdisc ownership encoded in data argument
 */
function isCDISC(data) {
  const ownerName = data.owner || data;

  try {
    return ownerName.toLowerCase() === 'cdisc';
  }
  catch {
    return false
  }
}

const tableInteraction = {
  /**
   * Enable table interactivity
   * @param {string} selector Table selector
   */
  enable(selector) {
    $(selector).removeClass("table-disabled");
  },
  /**
   * Disable table interactivity
   * @param {string} selector Table selector
   */
  disable(selector) {
    $(selector).addClass("table-disabled");
  }
}

export {
  getDeepestValue,
  isCDISC,
  tableInteraction
}
