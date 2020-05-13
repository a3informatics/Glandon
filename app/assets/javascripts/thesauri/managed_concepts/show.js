refreshOnBackPressed();

$(document).ready( function() {
  if (canEdit) {
    var extensionCreate = new ExtensionCreate(isExtended, isExtending);
    var thesauriSelect = new ThesauriSelect(tcId, extensionCreate.createExtensionCallback.bind(extensionCreate));
    var subsetsIndex = new IndexSubsets(tcId);
    
    var startExtend = function(){
      thesauriSelect.setCallback(extensionCreate.createExtensionCallback.bind(extensionCreate));
      thesauriSelect.resetUi();
      $("#th-select-modal").modal("show");
    };

    $("#extend").click(function(){
      if (canExtendUnextensible && !canBeExtended)
          new ConfirmationDialog(function(){ startExtend() },{subtitle: "Are you sure you want to extend an Non-Extensible code list?", dangerous: true}).show();
      else
        startExtend();
    });

    $("#new_subset").click(function(){
      thesauriSelect.setCallback(subsetsIndex.createSubsetCallback.bind(subsetsIndex));
      thesauriSelect.resetUi();
    });
  }

  var columns = [
    {"data" : "identifier"},
    {"data" : "notation"},
    {"data" : "preferred_term"},
    {"data" : "synonym"},
    {"data" : "definition"},
    {"data" : "tags", "render": function (data, type, row, meta) { return colorCodeTagsBadge(data);}},
    { "data": "indicators", "width": "90px", "render" : function (data, type, row, meta) {
        data = filterIndicators(data, {withoutVersions: true});
        return type === "display" ? formatIndicators(data) : formatIndicatorsString(data);
    }}
  ];
  var cp = new ChildrenPanel(dataUrl, 1000, columns);

});
