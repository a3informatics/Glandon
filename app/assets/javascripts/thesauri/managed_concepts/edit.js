$(document).ready(function() {
  ep = new EditorPanel(children_path, update_path, parent_id, lockCallback);
  np = new NewPanel(add_child_path, 'managed_concept', callback);
  timer = new Timer($('#edit_lock_token').val(), "imh_header", $('#warning_timeout').val());
  unload = new UnloadV2($('#edit_lock_token').val(), false, unloadCallback);

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
