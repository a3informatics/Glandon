import IndexPanel from 'shared/custom/iso_managed/index_panel'
import CreateStudyView from 'shared/custom/studies/study_create'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "study",
  });

  let cs = new CreateStudyView();

});
