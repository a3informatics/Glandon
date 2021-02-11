import TokenTimer from 'shared/custom/tokens/token_timer'
import StatusPanel from 'shared/custom/iso_managed/status/status_panel'

$(document).ready(() => {

  const tt = new TokenTimer({
    tokenId: tokenTimerId,
    warningTime: tokenTimerWarning
  });

  const sp = new StatusPanel({
    urls: statusUrls
  })

});
