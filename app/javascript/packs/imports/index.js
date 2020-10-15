import ImportsManager from 'shared/imports/imports_manager_panel'

$(document).ready( () => {

  let im = new ImportsManager({
    dataUrl: importsDataUrl,
    deleteAllUrl: importsDeleteAllUrl
  });

});
