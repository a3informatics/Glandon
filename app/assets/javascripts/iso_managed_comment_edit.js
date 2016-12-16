$(document).ready( function() {

  validatorDefaults ();
  $('#main_form').validate({
    rules: {  "iso_managed[changeDescription]": { required: false, markdown: true },
              "iso_managed[explanatoryComment]": { required: false, markdown: true },
              "iso_managed[origin]": { required: false, markdown: true }
    },
    submitHandler: function(form) {
      return true;
    }
  });

  var markdownElement = null;
  var genericMarkdownElement = document.getElementById("generic_markdown");

  /*
  * Completion and notes focus functions
  */
  $( "#iso_managed_changeDescription" ).focus(function() {
    markdownElement = this;
    getMarkdown(this.value, setMarkdown); 
  });

  $( "#iso_managed_explanatoryComment" ).focus(function() {
    markdownElement = this;
    getMarkdown(this.value, setMarkdown); 
  });

  $( "#iso_managed_origin" ).focus(function() {
    markdownElement = this;
    getMarkdown(this.value, setMarkdown); 
  });

  /*
  * Functions to handle completion instruction preview
  */
  $('#markdown_preview').click(function() {
    if (markdownElement == null) {
      var html = alertWarning("You need to select a form field.");
      displayAlerts(html);
    } else {
      getMarkdown(markdownElement.value, setMarkdown);  
    }
  });

  function setMarkdown(text) {
    genericMarkdownElement.innerHTML = text;
  }
		
});
