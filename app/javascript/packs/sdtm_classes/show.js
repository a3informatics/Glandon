import TablePanel from 'shared/base/table_panel'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: sdtmClassShowDataUrl,
    param: "sdtm_class"
  });

});
