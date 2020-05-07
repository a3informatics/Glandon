$(document).ready(function() {

	var iaControl = new ImpactAnalysis(url, id, namespace, maxLevel, finishedCallBack);
  
	spAddSpinner("#processing");
	iaControl.start();

	$('#close').click(function() {
    history.back();
  });

	function finishedCallBack() {
		spRemoveSpinner("#processing");
	}

});




