import TablePanel from 'shared/base/table_panel'
import { dtADaMIGDatasetShowColumns } from 'shared/helpers/dt/dt_column_collections'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: adamIGDatasetShowDataUrl,
    param: "adam_ig_dataset",
    extraColumns: dtADaMIGDatasetShowColumns(),
    count: 1000,
    buttons: [csvExportBtn(), excelExportBtn()],
    order: [[0, "asc"]]
  });

});
