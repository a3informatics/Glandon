$(document).ready(function() {

	var resultsLoaded = false;
	var reportId = document.getElementById("report_id").value;
  var resultsTable;
  
  spAddSpinner("#running");
  getStatus();

  function statusTimeout() {
    setTimeout(function(){
      getStatus();
    }, 10000);
 	}
 
  function getResults() {
  	if (resultsLoaded) {
  		resultsTable.ajax.reload();
  	} else {
	  	resultsTable = $('#results').DataTable( {
	      "ajax": {
	        "url": "/ad_hoc_reports/" + reportId + "/run_results",
	        "dataSrc": "data"  
	      },
    		"pageLength": pageLength,
    		"lengthMenu": pageSettings
	    });
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
	      	getResults();
	      	spRemoveSpinner("#running");
	      } else {
	      	statusTimeout();
	      	// Just load the table once to set up page nicely.
	      	if (!resultsLoaded) {
	      		getResults();
	      	}
	      }
	    }
	  });
	}

});
