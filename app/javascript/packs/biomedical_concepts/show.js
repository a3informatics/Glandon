import TablePanel from "shared/base/table_panel"
import { dtBCShowColumns } from "shared/helpers/dt_column_collections"

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: showDataUrl,
    param: "biomedical_concept",
    paginated: false,
    extraColumns: dtBCShowColumns()
  });


});
