$(document).ready(function() {
  
  var csvp = new ConceptSystemViewPanel(conceptSystemId, conceptSystemNamespace, 100, nodeSelected);
  var imtlp = new IsoManagedTagListPanel(isoManagedId, isoManagedNamespace);
  var imlop = new IsoManagedListOldPanel();
  
  function nodeSelected(data) {
    imtlp.selected(data);
    imlop.refresh(data.id, data.namespace);
  } 

  // Set window resize.
  window.addEventListener("resize", csvp.reDisplay);

});