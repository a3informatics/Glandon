import TablePanel from 'shared/base/table_panel'
import { dtADaMIGShowColumns } from 'shared/helpers/dt/dt_column_collections'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: adamIGShowDataUrl,
    param: "adam_ig",
    extraColumns: dtADaMIGShowColumns(),
    count: 10,
    buttons: [csvExportBtn(), excelExportBtn()],
    paginated: true
  });

});
