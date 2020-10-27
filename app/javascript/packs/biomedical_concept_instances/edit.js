import BCManager from 'shared/biomedical_concept_instances/edit/bc_manager'

$(document).ready( () => {

  let manager = new BCManager({
    baseBCId: baseBCId,
    tokenWarningTime: tokenWarningTime,
    urls: {
      metadata: bcMetadataUrl,
      editAnother: bcEditAnotherUrl,
      data: bcEditFullDataUrl,
      update: bcUpdateUrl
    }
  })

});
