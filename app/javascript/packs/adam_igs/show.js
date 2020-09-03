import TablePanel from 'shared/base/table_panel'
import { dtSDTMShowColumns } from 'shared/helpers/dt/dt_column_collections'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: sdtmIGShowDataUrl,
    param: "adam_ig",
    extraColumns: dtSDTMShowColumns(),
    count: 10,
    paginated: true
  });

});
