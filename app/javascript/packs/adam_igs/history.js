import HistoryPanel from 'shared/iso_managed/history_panel'

$(document).ready( () => {

  let ip = new HistoryPanel({
    url: historyDataUrl,
    param: "adam_ig",
    cache: false
  });

});
