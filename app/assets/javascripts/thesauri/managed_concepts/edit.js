$(document).ready(function() {
  var ep = new EditorPanel(childrenPath, updatePath, parentId, lockCallback);
  var np = new NewPanel(addChildPath, 'managed_concept', callback);
  var timer = new Timer($('#edit_lock_token').val(), "imh_header", $('#warning_timeout').val());
  var unload = new UnloadV2($('#edit_lock_token').val(), false, unloadCallback);
  var rankModal = new RankModal(lockCallback);

  $("#edit-properties-button").on("click", function(){
    new EditProperties(epItemcodelist, "codelist", "ManagedConcept", null).show();
  });


  function callback(data) {
    ep.add(data);
  }

  function lockCallback() {
    if (!timer.expired) {
      timer.extendLock();
    }
  }

  function unloadCallback() {
    timer.unload();
  }

})
