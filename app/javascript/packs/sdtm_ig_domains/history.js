import HistoryPanel from 'shared/custom/iso_managed/history_panel'

$(document).ready( () => {

  let ip = new HistoryPanel({
    url: historyDataUrl,
    param: "sdtm_ig_domain",
    cache: false
  });

});
