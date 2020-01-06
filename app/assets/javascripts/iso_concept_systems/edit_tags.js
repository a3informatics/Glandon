$(document).ready(function() {

  var csvp = new ConceptSystemViewPanel(conceptSystemId, 100, nodeSelected);
  var imtlp = new IsoManagedTagListPanel(isoManagedId, isoManagedNamespace);

  function nodeSelected(data) {
    imtlp.selected(data);
  }

  // Set window resize.
  $(window).resize(function() {
    csvp.reDisplay();
  });

});
