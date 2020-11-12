/*
* Dashboard Editor
*
*/

/**
 * Dashboard Editor Constructor
 *
 * @return [void]
 */
function DashboardEditor(editorId, listId, url) {
  var _this = this;

  this.editorId = editorId;
  this.listId = listId;
  this.url = url;

  // Init Sortable
  $(this.editorId).sortable({
    placeholder: "de-item-highlight",
    containment: "parent",
    tolerance: "pointer",
    items: "div:not(.de-header)"
  });
  $(this.editorId).disableSelection();

  // Handle marking / unmarking checkboxes
  $(this.listId).find("input").change(function(){
    var name = $(this).parent().text();
    var sym = $(this).attr("name");
    if(this.checked)
      _this.addItemToEditor(name, sym);
    else
      _this.removeItemFromEditor(sym);

    $(_this.editorId).find(".de-item").length == 1 ? $(".de-item").addClass("wide-de-item") : $(".de-item").removeClass("wide-de-item");
  });

  this.initializeState();

  $(this.listId).find("input").one("change", function(){
    _this.toggleSave(false, "");
  });
  $(this.editorId).find(".de-item").one("mousedown", function(){
    _this.toggleSave(false, "");
  });

  // Handle save button click
  $("#de-save-changes").on("click", function(){
    _this.writeSettings(_this.readEditorState());
  });

}

/**
 * When the Editor is first initialized, it prepares the UI by manually marking the checkboxes to match the actual user settings
 *
 * @return [void]
 */
DashboardEditor.prototype.initializeState = function () {
  var _this = this;
  $.each(user_dashboard_layout_settings.split(', '), function(){
    $(_this.listId).find("input[name='"+this+"']").prop("checked", true).change();
  });
}

/**
 * Adds item div to the layout editor
 *
 * @param [String] name of the item
 * @return [void]
 */
DashboardEditor.prototype.addItemToEditor = function (itemName, symbol) {
  var _this = this;
  $(_this.editorId).append(_this.generateItemHTML(itemName, symbol));
}

/**
 * Deletes an item div from the layout editor
 *
 * @param [String] name of the item
 * @return [void]
 */
DashboardEditor.prototype.removeItemFromEditor = function (symbol) {
  var _this = this;
  $(_this.editorId).find(".de-item[data-sym='"+symbol+"']").remove();
}

/**
 * Generates string HTML code of a draggable editor item
 *
 * @param [String] name of the item
 * @return [String] HTML code of an item
 */
DashboardEditor.prototype.generateItemHTML = function (itemName, symbol) {
  itemName = (itemName.length > 16 ? getStringInitials(itemName) : itemName);
  return "<div class='de-item ui-sortable-handle' data-sym='"+symbol+"'>"+itemName+"</div>";
}

/**
 * Reads the current order of the Dashboard Editor
 *
 * @return [Array] Array of string, ordered
 */
DashboardEditor.prototype.readEditorState = function(){
  var _this = this;
  var items = $(_this.editorId).find(".de-item");
  var result = [];
  $.each(items, function(){
    result.push($(this).attr("data-sym"));
  });
  return result.join(', ');
}

/**
 * Writes the settings to the server, handles response
 *
 * @param [String] comma separated layout settings
 * @return [void]
 */
DashboardEditor.prototype.writeSettings = function(settings){
  var _this = this;
  _this.toggleSave(true, "Saving...");
  var settings_data = {"user_settings": {"name": "dashboard_layout", "value": settings}};

  $.ajax({
    method: "PUT",
    url: _this.url,
    data: settings_data,
    dataType: 'json',
    success: function(result) {
      location.reload();
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      _this.toggleSave(false, "Save");
      $("#dashboardModal").modal('hide');
    }
  });
}

/**
 * Toggles the state of the save button
 *
 * @return [void]
 */
DashboardEditor.prototype.toggleSave = function(disable, text){
  var _this = this;
  var saveBtn = $("#de-save-changes");
  if(disable)
    saveBtn.addClass("disabled");
  else
    saveBtn.removeClass("disabled");
  saveBtn.text(text == "" ? saveBtn.text() : text);
}
