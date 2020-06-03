$(document).ready( function() {
  var synonymsPanel = new LinksPanel(synonymsUrl, "synonyms-panel", "Shared Synonyms");
  var ptsPanel = new LinksPanel(ptsUrl, "pts-panel", "Shared Preferred Terms");

  if (childrenUrl !== "") {
    var columns = [
      {"data" : "identifier"},
      {"data" : "notation"},
      {"data" : "preferred_term"},
      {"data" : "synonym"},
      {"data" : "extensible"},
      {"data" : "definition"}
    ];
    var cp = new ChildrenPanel(childrenUrl, 20, columns);
  }
});
