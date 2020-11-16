import ImportsManager from 'shared/custom/imports/imports_manager_panel'

$(document).ready( () => {

  let im = new ImportsManager({
    dataUrl: importsDataUrl,
    deleteAllUrl: importsDeleteAllUrl
  });

});
