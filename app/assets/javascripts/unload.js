/*
* Page Unload - releases token when uses leaves a page
*/


/**
* Unload constructor
* @param id [Boolean] Keep token boolean
*
* @return [void]
*/
function Unload(keepToken) {
	this.keepToken = keepToken;
	var _this = this;
	window.onbeforeunload = function(){
		_this.handleUnload(_this.keepToken);
	}
}

/**
 * Handles the unload event
 * @param id [Boolean] Keep token boolean
 *
 * @return [void]
 */
Unload.prototype.handleUnload = function(keepToken) {
	var _this = this;
	var tokenId = $('#edit_lock_token').val();
	if(typeof(pageUnloadAction) !== 'undefined')
		pageUnloadAction();
	if (!keepToken) {
		if (tokenId !== "" && tokenId !== undefined) {
			$.ajax({
				url: '/tokens/' + tokenId +  '/release',
				type: 'POST',
				dataType: 'json',
			});
		}
	}
}
