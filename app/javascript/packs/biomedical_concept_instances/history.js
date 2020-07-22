import HistoryPanel from 'shared/iso_managed/history_panel'

$(document).ready( () => {

  let ip = new HistoryPanel({
    url: historyDataUrl,
    param: "biomedical_concept_instance",
    cache: false
  });

});
