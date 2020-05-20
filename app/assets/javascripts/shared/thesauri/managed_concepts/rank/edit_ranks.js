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
  this.rankTable.columns.adjust();
  this.loadData();
}

/**
 * Draws table, re-loads data
 *
 * @return [void]
 */
RankModal.prototype.loadData = function() {
  this.rankTable.clear().draw();
  //
  // this.executeRequest({
  //   url: this.dataUrl,
  //   type: "GET",
  //   data: {},
  //   callback: function(data) {
  //     $.each(data.data, function(i, item){
  //       this.rankTable.row.add(item);
  //     }.bind(this))
  //
  //     this.rankTable.draw();
  //   }.bind(this)
  // });

  var data = {"data":[{"rank": 0, "identifier":"S000288","notation":"sdasfsfr","preferred_term":"Asdasdasd","synonym":"","tags":"","extensible":false,"definition":"Not Set","delete":false,"single_parent":true,"uri":"http://www.s-cubed.dk/SN000320/V1#SN000320_S000288","id":"aHR0cDovL3d3dy5zLWN1YmVkLmRrL1NOMDAwMzIwL1YxI1NOMDAwMzIwX1MwMDAyODg=","indicators":{"annotations":{"change_notes":0,"change_instructions":0}},"edit_path":"","delete_path":"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5zLWN1YmVkLmRrL1NOMDAwMzIwL1YxI1NOMDAwMzIwX1MwMDAyODg=?unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5zLWN1YmVkLmRrL1NOMDAwMzIwL1YxI1NOMDAwMzIw"},{"rank": 1, "identifier":"S000292","notation":"Not Set","preferred_term":"Not Set","synonym":"","tags":"","extensible":false,"definition":"Not Set","delete":false,"single_parent":true,"uri":"http://www.s-cubed.dk/SN000320/V1#SN000320_S000292","id":"aHR0cDovL3d3dy5zLWN1YmVkLmRrL1NOMDAwMzIwL1YxI1NOMDAwMzIwX1MwMDAyOTI=","indicators":{"annotations":{"change_notes":0,"change_instructions":0}},"edit_path":"","delete_path":"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5zLWN1YmVkLmRrL1NOMDAwMzIwL1YxI1NOMDAwMzIwX1MwMDAyOTI=?unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5zLWN1YmVkLmRrL1NOMDAwMzIwL1YxI1NOMDAwMzIw"}]}

  $.each(data.data, function(i, item){
      this.rankTable.row.add(item);
  }.bind(this))
  this.rankTable.draw();

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
 * Sets event listeners, handlers
 *
 * @return [void]
 */
RankModal.prototype.setListeners = function() {
  this.modal.on("shown.bs.modal", this.onShow.bind(this));
  this.modal.on("focusin", "#rank-table tbody td .content-editable", this.onRankInteract.bind(this));
  this.modal.on("focusout keydown", "#rank-table tbody td .rank-input", this.onRankInteract.bind(this));
  this.modal.on("click", "#auto-rank-btn", this.autoRank.bind(this));
}

/**
 ****** Support ******
**/

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
RankModal.prototype.updateRank = function(row, value) {
  row.data().rank = value;
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
  this.rankTable.draw();
}

/**
 * Rank table columns definitions
 *
 * @return [Array] array of column definitions
 */
RankModal.prototype.rankHTML = function(rank, type) {
  switch(type){
    case "display":
      return "<span tabindex='0' class='content-editable with-icon font-regular text-link'>" + rank + "</span>";
    case "editing":
      return "<input type='number' class='rank-input' step='1' style='width: 40px;' value='"+ rank +"'/>";
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
    context: this,
    success: function (result) {
			this.callback(result);
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
    {"data": "tags", "render": function (data, type, row, meta) {
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
    order: [[ 1, 'asc' ]],
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
