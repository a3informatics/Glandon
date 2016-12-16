$(document).ready(function () {

  validatorDefaults ();
  $('#placeholder_form').validate({
    rules: {
        "form[identifier]": { required: true, identifier: true },
        "form[label]": { required: true, label: true },
        "form[freeText]": { required: true, markdown: true }
    }
  });

  var markdownElement = null;
  var genericMarkdownElement = document.getElementById("generic_markdown");

  /*
  * Completion and notes focus functions
  */
  $( "#form_freeText" ).focus(function() {
    markdownElement = this;
    getMarkdown(genericMarkdownElement, this.value, setMarkdown); 
  });

  /*
  * Functions to handle completion instruction preview
  */
  $('#markdown_preview').click(function() {
    if (markdownElement == null) {
      var html = alertWarning("You need to select a form field.");
      displayAlerts(html);
    } else {
      getMarkdown(genericMarkdownElement, markdownElement.value, setMarkdown);  
    }
  });

  function setMarkdown(element, text) {
    element.innerHTML = text;
  }

});