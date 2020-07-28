import IndexPanel from 'shared/iso_managed/index_panel'
import CreateBCView from 'shared/biomedical_concept_instances/create_view'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "biomedical_concept_instance",
  });

  new CreateBCView();

});
