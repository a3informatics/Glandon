import IndexPanel from "shared/iso_managed/index_panel"
import { expandColumn } from "shared/helpers/dt"

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "form",
  });

  // Expand column width to fit contents better
  expandColumn("Identifier", "#index");

});
