var keepToken = false;
window.onbeforeunload = pageUnload;

function pageUnload() {
	pageUnloadAction();
	if (!keepToken) {
		var token_id = $('#token').val();
		$.ajax({
	    url: '/tokens/' + token_id +  '/release',
	    type: 'POST',
	    contentType: 'application/json'
	  });
  }
}