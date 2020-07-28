import HistoryPanel from 'shared/iso_managed/history_panel'

$(document).ready( () => {

  let ip = new HistoryPanel({
    url: historyDataUrl,
    param: "thesauri",
    cache: false
  });

  let cp = new CommentsPanel(commentsDataUrl);

});
