/**
 * Fetches data from server
 * @param {Object} params Request parameters
 * @param {string} params.url Url of source data
 * @param {Object} params.data Optional request data object
 * @param {function} params.done Callback when all data is loaded
 * @param {function} params.always Callback which should be invoked after all is done / if anything fails. Usually for disabling loading animation.
 * @param {boolean} params.cache False if cache should be disabled. Default true
 */
function $get(params = {}) {
  params.type = "GET";
  _simpleAjax(params);
}

/**
 * Removes data from server
 * @param {Object} params Request parameters
 * @param {string} params.url Target url
 * @param {Object} params.data Optional request data object
 * @param {function} params.done Callback when all data is loaded
 * @param {function} params.always Callback which should be invoked after all is done / if anything fails. Usually for disabling loading animation.
 */
function $delete(params = {}) {
  params.type = "DELETE";
  _simpleAjax(params);
}

/**
 * PUTs data to server
 * @param {Object} params Request parameters
 * @param {string} params.url Target url
 * @param {Object} params.data Optional request data object
 * @param {function} params.done Callback when all data is loaded
 * @param {function} params.always Callback which should be invoked after all is done / if anything fails. Usually for disabling loading animation.
 */
function $put(params = {}) {
  params.type = "PUT";
  _simpleAjax(params);
}

/**
 * POSTs data to server
 * @param {Object} params Request parameters
 * @param {string} params.url Target url
 * @param {Object} params.data Optional request data object
 * @param {function} params.done Callback when all data is loaded
 * @param {function} params.always Callback which should be invoked after all is done / if anything fails. Usually for disabling loading animation.
 */
function $post(params = {}) {
  params.type = "POST";
  _simpleAjax(params);
}


/**
 * Fetches data from server in a paginated manner
 * @param {int} offset Current offset, [default = 0]
 * @param {Object} params Request parameters
 * @param {string} params.url Url of source data
 * @param {string} params.strictParam Strict parameter name required for the controller params
 * @param {int} params.count Count of items fetched in one request (page)
 * @param {boolean} params.data Optional additional data to pass to the server (without strict param)
 * @param {function} params.pageDone Callback after each page is fetched (data is passed to the callback)
 * @param {function} params.done Callback when all data is loaded
 * @param {function} params.always Callback which should be invoked after all is done / if anything fails. Usually for disabling loading animation.
 * @param {$element} params.errorDiv Div to display error alerts in. Optional.
 * @param {boolean} params.cache False if cache should be disabled. Default true
 */
function $getPaginated(offset = 0, params = {}) {
  $.get({
    url: _jsonizeUrl(params.url),
    dataType: "json",
    data: _getPaginationParams(offset, params),
    cache: (params.cache != null ? params.cache : true)
  })
  .done((result) => {
    // One 'page' of data loaded
    params.pageDone(result.data);

    if (_.isNumber(result.count) && _.isNumber(result.offset) && result.count >= params.count)
      $getPaginated(result.offset + params.count, params);
    else
      // Data loaded
      params.done();
  })
  .fail((x, s, e) => handleAjaxError(x, s, e, params.errorDiv))
  .always(() => params.always());
}


/** Support **/

/**
 * Generic call to server with error handling
 * @param {Object} params Request parameters
 * @param {string} params.url Url of source data
 * @param {string} params.type Request type
 * @param {Object} params.data Optional request data object
 * @param {function} params.done Callback when all data is loaded
 * @param {function} params.always Callback which should be invoked after all is done / if anything fails. Usually for disabling loading animation.
 * @param {boolean} params.cache Optional cache option
 * @param {JQuery Element} params.errorDiv Div to display errors in, optional
 * @param {boolean} params.rawResult Set to true to return the raw result to the done callback. Otherwise result.data will be returned. Optional [default=false]
 */
function _simpleAjax({ url, type, data = {}, done = () => {}, always = () => {}, error = handleAjaxError, cache = true, errorDiv = null, rawResult = false }) {
  $.ajax({
    url: _jsonizeUrl(url),
    type: type,
    dataType: "json",
    data: data,
    cache: cache,
  })
  .done((result) => done( rawResult ? result : (result.data || result) ))
  .fail((x, s, e) => error(x, s, e, errorDiv))
  .always(() => always());
}

/**
 * Generates data parameters for paginated data request. Merges additional data from params.
 * @param {int} offset Current page offset
 * @param {params} params Request params
 * @return {object} Paginated request parameters
 */
function _getPaginationParams(offset, params) {
  let parameters = {}

  parameters[params.strictParam] = {
    offset: offset,
    count: params.count
  }

  if(params.data !== null)
    Object.assign(parameters[params.strictParam], params.data)

  return parameters;
}

/**
 * Inserts .json into a url (chrome caching bug)
 * @param {string} url Url to process
 * @return {string} Url with .json prepended to '?' or appended to the end of url
 */
function _jsonizeUrl(url) {
  // Prepends ? with .json
  if (url.includes('?') && !url.includes('.json'))
    return url.replace('?', '.json?')
  // Appends .json to the end of url
  else if (!url.includes('?') && !url.includes('.json'))
    return `${url}.json`
  // No change, .json already included
  else
    return url;
}

export { $get, $put, $post, $delete, $getPaginated }
