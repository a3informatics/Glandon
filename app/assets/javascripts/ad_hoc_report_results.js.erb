$(document).ready(function() {

	var resultsLoaded = false;
	var reportId = document.getElementById("report_id").value;

  var resultsTable = $('#results').DataTable( {
		"processing": true,
		"pageLength": pageLength,
		"lengthMenu": pageSettings,
		"language": {
			"infoFiltered": "",
			"emptyTable": "No data.",
			"processing": generateSpinner("small")
		},
	});

	processing(true);
  getStatus();

  function statusTimeout() {
    setTimeout(function(){
      getStatus();
    }, 10000);
 	}

  function getResults() {
		if (!resultsLoaded) {
			resultsTable.ajax.url("/ad_hoc_reports/" + reportId + "/run_results").load();
			processing(true, "Loading results");
	    resultsLoaded = true;
    }
  }

  function getStatus() {
	  $.ajax({
	    url: "/ad_hoc_reports/" + reportId + "/run_progress",
	    type: "GET",
	    dataType: 'json',
	    error: function (xhr, status, error) {
	      displayError("An error has occurred obtaining the run status.");
	    },
	    success: function(result){
	      if (!result.running) {
					processing(false);
	      	getResults();
	      } else {
	      	statusTimeout();
					processing(true, "Database query running");
	      }
	    }
	  });
	}

	function processing(enable, text){
		if (text != null)
			$("#results_processing").html(generateSpinnerWText("small", text));
		resultsTable.processing(enable);
	}

});
