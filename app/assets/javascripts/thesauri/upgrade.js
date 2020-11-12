$(document).ready(function(){

  var ccp = new ChangesCdiscPanel(cdiscChangesUrl);
  var dp = new DifferencesPanel();
  var cp = new ChangesPanel(null, 2);
  var up = new UpgradePanel(upgradeDataUrl, upgradeBaseUrl);

  var selectCallback = function(dataRow) {
    toggleTableActive(ccp.id, false);
    $("#impact-item-identifier").text(dataRow.identifier);
    $("#tab-affected").click();
    dp.reload(dataRow.differences_url);
    cp.reload(dataRow.changes_url);
    up.loadData(dataRow);
    enableChangesPanel();
  }

  var enableChangesPanel = function() {
    if(!dp.processing && !cp.processing && !up.impact.processing)
      toggleTableActive(ccp.id, true);
    else
      setTimeout(enableChangesPanel, 500);
  }

  ccp.sCallback = selectCallback;
});
