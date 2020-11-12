$(document).ready(function(){

  var ccp = new ChangesCdiscPanel(cdiscChangesUrl);
  var dp = new DifferencesPanel(null);
  var cp = new ChangesPanel(null, 2);
  var ig = new ImpactGraph(graphBaseUrl, false);

  var selectCallback = function(dataRow){
    toggleTableActive(ccp.id, false);
    $("#impact-item-identifier").text(dataRow.identifier);
    $("#tab-affected").click();
    dp.reload(dataRow.differences_url);
    cp.reload(dataRow.changes_url);
    ig.loadData(dataRow);
    enableChangesPanel();
  }

  var enableChangesPanel = function(){
    if(!dp.processing && !cp.processing && !ig.processing)
      toggleTableActive(ccp.id, true);
    else
      setTimeout(enableChangesPanel, 500);
  }

  $("#sidebar-arrow").on("click", function(){
    setTimeout(ig.graph.onRescale.bind(ig.graph), 500);
  });

  ccp.sCallback = selectCallback;
});
