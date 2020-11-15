/*
* Edit Properties Modal
*/


/**
* Edit Properties Constructor
*
* @param item [Object] Must contain fields:
          identifier, notation. preferred_term, synonym, definition, id, (parent_id, context_id in relevant type)
* @param type [String] item type. Can be: ManagedConcept, UnmanagedConcept
* @param callback [Function] is called on item update success, optional
* @return [Object Instance] this instance, for chaining purposes
*/
function EditProperties(item, modalId, type, callback) {
  this.item = item;
  this.type = type;
  this.callback = callback;
  this.els = {
    modal: '#edit-properties-'+modalId,
    save: '#submit-button',
    tags: '#edit-tags-button',
    title: '.title-identifier',
    notation: 'input[name="notation"]',
    preferred_term: 'input[name="preferred_term"]',
    synonym: 'input[name="synonym"]',
    definition: 'textarea[name="definition"]'
  };

  return this;
}

/**
 * Init and open modal
 *
 * @return [void]
 */
EditProperties.prototype.show = function() {
  this.initModal();
  $(this.els.modal).modal('show');
};

/**
 * Initializes the fields in the modal, save event
 *
 * @return [void]
 */
EditProperties.prototype.initModal = function() {
  $(this.els.modal).find(this.els.title).text(this.item.identifier);
  $(this.els.modal).find(this.els.notation).val(this.item.notation);
  $(this.els.modal).find(this.els.preferred_term).val(this.item.preferred_term);
  $(this.els.modal).find(this.els.synonym).val(this.item.synonym);
  $(this.els.modal).find(this.els.definition).val(this.item.definition);

  $(this.els.modal).find(this.els.save).off("click").on("click", this.save.bind(this));
  $(this.els.modal).find(this.els.tags).off("click").on("click", this.editTagsHandler.bind(this));
};

/**
 * Ajax save
 *
 * @return [void]
 */
EditProperties.prototype.save = function() {
  var params = this.requestParams();

  if (params == null)
    $(this.els.modal).modal('hide');
  else {
    this.loading(true);

    $.ajax({
      url: params.url,
      type: params.type,
      data: params.data,
      context: this,
      success: function(result){
        this.item = this.mergeResultItem(this.item, result.data[0]);
        this.loading(false);

        if (this.callback != null) {
          $(this.els.modal).modal('hide');
          this.callback(this.item);
        }
        else
          location.reload();
      },
      error: function(xhr,status,error){
        this.loading(false);
        handleAjaxError(xhr, status, error);
      }
    })
  }
};

EditProperties.prototype.requestParams = function() {
  var changedData = this.getChangedData();

  if(Object.keys(changedData).length == 0)
    return null;

  var params = {};

  switch (this.type) {
    case "UnmanagedConcept":
      changedData["parent_id"] = this.item.parent_id;
      params["type"] = "PATCH";
      params["url"] = baseUMCUrl.replace("id", this.item.id);
      params["data"] = {edit: changedData};
      break;
    case "ManagedConcept":
      params["type"] = "PATCH";
      params["url"] = baseMCUrl.replace("id", this.item.id);
      params["data"] = {edit: changedData};
      break;
  }

  return params;
}

/**
 * Collects changed values
 *
 * @return [Object] data name values that have been changed
 */
EditProperties.prototype.getChangedData = function() {
  var _this = this;

  var data = {};
  $(this.els.modal).find("input, textarea").each(function(e){
    if($(this).val() != _this.item[$(this).attr("name")])
      data[$(this).attr("name")] = $(this).val();
  });

  return data;
};

/**
 * Handles click on Edit tags button
 *
 * @return [void]
 */
EditProperties.prototype.editTagsHandler = function() {
  switch (this.type) {
    case "ManagedConcept":
      window.open(baseMCTagsUrl
        .replace('itemid', this.item.id), '_blank');
      break;
    case "UnmanagedConcept":
      window.open(baseUMCTagsUrl
        .replace('itemid', this.item.id)
        .replace('prnt', this.item.parent_id)
        .replace('ctxt', this.item.context_id), '_blank');
      break;
  }
};

/**
 * Merges ajax results with current item object
 *
 * @return [Object] data name values that have been changed
 */
EditProperties.prototype.mergeResultItem = function(item, result) {
  item.notation = result.notation;
  item.preferred_term = result.preferred_term;
  item.definition = result.definition;
  item.synonym = result.synonym;

  return item;
};

/**
 * Enables / disables loading state of modal
 *
 * @param enable [Boolean] enable/disable loading ~ true/false
 * @return [void]
 */
EditProperties.prototype.loading = function(enable) {
  if (enable) {
    $(this.els.modal).find(this.els.save).addClass("disabled");
    $(this.els.modal).find(this.els.save).text("Saving...");
  }
  else {
    $(this.els.modal).find(this.els.save).removeClass("disabled");
    $(this.els.modal).find(this.els.save).text("Save changes");
  }
};
