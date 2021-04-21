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

  // Helpers
  async function initialize(tab) {

    switch( tab ) {
  
      case 'timeline': 
        // This is included only for Timeline development purposes, needs a wrapper module for the Arm-Epoch Matrix and multiple StudyTimeline instances per Arm etc... 
        const StudyTimeline = await fetchModule( 'study_timeline' )

        new StudyTimeline({
          armLabel: 'High Dose' // Mock value
        })
        break
  
      // Add other tab modules 
    }
  
  }
  
  async function fetchModule(filename) {
  
    let module = await import( /* webpackPrefetch: true */ `shared/custom/studies/build/${ filename }` )
    return module.default
  
  }

});