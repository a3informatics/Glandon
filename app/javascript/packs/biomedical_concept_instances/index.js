import IndexPanel from 'shared/custom/iso_managed/index_panel'
import CreateBCView from 'shared/custom/biomedical_concept_instances/bc_create'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "biomedical_concept_instance",
  });

  new CreateBCView();

});
