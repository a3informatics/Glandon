/*
* Iso Concept Tagging
*
* Requires: tag_panel [div] (find in edit_tags.html.erb),
*           iso_concept_systems/tags.scss to be included in page
*/

/**
 * Iso Concept Tagging  Constructor
 * @param [Object] contains urls: dataUrl, addTagUrl, removeTagUrl
 *
 * @return [void]
 */
function IsoConceptTagging(urls) {
  this.urls = urls;
  this.tagListDiv = $("#tags_container");
  this.tagSelected = {label: $("#add_label"), description: $("#add_description")};

  this.getTags();
}

/**
 * Fetches tags from server, inserts into page.
 *
 * @return [void]
 */
IsoConceptTagging.prototype.getTags = function () {
  this.tagListDiv.find(".tag-item").remove();
  this.loading(true);

  $.ajax({
    url: this.urls.dataUrl,
		type: 'GET',
		dataType: 'json',
		context: this,
		success: function (result) {
      this.addTagsUI(result);
      colorCodeTagsOutline(this.tagListDiv, '.tag-item', '.tag');
      this.listeners();
      this.loading(false);
		},
		error: function (xhr, status, error) {
			handleAjaxError(xhr, status, error);
			this.loading(false);
		}
  });
}

/**
 * Toggles loading animation in view
 * @param [boolean] enable / disable loading animation
 *
 * @return [void]
 */
IsoConceptTagging.prototype.loading = function (enable) {
  if(enable)
    spinnerInElement(this.tagListDiv, 'small');
  else
    removeSpinnerInElement(this.tagListDiv);
}

/**
 * Marks a tag as selected in the view
 * @param [Object] raw json structure of a tag item, must contain id, pref_label and description
 *
 * @return [void]
 */
IsoConceptTagging.prototype.select = function (item) {
  this.tagSelected.label.val(item.pref_label);
  this.tagSelected.label.attr("data-id", item.id);
  this.tagSelected.description.val(item.description);
  colorCodeElement(this.tagSelected.description, 'border-bottom', '2px solid '+getColorByTag(item.pref_label));
  colorCodeTagsOutline('#selected_container', '.bg-label');

  this.addButtonUI();
}

/**
 * Adds / removes a tag from an item. Posts to server, handles response and UI update
 * @param [Object] object containing tag data: id, label
 * @param [boolean] adding / removing a tag = true / false
 *
 * @return [void]
 */
IsoConceptTagging.prototype.tagUpdate = function (tag, adding) {
  this.loading(true);
  $.ajax({
    url: (adding == true ? this.urls.addTagUrl : this.urls.removeTagUrl),
    data: {iso_concept: {tag_id: tag.id}},
    type: 'PUT',
    dataType: 'json',
    context: this,
    success: function (result) {
      if(adding){
        this.addTagsUI([tag]);
        colorCodeTagsOutline(this.tagListDiv, '.tag-item', '.tag');
        this.listeners();
      }
      else {
        this.removeTagUI(tag.id)
      }
      this.addButtonUI();
      this.loading(false);
    },
    error: function (xhr, status, error) {
      handleAjaxError(xhr, status, error);
      this.loading(false);
    }
  });
}

/**
 * Updates UI of the add button (disables / enables)
 *
 * @return [void]
 */
IsoConceptTagging.prototype.addButtonUI = function(){
  if(this.tagSelected.label.val() == "Tags" || this.tagExists(this.tagSelected.label.attr("data-id")))
    $("#add_tag").addClass("disabled");
  else
    $("#add_tag").removeClass("disabled");
}

/**
 * Adds a new tag  to the UI
 * @param [Array] one or more tags to add
 *
 * @return [void]
 */
IsoConceptTagging.prototype.addTagsUI = function (tags) {
  var _this = this;
  if(tags.length > 0)
    $("#no-tags-msg").hide();

  if(tags.length > 0){
    $.each(tags, function(i,e){
      _this.tagListDiv.append(_this.tagHTML(e));
    });
  }
}

/**
 * Removes a tag from the UI
 * @param [String] id of the tag to remove
 *
 * @return [void]
 */
IsoConceptTagging.prototype.removeTagUI = function (id) {
  this.tagListDiv.find(".tag-item[data-id='"+id+"']").remove();

  if (this.tagListDiv.find(".tag-item").length == 0)
    $("#no-tags-msg").show();
}

/**
 * Checks if item is already tagged with this tag
 * @param [String] id of the specific tag
 *
 * @return [boolean] true if item already has such a tag
 */
IsoConceptTagging.prototype.tagExists = function(id){
  return this.tagListDiv.find(".tag-item[data-id='"+id+"']").length > 0;
}

/**
 * Sets various listeners in panel
 *
 * @return [void]
 */
IsoConceptTagging.prototype.listeners = function () {
  var _this = this;

  // Tag item click (remove)
  $(".tag-item").off("click").on("click", function(){
    new ConfirmationDialog(function(){
      _this.tagUpdate({id: this.attr("data-id"), label: this.text()}, false);
    }.bind($(this)), {subtitle: "", dangerous: true}).show();
  });

  // Add tag button click
  $("#add_tag").off("click").on("click", function(){
    _this.tagUpdate({id: _this.tagSelected.label.attr("data-id"), label: _this.tagSelected.label.val()}, true);
  });
}

/**
 * Generates HTML code for tag data
 * @param [Object] tag object of tag data containing: id, label
 *
 * @return [String] Formatted HTML
 */
IsoConceptTagging.prototype.tagHTML = function (tag) {
  var html =
    "<div class='tag-item bg-label removable' data-id='"+tag.id+"'>" +
      tag.label +
    "</div>";
  return html;
}
