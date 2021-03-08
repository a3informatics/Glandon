/**
 * Rename a key in an object (without mutating the original)
 * @param {object} obj Object instance to rename the key in  
 * @param {string} oldKey Old key name value to change 
 * @param {string} newKey New key name value 
 */
function renameKey(obj, oldKey, newKey) {

  const clone = {}
  delete Object.assign( clone, obj, { [newKey]: obj[oldKey] })[oldKey]
  return clone 

}

export {
  renameKey
}