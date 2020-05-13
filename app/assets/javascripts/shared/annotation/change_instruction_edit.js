/*
* Change Instructions Editor
* Edit Change Instructions page only.
*/

$(document).ready(function() {
  var ciEditor = new CIEditor();

  var helpInfo = new InformationDialog({div: $("#edit-help")});
  $(".icon-help").on("click", helpInfo.show.bind(helpInfo));
});


/**
* Change Instructions Editor Constructor
*
* @return [void]
*/
function CIEditor() {
  this.editing = false;
  this.setListeners();
  this.htmlHelper = new CIHtml();

  this.selector = new ItemsSelector({
    id: "1",
    types: {cls: true, clitems: true},
    multiple: true,
    description: "Select one or more items to link to the Change Instruction."
  });

  this.load();
}


/**
 ****** General ******
**/


/**
 * Sets event listeners, handlers
 *
 * @return [void]
 */
CIEditor.prototype.setListeners = function () {
  $(".change-instruction").on("focusin focusout", ".content-editable", this.onContentEdit.bind(this));
  $(".change-instruction").on("keydown", ".content-editable", this.onKeyPress.bind(this));
  $(".change-instruction").on("click", "#delete-ci", this.destroy.bind(this, false));
  $(".change-instruction").on("click", ".add-links", this.openSelector.bind(this));
  $(".change-instruction").on("click", ".removable", this.destroyLink.bind(this));
}

/**
 * Generic ajax request builder, invokes callback on success
 *
 * @param params [Object] must contain: url, type, data, callback
 * @return [void]
 */
CIEditor.prototype.executeRequest = function (params) {
  this.processing(true);

	$.ajax({
		url: params.url,
		type: params.type,
    data: params.data,
		dataType: 'json',
		context: this,
		success: function (result) {
      params.callback(result);
		},
		error: function (xhr, status, error) {
      handleAjaxError(xhr, status, error);
      this.processing(false);
		}
	});
}

/**
 * Build load CI data request
 *
 * @return [void]
 */
CIEditor.prototype.load = function () {
  this.clear();

  this.executeRequest({
    url: ciBaseUrl,
    type: "GET",
    data: {},
    callback: function(result) {
      this.initHTML(result.data);
      this.processing(false);
    }.bind(this)
  });
}

/**
 * Saves text fields
 *
 * @return [void]
 */
CIEditor.prototype.save = function () {
  var description = $("#description").text().trim();
  var reference = $("#reference").text().trim();

  this.executeRequest({
    url: ciBaseUrl,
    type: "PUT",
    data: {
      change_instruction: {
        description: description,
        reference: reference
      }
    },
    callback: function(result) {
      this.processing(false);
      this.success();
    }.bind(this)
  })
}

/**
 * Build CI destroy request, redirects to root
 *
 * @param confirm [Boolean] shows confirmation dialog if false, force remove if true
 * @return [void]
 */
CIEditor.prototype.destroy = function (confirm) {
  if (!confirm)
    new ConfirmationDialog(this.destroy.bind(this, true), {dangerous: true})
    .show();

  else
    this.executeRequest({
      url: ciBaseUrl,
      type: "DELETE",
      data: {},
      callback: function (result) {
        displaySuccess("Change Instruction was removed.");
        $(".change-instruction").remove();
        location.href = "/";
      }.bind(this)
    });
}

/**
 * Build CI link destroy request, updates UI
 *
 * @param e [Event] source click event
 * @return [void]
 */
CIEditor.prototype.destroyLink = function (e) {
  var linkId = $(e.currentTarget).attr("data-id");
  var linkType = $(e.currentTarget).attr("data-type");

  this.executeRequest({
    url: ciRemoveRefsUrl,
    type: "PUT",
    data: {change_instruction: {type: linkType, concept_id: linkId}},
    callback: function (result) {
      $(e.currentTarget).remove();
      this.handleEmptyLists();
      this.processing(false);
      this.success();
    }.bind(this)
  });
}

/**
 * Process selection and post to server
 *
 * @param e [Event] trigger event
 * @return [void]
 */
CIEditor.prototype.addLinks = function (linkType, selection) {
  var data = {
    change_instruction: {
      current: [],
      previous: []
  }};

  $.each(selection, function(type, values) {
    data.change_instruction[linkType] = data.change_instruction[linkType].concat(values.map(function(v){return v.id}));
  });

  this.executeRequest({
    url: ciAddRefsUrl,
    type: "PUT",
    data: data,
    callback: function(result) {
      this.load();
      this.success();
    }.bind(this)
  })
}

/**
 * Enables / disables content editing
 *
 * @param e [Event] trigger event
 * @return [void]
 */
CIEditor.prototype.onContentEdit = function (e) {
  switch(e.type) {
    case "focusin":
      $(".content-editable")
        .removeClass("with-icon")
        .not($(e.currentTarget))
        .addClass("with-icon");
      break;
    case "focusout":
      this.save();
      $(".content-editable")
        .addClass("with-icon");
      break;
  }
}

/**
 * Key press for content-editable
 *
 * @param e [Event] trigger event
 * @return [void]
 */
CIEditor.prototype.onKeyPress = function (e) {
  switch(e.keyCode || e.which) {
    case 13:
      e.preventDefault();
      $(e.currentTarget).blur();
      this.save();
      break;
    case 27:
      $(e.currentTarget).blur();
      break;
  }
}

/**
 * Opens selector for adding links, bind callback
 *
 * @param e [Event] trigger event
 * @return [void]
 */
CIEditor.prototype.openSelector = function (e) {
  var type = $(e.currentTarget).attr("id").split('-')[1];
  this.selector.setCallback(this.addLinks.bind(this, type));
  this.selector.show();
}


/**
 ****** Support ******
**/


/**
 * Clear all CI data from HTML
 *
 * @return [void]
 */
CIEditor.prototype.clear = function () {
  $("#reference").text("");
  $("#description").text("");
  $(".items-list").empty();
}

/**
 * Success CI style animation
 *
 * @return [void]
 */
CIEditor.prototype.success = function() {
  $(".change-instruction").addClass("success");
  setTimeout(function() {$(".change-instruction").removeClass("success")}, 300);
}

/**
 * Fills page with CI data
 *
 * @return [void]
 */
CIEditor.prototype.initHTML = function (data) {
  $("#reference").text(data.reference);
  $("#description").text(data.description);

  $.each(data.previous, function(index, item) {
    var itemHTML = this.htmlHelper.listItem(item, "previous", {withHref: false, ttip: false, class: "removable"});
    $("#list-previous").append(itemHTML);
  }.bind(this));

  $.each(data.current, function(index, item) {
    var itemHTML = this.htmlHelper.listItem(item, "current", {withHref: false, ttip: false, class: "removable"});
    $("#list-current").append(itemHTML);
  }.bind(this));

  this.handleEmptyLists();
}

/**
 * Adds 'Empty' text to list if empty
 *
 * @return [void]
 */
CIEditor.prototype.handleEmptyLists = function () {
  $(".items-list").each(function(){
    if ($(this).html() == "")
      $(this).html("<div class='text-small text-light'><i>Empty</i></div>");
  });
}

/**
 * Toggles processing state
 *
 * @param enable [Boolean] true / false ~ enable / disable processing
 * @return [void]
 */
CIEditor.prototype.processing = function (enable) {
  $(".change-instruction").toggleClass("processing", enable);

  if (enable)
    spinnerInElement($(".change-instruction"), "small");
  else
    removeSpinnerInElement($(".change-instruction"));
}
