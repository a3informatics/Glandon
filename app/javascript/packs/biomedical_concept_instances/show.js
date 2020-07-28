import TablePanel from 'shared/base/table_panel'
import { dtBCShowColumns } from 'shared/helpers/dt/dt_column_collections'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: bcShowDataUrl,
    param: "biomedical_concept_instance",
    paginated: false,
    extraColumns: dtBCShowColumns(),
    order: [[2, "desc"]],
    buttons: [csvExportBtn(), excelExportBtn()]
  });

});
