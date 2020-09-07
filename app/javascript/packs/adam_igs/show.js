import TablePanel from 'shared/base/table_panel'
import { dtSDTMShowColumns } from 'shared/helpers/dt/dt_column_collections'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: sdtmIGShowDataUrl,
    param: "adam_ig",
    extraColumns: dtSDTMShowColumns(),
    count: 10,
    buttons: [csvExportBtn(), excelExportBtn()],
    paginated: true
  });

});
