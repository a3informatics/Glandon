$(document).ready( function() {
  var urls = {childrenUrl: subsetChildrenUrl, addUrl: addToSubsetUrl, removeUrl: removeFromSubsetUrl,
    removeAllUrl: removeAllFromSubsetUrl, moveAfterUrl: moveAfterSubsetUrl }

  var subsetEditPanel = new SubsetEditChildrenPanel(urls, 1000, lockCallback);
  var sourceChildrenPanel = new SubsetSourceChildrenPanel(clChildrenUrl, 1000, subsetEditPanel, lockCallback);
  
  var timer = new Timer($('#edit_lock_token').val(), "imh_header", $('#warning_timeout').val());
  var unload = new Unload(false);

  $("#edit-properties").on("click", function(){
    // epItemsubset is declared in the edit_properties_modal
    new EditProperties(epItemsubset, "subset", "ManagedConcept", null).show();
  });

  function lockCallback() {
    if(!timer.expired)
      timer.extendLock();
  }

  $("#edit-properties").on('click', function(){
    lockCallback();
  });

  $("#submit_button").on('click', function(){
    unload.keepToken = true;
  });

});
