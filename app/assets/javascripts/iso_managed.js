$(document).ready( function() {

  $('#main').DataTable({
      columnDefs: [ ]
  } );	

  var markdownElement = null;
  var genericMarkdownElement = document.getElementById("generic_markdown");

  /*
  * Completion and notes focus functions
  */
  $( "#iso_managed_changeDescription" ).focus(function() {
    markdownElement = this;
    getMarkdown(genericMarkdownElement, this.value); 
  });

  $( "#iso_managed_explanatoryComment" ).focus(function() {
    markdownElement = this;
    getMarkdown(genericMarkdownElement, this.value);  
  });

  $( "#iso_managed_origin" ).focus(function() {
    markdownElement = this;
    getMarkdown(genericMarkdownElement, this.value);  
  });

  /*
  * Functions to handle completion instruction preview
  */
  $('#markdown_preview').click(function() {
    if (markdownElement == null) {
      var html = alertWarning("You need to select a form field.");
      displayAlerts(html);
    } else {
      getMarkdown(genericMarkdownElement, markdownElement.value);  
    }
  });
		
});
