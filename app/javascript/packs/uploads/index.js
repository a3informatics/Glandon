import UploadsManager from 'shared/custom/uploads/uploads_manager'

$(document).ready( () => {

  let um = new UploadsManager({
    removeUrl: uploadsRemoveUrl,
    removeAllUrl: uploadsRemoveAllUrl
  });

});
