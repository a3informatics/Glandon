import FormEditor from 'shared/custom/forms/edit/editor_panel'
import TokenTimer from 'shared/custom/tokens/token_timer'

$(document).ready( () => {

  let tt = new TokenTimer({
    tokenId: tokenTimerId,
    warningTime: tokenTimerWarning
  });

  let fe = new FormEditor({
    formId: editorFormId,
    urls: {
      data: editorDataUrl,
      refData: editorRefDataUrl
    },
    onEdited: () => tt.extend()
  });

});
