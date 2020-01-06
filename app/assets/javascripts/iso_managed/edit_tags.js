$(document).ready(function() {

  var csvp = new ConceptSystemViewPanel(conceptSystemId, 100, nodeSelected);
  var imtlp = new IsoManagedTagListPanel(isoManagedId, isoManagedNamespace);
  var icl = new IsoConceptList();

  function nodeSelected(data) {
    imtlp.selected(data);
    icl.refresh(data.id);
  }

  // Set window resize.
  $(window).resize(function() {
    csvp.reDisplay();
  });

});
