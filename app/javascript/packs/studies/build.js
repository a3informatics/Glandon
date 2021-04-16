import TokenTimer from 'shared/custom/tokens/token_timer'

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

  // Fetch and itialize specific Tab module
  const tab = new URLSearchParams( window.location.search ).get( 'tab' )
  initialize( tab )

});

async function initialize(tab) {

  switch( tab ) {

    case 'timeline': 
      const StudyTimeline = await fetchModule( 'study_timeline' )
      new StudyTimeline()
      break

    // Add other tab modules 
  }

}

async function fetchModule(filename) {

  let module = await import( /* webpackPrefetch: true */ `shared/custom/studies/build/${ filename }` )
  return module.default

}