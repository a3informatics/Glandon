function ImportCrfFilesPanel() {
  this.iip = new ImportItemsPanel(this.status,
    "",
    "");

  var _this = this;

  $('#list_button').click(function() {
    var filename = $('#imports_files_').val();
    if (filename === null){
      displayError("You need to select a file.");
    } else {
      _this.iip.refresh("", filename);
    }
  });

}

ImportCrfFilesPanel.prototype.status = function(operating) {
  $('#list_button').prop('disabled', operating);
}
