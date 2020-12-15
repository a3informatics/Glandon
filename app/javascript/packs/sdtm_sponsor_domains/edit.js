import SDTMSDEditor from 'shared/custom/sdtm_sponsor_domains/editor'
import TokenTimer from 'shared/custom/tokens/token_timer'

$(document).ready( () => {

  let tt = new TokenTimer({
    tokenId: tokenTimerId,
    warningTime: tokenTimerWarning
  });

  let sdtmEditor = new SDTMSDEditor({
    urls: sdtmSDEditorUrls,
    onEdited: () => tt.extend()
  });

});
