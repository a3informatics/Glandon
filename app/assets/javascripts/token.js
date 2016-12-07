var keepToken = false;
window.onbeforeunload = releaseToken;

function releaseToken() {
	if (!keepToken) {
		var token_id = $('#token').val();
		$.ajax({
	    url: '/tokens/' + token_id +  '/release',
	    type: 'POST',
	    contentType: 'application/json'
	  });
  }
}