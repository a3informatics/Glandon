$(document).ready( function() {

  var mis = new ManagedItemsSelect(null);
  var hp = new HistoryPanel(url_path, strict_params, identifier, scope_id, 100, mis);
  var cp = new CommentsPanel(comments_url_path);

});