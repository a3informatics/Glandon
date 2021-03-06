import IndexPanel from 'shared/custom/iso_managed/index_panel'
import SearchManager from 'shared/custom/thesauri/search_manager'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "thesauri",
  });

  SearchManager.initialize() 

});
