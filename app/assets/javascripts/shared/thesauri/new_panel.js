/*
* Changes Panel
* 
* Requires:
* tnp_new_button: the new button
* tnp_identifier: the new identifier (might be empty, this is permitted)
*/

/**
 * Change Panel Constructor
 *
 * @return [void]
 */
function NewPanel(url, strong_params, callback) {
  this.url = url;
  this.callback = callback;
  this.strong_params = strong_params;
  
  var _this = this;

  $('#tnp_new_button').on('click', function () {
    var identifier = $("#tnp_identifier").val();
    $("#tnp_identifier").val("");
    _this.create(identifier);
  });

}

/**
 * Create. Create the concept
 *
 * @return [void]
 */
NewPanel.prototype.create = function (identifier) {
  var _this = this;
  var data = {};
  data[_this.strong_params] = {"identifier": identifier};
  $.ajax({
    url: _this.url,
    type: 'POST',
    data: JSON.stringify(data),
    dataType: 'json',
    contentType: 'application/json',
    success: function(result){
      _this.callback(result.data);
    },
    error: function(xhr,status,error){
      handleAjaxError (xhr, status, error);
    }
  }); 
}