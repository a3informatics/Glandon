import TablePanel from 'shared/base/table_panel'
import { dtSDTMIGDomainShowColumns } from 'shared/helpers/dt/dt_column_collections'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: sdtmIGDomainShowDataUrl,
    param: "sdtm_sponsor_domain",
    extraColumns: dtSDTMIGDomainShowColumns(),
    count: 1000,
    order: [[0, "asc"]],
    buttons: [csvExportBtn(), excelExportBtn()]
  });

});
