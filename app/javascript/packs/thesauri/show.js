import ChildrenPanel from 'shared/custom/iso_managed/children_panel'

$(document).ready( () => {

  let cp = new ChildrenPanel({
    url: childrenDataUrl,
    param: "thesauri"
  });

});
