import TablePanel from 'shared/base/table_panel'
import { dtSDTMShowColumns } from 'shared/helpers/dt/dt_column_collections'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: sdtmIGShowDataUrl,
    param: "sdtm_ig",
    extraColumns: dtSDTMShowColumns(),
    buttons: [
      csvExportBtn('th:not(:last-of-type)'), // Do not export the 'Show' button column
      excelExportBtn('th:not(:last-of-type)')
    ],
    count: 10,
    paginated: true
  });

});
