import TablePanel from 'shared/base/table_panel'
import { dtSDTMClassShowColumns } from 'shared/helpers/dt/dt_column_collections'


$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: sdtmClassShowDataUrl,
    param: "sdtm_class",
    extraColumns: dtSDTMClassShowColumns()
  });

});
