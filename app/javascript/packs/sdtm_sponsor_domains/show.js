import TablePanel from 'shared/base/table_panel'
import { dtSDTMSDDomainShowColumns } from 'shared/helpers/dt/dt_column_collections'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: sdtmSDDomainShowDataUrl,
    param: "sdtm_sponsor_domain",
    extraColumns: dtSDTMSDDomainShowColumns(),
    count: 1000,
    order: [[0, "asc"]],
    buttons: [csvExportBtn(), excelExportBtn()],
    autoHeight: true
  });

});
