import TablePanel from 'shared/base/table_panel'
import { dtSDTMShowColumns } from 'shared/helpers/dt/dt_column_collections'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: sdtmModelShowDataUrl,
    param: "sdtm_model",
    extraColumns: dtSDTMShowColumns(),
    count: 10,
    buttons: [
      csvExportBtn('th:not(:last-of-type)'), // Do not export the 'Show' button column
      excelExportBtn('th:not(:last-of-type)')
    ],
    paginated: true
  });

});
