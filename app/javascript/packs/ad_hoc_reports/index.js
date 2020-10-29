import ReportsManager from 'shared/custom/ad_hoc_reports/reports_manager'

$(document).ready( () => {

  let im = new ReportsManager({
    dataUrl: reportsDataUrl,
    deleteAllowed: reportsDeleteAllowed
  });

});
