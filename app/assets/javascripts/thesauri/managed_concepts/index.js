$(document).ready( function() {
  var columns = [
    {"data" : "owner"},
    {"data" : "identifier"},
    {"data" : "label"},
    {"data" : "notation"},
  ];

  var ip = new IndexPanel(indexCLUrl, "managed_concept", columns, 1000, "all");
  var tnb = new NewButton(createCLUrl, createCallback);

  function createCallback(data) {
    window.location.href = data.history_path;
  }

});
