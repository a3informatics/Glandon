import TokenTimer from 'shared/custom/tokens/token_timer'

import StudyTimeline from 'shared/custom/studies/study_timeline'

$(document).ready( () => {

  const tt = new TokenTimer({
    tokenId: tokenTimerId,
    warningTime: tokenTimerWarning
  })

  // Prevent token from being released when switching tabs 
  $('.study-build-tab').on( 'mousedown', e => {
    
    tt.handleUnload = false
    setTimeout( () => tt.handleUnload = true, 1000 )

  })

  const st = new StudyTimeline()

});
