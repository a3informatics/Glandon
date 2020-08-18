/**
 * Compare if two item reference collections match through their children ids, in any order
 * @param {Array} a First collection of item objects to compare
 * @param {Array} b Second collection of item objects to compare
 * @return {boolean} Value representing whether the collections match no matter their children's order
 */
function compareRefItems(a, b) {
  return _.isEqual( _.sortBy(a.map((d) => d.reference.id)), _.sortBy(b.map((d) => d.reference.id)) );
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
  compareRefItems,
  isCDISC,
  tableInteraction
}
