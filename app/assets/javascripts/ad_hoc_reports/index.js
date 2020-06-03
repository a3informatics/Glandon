refreshOnBackPressed();

$(document).ready(function(){
  var ri = new ReportsIndex();
});

/*
* Ad-Hoc Reports Index
* Only use on Ad Hoc Reports Index page.
*/

/**
* Ad-Hoc Reports Index Constructor
*
* @return [void]
*/
function ReportsIndex() {
  this.tableId = "#main";
  this.selector = new ManagedItemsSelect();

  this.setListners();
}

/**
* Sets event listeners, handlers
*
* @return [void]
*/
ReportsIndex.prototype.setListners = function() {
  $(this.tableId + " tbody").on("click", " a[id^='delete-']", this.removeReport.bind(this, false));
  $(this.tableId + " tbody").on("click", "a[id^='run-'][href='#']", this.runReport.bind(this));
}

/**
* Called when Run report is clicked. Opens items selector and sets callback handle
*
* @param e [Event] click event trigerring this action
* @return [void]
*/
ReportsIndex.prototype.runReport = function(e) {
  var reportId = this.getReportId(e);

  this.selector.type = $("#paramtype-" + reportId).val();
  this.selector.setDescription($("#paramdescription-" + reportId).val());
  this.selector.callback = function(selectedId) {
    location.href = this.buildReportUrl(reportId, selectedId);
  }.bind(this)

  this.selector.show();
}

/**
* Shows confirmation for removal - if confirmed, clicks the delete report hidden link
*
* @param confirmed [Boolean] false - show confirmation, true - bypass confirmation
* @param e [Event] click event trigerring this action
* @return [void]
*/
ReportsIndex.prototype.removeReport = function(confirmed, e) {
  if (!confirmed) {
    new ConfirmationDialog(this.removeReport.bind(this, true, e), {dangerous: true}).show();
    return;
  }

  $('#delete_link_' + this.getReportId(e)).click();
}

/**
* Shows confirmation for removal - if confirmed, clicks the delete report hidden link
*
* @param reportId [String] id of the ad-hoc report
* @param selectedId [String] id of the target item - from the items selector
* @return [String URL] URL for running the report, with params
*/
ReportsIndex.prototype.buildReportUrl = function(reportId, selectedId) {
  return startParamReportUrl
    .replace("reportId", reportId)
    .replace("reportParam", selectedId);
}

/**
* Extracts report id string from click event
*
* @param event [Event] click event trigerring report action
* @return [String] id of the report
*/
ReportsIndex.prototype.getReportId = function(event) {
  return $(event.currentTarget).attr("id").split('-')[1];
}
