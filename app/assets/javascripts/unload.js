var keepToken = false;
window.onbeforeunload = pageUnload;

function pageUnload() {
	pageUnloadAction();
	if (!keepToken) {
		var token_id
		// Allows for upto eight tokens
		for (var i=1; i<=8; i++) {
			token_id = $('#token_' + i).val();
			if (token_id !== "" && token_id !== undefined) {
				$.ajax({
			    url: '/tokens/' + token_id +  '/release',
			    type: 'POST',
			    dataType: 'json',
			  });
			} else {
				break;
			}
		}
  }
}