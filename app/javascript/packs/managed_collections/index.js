import IndexPanel from 'shared/custom/iso_managed/index_panel'
import CreateMCView from 'shared/custom/managed_collections/mc_create'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "managed_collection",
  });

  new CreateMCView();

});
