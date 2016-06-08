$(document).ready(function () {

  $('#main').DataTable({
      columnDefs: [ ]
  } );

});

function getMarkdown(element, text) {
  if (text != "") {
    $.ajax({
      url: "/forms/markdown",
      data: {
        "markdown": text
      },
      dataType: 'json',
      error: function (xhr, status, error) {
        var html = alertError("An error has occurred loading the markdown.");
        displayAlerts(html);
      },
      success: function(result){
        var html_text = $.parseJSON(JSON.stringify(result));
        element.innerHTML = html_text.result;
      }
    });
  } else {
    element.innerHTML = "";    
  }
}