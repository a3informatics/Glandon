import TablePanel from 'shared/base/table_panel'
import { dtSDTMModelShowColumns } from 'shared/helpers/dt/dt_column_collections'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: sdtmIGShowDataUrl,
    param: "sdtm_ig",
    extraColumns: dtSDTMModelShowColumns(),
    count: 10,
    paginated: true
  });

});
