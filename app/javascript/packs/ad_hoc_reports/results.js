import ReportViewer from 'shared/ad_hoc_reports/report_viewer'

$(document).ready( () => {

    let rt = new ReportViewer({
      dataUrl: reportResultsUrl,
      statusUrl: reportStatusUrl
    });

});
