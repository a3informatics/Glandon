/**
 * Base Cacheable Class
 * @description Implements a simple cache, extensible
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class Cacheable {

  /**
   * Create a Cacheable instance
   */
  constructor() {
    // Create an empty cache object
    Object.assign(this, { cacheObj: {} });
  }

  /** Private **/

  /**
   * Save data to cache under a key
   * @param {string} key Unique identifier to cache data under
   * @param {?} data Data to cache
   * @param {boolean} overwrite Set to true to overwrite data in cache if the key already exists, optional
   */
  _saveToCache(key, data, overwrite = false) {
    if ( overwrite || !this._hasCacheEntry(key) )
      this.cacheObj[key] = data;
  }

  /**
   * Retrieve data from cache stored under the key
   * @param {string} key Unique identifier data is cached under
   * @return {?} stored data value , null if not found
   */
  _getFromCache(key) {
    if (this._hasCacheEntry(key))
      return this.cacheObj[key];
    else
      return null;
  }

  /**
   * Checks if key present in cache
   * @param {string} key Unique identifier data is cached under
   * @return {boolean} Presence of key in the cache object
   */
  _hasCacheEntry(key) {
    return Object.keys(this.cacheObj).includes(key);
  }

  /**
   * Remove an entry from the cache
   * @param {string} key Unique identifier data is cached under
   */
  _removeFromCache(key) {
    if ( this._hasCacheEntry(key) )
      delete this.cacheObj[key]
  }

  /**
   * Deletes cache and re-initializes a new cache
   */
  _clearCache() {
    delete this.cacheObj;
    this.cacheObj = { }
  }
}
