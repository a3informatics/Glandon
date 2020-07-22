/**
 * Checks if data instance mentions CDISC ownership
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
  isCDISC,
  tableInteraction
}
