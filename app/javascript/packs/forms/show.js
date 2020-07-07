import TablePanel from "shared/base/table_panel"
import { dtFormShowColumns } from "shared/helpers/dt_column_collections"

$(document).ready( () => {

  let tp = new TablePanel({
    selector: "#show-panel table#show",
    url: formShowDataUrl,
    param: "form",
    paginated: false,
    extraColumns: dtFormShowColumns(),
    order: [[2, "desc"]]
  });
  
});
