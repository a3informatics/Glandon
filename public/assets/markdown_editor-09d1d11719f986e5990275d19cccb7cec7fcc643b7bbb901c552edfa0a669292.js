$(document).ready(function () {

  validatorDefaults ();
  $('#main_form').validate({
    rules: { "Raw Markdown": { required: false, markdown: true }},
    submitHandler: function(form) {
      return false;
    }
  });

  var markdownElement = document.getElementById("raw_markdown");
  var genericMarkdownElement = document.getElementById("generic_markdown");

  /*
  * Completion and notes focus functions
  */
  $( "#raw_markdown" ).focus(function() {
    getMarkdown(genericMarkdownElement, this.value, setMarkdown); 
  });

  /*
  * Functions to handle completion instruction preview
  */
  $('#markdown_preview').click(function() {
    getMarkdown(genericMarkdownElement, markdownElement.value, setMarkdown);  
  });

  function setMarkdown(element, text) {
    element.innerHTML = text;
  }

});
