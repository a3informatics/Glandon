import FormEditor from 'shared/forms/edit/editor_panel'
import TokenTimer from 'shared/tokens/token_timer'

$(document).ready( () => {

  let tt = new TokenTimer({
    tokenId: tokenTimerId,
    warningTime: tokenTimerWarning
  });

  let fe = new FormEditor({
    urls: {
      data: editorDataUrl,
      update: editorUpdateUrl,
      refData: editorRefDataUrl
    }
  });

});
