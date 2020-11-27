import IndexPanel from 'shared/custom/iso_managed/index_panel'
import { expandColumn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "sdtm_sponsor_domain",
  });

  // Expand column width to fit contents better
  expandColumn("Identifier", "#index");

});
