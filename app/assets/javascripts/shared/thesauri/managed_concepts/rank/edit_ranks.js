/*
* Rank Items Modal
* Modal for ranking child items of a Code List.
*/

/**
* Rank Items Modal Constructor
*
* @param lockCallback [Function] callback to edit lock extend
* @return [void]
*/
function RankModal(lockCallback) {
 this.modal = $("#rank-items-modal");
 this.rankTable = this.initTable();
 this.lockCallback = lockCallback;
 this.data = {};

 this.setListeners();
}


/**
 ****** General ******
**/


/**
 * Hides modal
 *
 * @return [void]
 */
RankModal.prototype.dismiss = function() {
  this.modal.modal("hide");
}

/**
 * Clears data, re-loads data and re-populates table
 *
 * @return [void]
 */
RankModal.prototype.loadData = function() {
  this.rankTable.clear().draw();
  this.data = {};

  this.executeRequest({
    url: rankedChildrenUrl,
    type: "GET",
    data: {},
    callback: function(data) {
      $.each(data.data, function(i, item){
        this.rankTable.row.add(item);
      }.bind(this))

      this.rankTable.draw();
      this.rankTable.columns.adjust();
    }.bind(this)
  });

}

/**
 * Saves rank data, clears local data and shows message on success
 * Does nothing when local data empty
 *
 * @return [void]
 */
RankModal.prototype.save = function() {
  var rankData  = this.getDataArray();

  if(_.isEmpty(rankData))
    return;

  this.executeRequest({
    url: rankSaveUrl,
    data: JSON.stringify({
      managed_concept: {
        children_ranks: this.getDataArray()
      }
    }),
    type: "PUT",
    callback: function(r) {
      this.data = {};
      displayAlerts(alertSuccess("Ranks saved."));
    }.bind(this)
  })
}

/**
 * Closes Rank Modal, shows confirmation dialog if rank data not saved
 *
 * @param confirmRequired [Boolean] true if a confirmation dialog should appear
 * @return [void]
 */
RankModal.prototype.close = function(confirmRequired) {
  if (confirmRequired && this.hasUnsavedData()) {

    new ConfirmationDialog(this.close.bind(this, false), {
      dangerous: true,
      title: "Are you sure you want to close this dialog?",
      subtitle: "You have unsaved changes."
    }).show();

    return;
  }

  this.dismiss();
}

/**
 * Remove Rank from Code List
 *
 * @param confirmRequired [Boolean] true if a user confirmation required
 * @return [void]
 */
RankModal.prototype.removeRank = function(confirmRequired) {
  if (confirmRequired) {

    new ConfirmationDialog(this.removeRank.bind(this, false), {
      dangerous: true,
      subtitle: "All rank data of this Code List will be deleted."
    }).show();
    return;

  }

  this.executeRequest({
    url: rankRemoveUrl,
    data: {},
    type: "DELETE",
    callback: function(r) {
      this.dismiss();
      location.reload();
    }.bind(this)
  })
}

/**
 * Assigns ranks automatically to rows, as sorted, re-draws table
 *
 * @return [void]
 */
RankModal.prototype.autoRank = function() {
  var count = 1,
      self = this;

  this.rankTable.rows({order: 'applied'}).every(function(el, i, ar){
    self.updateRank(this, count++);
  });

  this.rankTable.rows().invalidate().draw();
}

/**
 * Rank field interaction (focus -in, -out, key-press), handles UI response
 *
 * @param ev [Event] trigerring event
 * @return [void]
 */
RankModal.prototype.onRankInteract = function(ev) {
  switch(ev.type) {
    // Start editing rank
    case "focusin":
      this.updateRankHTML($(ev.target), "editing")
      this.focusAndSelect(".rank-input");
      break;
    // Finish editing rank
    case "focusout":
      var rank = parseInt($(ev.target).val());
      this.updateRank(this.rankTable.row("tr.editing"), rank);
      this.updateRankHTML($(ev.target), "display");
      break;
    // Finish editing with ESC or ENTER key
    case "keydown":
      if((ev.keyCode || ev.which) == 13 || (ev.keyCode || ev.which) == 27) {
        ev.stopPropagation();
        $(ev.target).blur();
      }
      break;
  }
}

/**
 * Sets event listeners, handlers
 *
 * @return [void]
 */
RankModal.prototype.setListeners = function() {
  // Modal
  this.modal.on("show.bs.modal", this.loadData.bind(this));
  this.modal.on("shown.bs.modal", this.rankTable.columns.adjust);
  // Rank fields
  this.modal.on("focusin", "#rank-table tbody td .content-editable", this.onRankInteract.bind(this));
  this.modal.on("focusout keydown", "#rank-table tbody td .rank-input", this.onRankInteract.bind(this));
  // Buttons
  this.modal.on("click", "#auto-rank-btn",this.autoRank.bind(this));
  this.modal.on("click", "#save-rank-button", this.save.bind(this));
  this.modal.on("click", "#remove-rank-button", this.removeRank.bind(this, true));
  this.modal.on("click", "#close-modal-button", this.close.bind(this, true));
  this.modal.on("click", "#rank-help", function() { new InformationDialog({div: $("#information-dialog-rank")}).show(); })
}


