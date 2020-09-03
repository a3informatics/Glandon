import IndexPanel from 'shared/iso_managed/index_panel'
import { expandColumn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "adam_ig_dataset",
  });

  // Expand column width to fit contents better
  expandColumn("Identifier", "#index");

});
