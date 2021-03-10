import IndexPanel from 'shared/custom/iso_managed/index_panel'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "protocols",
  });

});
