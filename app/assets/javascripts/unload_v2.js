/*
* Page Unload - releases token when uses leaves a page
*/

/**
* Unload constructor
* @param id [Boolean] Keep token boolean
*
* @return [void]
*/
function UnloadV2(id, keep, callback) {
	this.id = id;
  this.keep = keep;
  this.callback = callback;

	var _this = this;
	window.onbeforeunload = function(){
		_this.handleUnload();
	}

}

/**
 * Handles the unload event
 *
 * @return [void]
 */
UnloadV2.prototype.handleUnload = function() {
	var _this = this;
  
  // Callback to any actions required. Do this before the release of the token.
	_this.callback();
  
  // Release the token if we don't want to keep it
	if (!_this.keep) {
		$.ajax({
			url: '/tokens/' + _this.id +  '/release',
			type: 'POST',
			dataType: 'json',
		});
	}
}
