$(document).ready(function() {
  
  var csvp = new ConceptSystemViewPanel(conceptSystemId, conceptSystemNamespace, 100);
  
  // Set window resize.
  window.addEventListener("resize", csvp.reDisplay);

});