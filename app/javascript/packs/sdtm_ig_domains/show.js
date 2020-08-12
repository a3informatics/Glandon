import TablePanel from 'shared/base/table_panel'
import { dtSDTMIGDomainShowColumns } from 'shared/helpers/dt/dt_column_collections'


$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: sdtmIGDomainShowDataUrl,
    param: "sdtm_ig_domain",
    extraColumns: dtSDTMIGDomainShowColumns(),
    count: 1000,
    order: [[0, "asc"]]
  });

});