/**
 ****** Support ******
**/


/**
 * Enables or disables processing on the modal
 *
 * @param enable [Boolean] Processing enable / disable == true / false
 * @return [void]
 */
RankModal.prototype.processing = function(enable) {
  this.rankTable.processing(enable);
  this.modal.find(".btn, .clickable")
            .not("#close-modal-button")
            .toggleClass("disabled", enable);
}

/**
 * Focuses on and selects text in an element
 *
 * @param element [String] JQuery element selector
 * @return [void]
 */
RankModal.prototype.focusAndSelect = function(element) {
  setTimeout(function() {
    $(element).get(0).focus();
    $(element).select();
  }, 0)
}

/**
 * Returns local rank data object as array of objects with params cli_id and rank
 *
 * @return [Array] array of local rank data objects
 */
RankModal.prototype.getDataArray = function() {
  return Object.keys(this.data).map(function(key) {
    return {
      cli_id: key,
      rank: this.data[key]
    }
  }.bind(this));
}

/**
 * Checks if any unsaved local data present
 *
 * @return [Boolean] local unsaved data presence
 */
RankModal.prototype.hasUnsavedData = function() {
  return !_.isEmpty(this.data);
}

/**
 * Updates rank value in a table's row data object, and local rank data
 *
 * @param row [DataTable Row] code list item row reference
 * @param rank [Integer] new rank value
 * @return [DataTable Row] updated row reference
 */
RankModal.prototype.updateRank = function(row, rank) {
  row.data().rank = rank;
  this.data[row.data().id] = rank;
  return row;
}

/**
 * Updates the HTML of a Rank cell to reflect interaction state
 *
 * @param element [JQuery Element] target element
 * @param type [String] specifies, whether HTML should be changed to "display" or "editing" type
 * @return [void]
 */
RankModal.prototype.updateRankHTML = function(element, type) {
  switch(type){
    case "display":
      element.closest("tr").removeClass("editing");
      element.parent().empty().append(this.rankHTML(element.val(), type));
      setTimeout(this.rankTable.columns.adjust, 0);
      break;
    case "editing":
      element.closest("tr").addClass("editing");
      element.parent().empty().append(this.rankHTML(element.html(), type));
      break;
  }
}

/**
 * Returns raw HTML of a Rank cell to reflect interaction state (input or span el)
 *
 * @param rank [Integer] current rank value of the cell
 * @param type [String] specifies, whether HTML should be for "display" or "editing"
 * @return [String] rank cell HTML (input or span element)
 */
RankModal.prototype.rankHTML = function(rank, type) {
  switch(type){
    case "display":
      return "<span tabindex='0' class='content-editable with-icon font-regular text-link text-normal no-break clickable'>" + rank + "</span>";
    case "editing":
      return "<input type='number' class='rank-input text-normal' step='1' style='width: 50px;' value='"+ rank +"'/>";
  }
}

/**
 * Exectute ajax request, with params callback and lock callback exec on success
 *
 * @param params [Object] must contain url, data, type, callback
 * @return [void]
 */
RankModal.prototype.executeRequest = function(params) {
  this.processing(true);

  $.ajax({
    url: params.url,
    type: params.type,
    data: params.data,
    dataType: "json",
    contentType: "application/json",
    context: this,
    success: function (result) {
			params.callback(result);
      this.lockCallback();
      this.processing(false);
		},
		error: function (xhr, status, error) {
      handleAjaxError(xhr, status, error);
			this.processing(false);
		}
  })
}

/**
 * Rank table columns definitions
 *
 * @return [Array] array of column definitions
 */
RankModal.prototype.columns = function() {
  return [
    { data: "rank", "render": function(data, type, row, meta) {
        return type === "display" ?
          this.rankHTML(data, type) : data;
    }.bind(this)},
    { data: "identifier" },
    { data: "notation" },
    { data: "preferred_term" },
    { data: "synonym" },
    { data: "definition" },
    { data: "tags", "render": function (data, type, row, meta) {
        return type === "display" ? colorCodeTagsBadge(data) : data;
    }},
  ]
}

/**
 * Initializes the Rank table
 *
 * @return [DataTable Instance] initialized DataTable
 */
RankModal.prototype.initTable = function() {
  return this.modal.find("#rank-table").DataTable({
    pageLength: pageLength,
    lengthMenu: pageSettings,
    order: [[ 1, 'desc' ]],
    columns: this.columns(),
    processing: true,
    paging: false,
    scrollY: 500,
    scrollX: true,
    scrollCollapse: true,
    info: false,
    language: {
      "infoFiltered": "",
      "emptyTable": "No child items.",
      "processing": generateSpinner("small")
    },
  })
}
