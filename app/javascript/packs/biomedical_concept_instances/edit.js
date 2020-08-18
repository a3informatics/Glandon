import BCManager from 'shared/biomedical_concept_instances/edit/bc_manager'

$(document).ready( () => {

  let manager = new BCManager({
    baseBCId: baseBCId,
    tokenWarningTime: tokenWarningTime,
    urls: {
      data: bcEditDataUrl,
      update: bcUpdateUrl,
      edit: bcEditUrl
    }
  })

});
