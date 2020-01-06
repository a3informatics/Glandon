$(document).ready(function() {

  var csvp = new ConceptSystemViewPanel(conceptSystemId, 100, nodeSelected);
  var imtlp = new IsoManagedTagListPanel(isoManagedId, isoManagedNamespace);

  function nodeSelected(data) {
    imtlp.selected(data);
  }


  // Set window resize.
  window.addEventListener("resize", function(event){
    csvp.reDisplay();
  });

  $("#sidebar-arrow").on("click", function(){
    window.setTimeout(function(){
      csvp.reDisplay();
    }, 300);
  });

});
