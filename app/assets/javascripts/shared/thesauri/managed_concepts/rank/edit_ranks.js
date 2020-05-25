/*
* Rank Items Modal
* Modal for ranking child items of a Code List.
*/

/**
* Rank Items Modal Constructor
*
* @return [void]
*/
function RankModal(lockCallback) {
 this.modal = $("#rank-items-modal");
 this.errorDiv = this.modal.find(".errors");
 this.rankTable = this.initTable();
 this.lockCallback = lockCallback;
 this.data = {};


 this.setListeners();
}


/**
 ****** General ******
**/


/**
 * Draws table, re-loads data
 *
 * @return [void]
 */
RankModal.prototype.onShow = function() {
  this.loadData();
}

/**
 * Hides modal
 *
 * @return [void]
 */
RankModal.prototype.dismiss = function() {
  this.modal.modal("hide");
}

/**
 * Draws table, re-loads data
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
 * Sets event listeners, handlers
 *
 * @return [void]
 */
RankModal.prototype.onRankInteract = function(ev) {
  switch(ev.type) {
    // Starts editing
    case "focusin":
      this.updateRankHTML($(ev.target), "editing")
      this.focusAndSelect(".rank-input");
      break;
    // Finish editing
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
RankModal.prototype.autoRank = function() {
  var count = 1,
      self = this;

  this.rankTable.rows({order: 'applied'}).every(function(el, i, ar){
    self.updateRank(this, count++).invalidate().draw();
  });
}

/**
 * Remove Rank
 *
 * @param confirmRequired [Boolean] true if a confirmation dialog should appear
 * @return [void]
 */
RankModal.prototype.save = function() {
  var rankData  = this.getDataArray();

  if(_.isEmpty(rankData))
    return;

  this.executeRequest({
    url: rankSaveUrl,
    data: JSON.stringify({ managed_concept: {children_ranks: this.getDataArray()} }),
    type: "PUT",
    callback: function(r) {
      this.data = {};
      displayAlertsInElement(alertSuccess("Ranks saved."), this.modal.find(".errors"));
    }.bind(this)
  })
}

/**
 * Close Rank Modal
 *
 * @param confirmRequired [Boolean] true if a confirmation dialog should appear
 * @return [void]
 */
RankModal.prototype.close = function(confirmRequired) {
  if (!_.isEmpty(this.data) && confirmRequired) {
    new ConfirmationDialog(this.close.bind(this, false), {
      dangerous: true,
      title: "Are you sure you want to close this dialog?",
      subtitle: "You have unsaved changes."
    }).show();

    return;
  }

  this.modal.modal("hide");
}

/**
 * Remove Rank
 *
 * @param confirmRequired [Boolean] true if a confirmation dialog should appear
 * @return [void]
 */
RankModal.prototype.removeRank = function(confirmRequired) {
  if (confirmRequired) {
    new ConfirmationDialog(this.removeRank.bind(this, false), {dangerous: true}).show();
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
 * Sets event listeners, handlers
 *
 * @return [void]
 */
RankModal.prototype.setListeners = function() {
  this.modal.on("show.bs.modal", this.loadData.bind(this));
  this.modal.on("shown.bs.modal", this.rankTable.columns.adjust);
  this.modal.on("focusin", "#rank-table tbody td .content-editable", this.onRankInteract.bind(this));
  this.modal.on("focusout keydown", "#rank-table tbody td .rank-input", this.onRankInteract.bind(this));
  this.modal.on("click", "#auto-rank-btn", this.autoRank.bind(this));
  this.modal.on("click", "#submit-button", this.save.bind(this));
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
 * Sets event listeners, handlers
 *
 * @return [void]
 */
RankModal.prototype.focusAndSelect = function(el) {
  setTimeout(function() {
    $(el).get(0).focus();
    $(el).select();
  }, 0)
}

/**
 * Sets event listeners, handlers
 *
 * @return [void]
 */
RankModal.prototype.getDataArray = function() {
  return Object.keys(this.data).map(function(key) {
    return { cli_id: key, rank: this.data[key] }
  }.bind(this));
}


/**
 * Sets event listeners, handlers
 *
 * @return [void]
 */
RankModal.prototype.updateRank = function(row, value) {
  row.data().rank = value;
  this.data[row.data().id] = value;
  return row;
}


/**
 * Rank table columns definitions
 *
 * @return [Array] array of column definitions
 */
RankModal.prototype.updateRankHTML = function(el, type) {
  switch(type){
    case "display":
      el.closest("tr").removeClass("editing");
      el.parent().empty().append(this.rankHTML(el.val(), type));
      break;
    case "editing":
      el.closest("tr").addClass("editing");
      el.parent().empty().append(this.rankHTML(el.html(), type));
      break;
  }
  this.rankTable.columns.adjust();
}

/**
 * Rank table columns definitions
 *
 * @return [Array] array of column definitions
 */
RankModal.prototype.rankHTML = function(rank, type) {
  switch(type){
    case "display":
      return "<span tabindex='0' class='content-editable with-icon font-regular text-link text-normal no-break'>" + rank + "</span>";
    case "editing":
      return "<input type='number' class='rank-input text-normal' step='1' style='width: 40px;' value='"+ rank +"'/>";
  }
}

/**
 * Exectute ajax request, with callback exec on success
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
      this.processing(false);
		},
		error: function (xhr, status, error) {
      handleAjaxError(xhr, status, error, this.errorDiv);
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
    scrollCollapse: true,
    info: false,
    language: {
      "infoFiltered": "",
      "emptyTable": "No child items.",
      "processing": generateSpinner("small")
    },
  })
}
