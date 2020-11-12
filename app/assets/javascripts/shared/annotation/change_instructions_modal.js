/*
* Change Instructions Modal
* Lists Change Instructions for any item.
*/

$(document).ready(function() {
  var ciModal = new CIListModal();
});

/**
* Change Instructions Modal Constructor
*
* @return [void]
*/
function CIListModal() {
 this.canUserEdit = ciCanEdit;
 this.modal = $("#change-instructions-modal");
 this.htmlHelper = new CIHtml();
 this.ready = false;

 this.table = this.initTable();
 this.setListeners();
}

/**
 ****** General ******
**/


/**
 * Sets event listeners, handlers
 *
 * @return [String] formatted HTML
 */
CIListModal.prototype.setListeners = function () {
  this.modal.on("shown.bs.modal", function() { if (!this.ready) this.loadData(); }.bind(this));

  if (this.canEdit) {
    this.modal.find("#change-instructions-table tbody").on("click", ".icon-trash", this.destroy.bind(this, true));
    this.modal.find("#add-ci-button").on("click", this.createNew.bind(this));
  }
}

/**
 * Builds, executes ajax request. Invokes callback on success
 *
 * @param params [Object] must contain: url, type, callback, withTable (bool)
 * @return [void]
 */
CIListModal.prototype.executeRequest = function (params) {
  this.processing(true, params.withTable);

	$.ajax({
		url: params.url,
		type: params.type,
		dataType: 'json',
		context: this,
		success: function (result) {
      params.callback(result);
		},
		error: function (xhr, status, error) {
      handleAjaxError(xhr, status, error);
      this.processing(false, params.withTable);
		}
	});
}

/**
 * Build load CI index data request, process and add to page
 *
 * @return [void]
 */
CIListModal.prototype.loadData = function () {
  this.executeRequest({
    url: listCIsUrl,
    type: "GET",
    withTable: true,
    callback: function (result) {
      $.each(result.data, function(i, item){
        this.table.row.add(item);
      }.bind(this));

      this.table.draw();
      this.ready = true;
      this.processing(false, true);

    }.bind(this)
  })
}

/**
 * Builds new Change Instructions request, redirects to edit page on success
 *
 * @return [void]
 */
CIListModal.prototype.createNew = function () {
  this.executeRequest({
    url: ciBaseUrl,
    type: "POST",
    withTable: false,
    callback: function (result) {
      location.href = result.edit_path;
    }.bind(this)
  });
}

/**
 * Builds a remove Change Instruction request, handles UI update
 *
 * @param confirm [Boolean] if true, will display a confirmation dialog
 * @return [void]
 */
CIListModal.prototype.destroy = function (confirm, e) {
  if (confirm) {
    new ConfirmationDialog(this.destroy.bind(this, false, e),{dangerous: true})
        .show();
    return;
  }

  var itemRow = this.table.row($(e.target).closest("tr"));

  this.executeRequest({
    url: itemRow.data().destroy_path,
    type: "DELETE",
    withTable: true,
    callback: function (result) {
      displayAlerts(alertSuccess("Change Instruction deleted."));
      itemRow.remove().draw();
      this.processing(false, true);
    }.bind(this)
  });
}


/**
 ****** Support ******
**/


/**
 * Checks if user policy annotation edit allowed and if the instance can be edited
 *
 * @param rowData [Object] CI data object
 * @return [Boolean] edit allowed / not allowed
 */
CIListModal.prototype.canEdit = function(rowData) {
  return this.canUserEdit && rowData.edit;
}

/**
 * Enables / disables processing state
 *
 * @param enable [Boolean] enable / disable - true / false
 * @param withTable [Boolean] true if table processing should be invoked
 * @return [void]
 */
CIListModal.prototype.processing = function(enable, withTable) {
  if (withTable)
    this.table.processing(enable);

  $("#add-ci-button").text(enable ? "Processing..." : "+ Create new");
  $("#add-ci-button").toggleClass("disabled", enable);
}

/**
 * Column definition
 *
 * @return [Array] definition of the single column
 */
CIListModal.prototype.column = function() {
  return [{
      data: "id",
      orderable: false,
      render: function (data, type, row, meta) {
        row.edit = this.canEdit(row);
        return (type == "display" ? this.htmlHelper.changeInstruction(row) : "");
      }.bind(this)
    }];
}

/**
 * Initializes invisible DataTable for change instructions
 *
 * @return [DataTable] initialized DT instance
 */
CIListModal.prototype.initTable = function() {
  return this.modal.find("#change-instructions-table").DataTable({
    "order": [[0, "desc"]],
		"columns": this.column(),
    "lengthChange": false,
		"processing": true,
		"paging": false,
    "searching": false,
    "info": false,
    "scrollY": 450,
    "scrollCollapse": true,
    "autoWidth": false,
		"language": {
			"infoFiltered": "",
			"emptyTable": "No Change Instructions were found.",
			"processing": generateSpinner("small")
		}
  });
}
