$(document).ready(function() {
  new ImportShow();
});

/*
************ Import Show ************
*/


/**
* Import Show Constructor
*
* @return [void]
*/
function ImportShow() {
  this.dataUrl = importDataUrl;
  this.refreshRate = 10000;

  this.refreshId = setInterval(this.refreshData.bind(this), this.refreshRate);
  this.refreshData();
}


/*
************ General ************
*/


/**
 * Posts data to server, runs callbacks
 *
 * @param params [Object] request parameters, must contain url, type, data, callback, withLoading
 * @return [void]
 */
ImportShow.prototype.executeRequest = function (params) {
	$.ajax({
		url: params.url,
		data: params.data,
		type: params.type,
    cache: false,
		dataType: 'json',
		context: this,
		success: function(result){
			params.callback(result);
		},
		error: function (xhr, status, error) {
			handleAjaxError(xhr, status, error);
		}
	});
}

/**
* Builds a request to reload data
*
* @return [void]
*/
ImportShow.prototype.refreshData = function() {
  this.clear();

  this.executeRequest({
    url: this.dataUrl,
    type: "GET",
    data: {},
    callback: function(result) {
      if (result.data.import.complete)
        clearInterval(this.refreshId);

      this.renderData(result.data);
    }.bind(this)
  });
}

/**
* Fills in the data fields with server-fetched data
*
* @return [void]
*/
ImportShow.prototype.renderData = function(data) {
  // Import
  $(".job-description").text(data.job.description);
  $(".job-started-at").text(data.job.started);

  if (data.import.complete) {
    $("#import-info").show();
    $("#import-identifier").text(data.import.identifier);
    $("#import-owner").text(data.import.owner);
    $("#import-success").html(trueFalseIcon(data.import.success));
    if (data.import.success){
      $("#import-info #import-alerts").append(alertSuccess("No errors were detected with the import."));
      if (data.import.auto_load)
        $("#import-info #import-alerts").append("<a href='"+data.import.success_path+"' class='btn medium light'>Show imported item(s)</a>");
      else
        $("#import-info #import-alerts").append(alertWarning("Auto load was not set so the item was not imported."))
    }
    else
      $("#import-info #import-alerts").append(alertError("Errors were detected during the processing of the import file. See the error table."));
  }
  // Job
  else {
    $("#import-job").show();
    spinnerInElement("#import-job #job-loading-wrap", "small");
    $("#job-status").text(data.job.status);
    $("#job-percentage").text(data.job.percentage);
  }
  // Errors
  if (data.job.complete && !data.import.success) {
    $("#import-errors").show();
    $.each(data.errors, function(i, error){
      $("#errors tbody").append("<tr><td>" + (i+1) + "</td><td>" + error + "</td></tr>");
    });
  }
}


/**
* Clears data fields, hides panels
*
* @return [void]
*/
ImportShow.prototype.clear = function() {
  $("#import-errors #errors tbody").empty();
  $("#import-info #import-alerts").empty();
  removeSpinnerInElement($("#import-job #job-loading-wrap"));
  $("#import-info, #import-job, #import-errors").hide();
}
