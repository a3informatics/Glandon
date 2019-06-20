$(document).ready(function() {
  
  var csvp = new ConceptSystemViewPanel(conceptSystemId, conceptSystemNamespace, 100, nodeSelected);
  // Manage Tags
  var imtlp = new IsoManagedTagListPanel(csvp.display());
  // Item List
  var imlop = new IsoManagedListOldPanel(csvp.display());
  
  function nodeSelected(data) {
    imtlp.selected(data);
    imlop.imlRefresh(data.id, data.namespace);
  } 

  // Set window resize.
  window.addEventListener("resize", csvp.reDisplay);

});