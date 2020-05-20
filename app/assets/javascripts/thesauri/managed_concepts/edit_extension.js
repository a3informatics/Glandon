$(document).ready( function() {

  var extUrls = {loadUrl: showDataUrl, updateUrl: extensionUrl, newChildUrl: newChildUrl, newSynChildUrl: newChildFromSynUrl, destroyChildUrl: destroyChildUrl};
  var eep = new EditExtensionPanel(extUrls, extensionId, 1000, editCallback);

  var searchModal = new TermSearchModal(eep.addToExtension.bind(eep), searchUrl);
  var mis = new ManagedItemsSelect(function(val){ setTimeout(searchModal.initAndShow.bind(searchModal,val), 600); });
  var rankModal = new RankModal(editCallback);

  var timer = new Timer($('#edit_lock_token').val(), "imh_header", $('#warning_timeout').val());
  var unload = new UnloadV2($('#edit_lock_token').val(), false, unloadCallback);

  $("#edit-properties-button").on("click", function(){
    new EditProperties(epItemextension, "extension", "ManagedConcept", null).show();
  });

  function unloadCallback() {
    timer.unload();
  }

  function editCallback() {
    timer.extendLock();
  }

});
