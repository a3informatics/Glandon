import { renderFullPageSpinner } from 'shared/ui/spinners'
import { baseUrl } from 'shared/helpers/urls'

/**
 * Set a click listener on given link, which will open a in a new tab with a loading message and redirect to the origianl href url of the link 
 * Used for Reports that take a long time   
 * @param {string | JQuery Element} target Target link (must have a defined href)
 */
function linkRedirectInNewTab(target) {

  // Extract url from href attribute and replace with '#' 
  const url = $( target ).attr( 'href' )
  $( target ).attr( 'href', '#' )

  // Set click event on the link
  $( target ).on( 'click', () => newTabRedirectWithLoading({
    redirectUrl: url 
  }) )

}

/**
 * Open a new tab with a specified loading message and redirect to a given url 
 * @param {string} redirectUrl Target url to redirect to
 * @param {string} message Loading message to display, optional
 * @param {int} timeout Timeout duration in seconds, optional
 * @param {string} timeoutMessage Timeout message, optional
 */
function newTabRedirectWithLoading({ 
  redirectUrl,
  message = 'Loading...', 
  timeout = 30, 
  timeoutMessage  = 'The request timed out'
}) {

  // Open a new tab 
  const tab = window.open()
  
  // Build spinner html
  const spinner = renderFullPageSpinner( message )

  // Attach stylesheet reference if defined
  if ( typeof stylesheetRef !== 'undefined' ) 
    addStylesheetToDoc( stylesheetRef, tab.document )

  // Render page contents
  $( tab.document.body ).html( spinner )
  tab.document.title = 'A3 MDR'

  // Redirect to target url after render complete 
  setTimeout( () => tab.location.href = redirectUrl, 200 )

  // Show error and close window if timeout elapses
  tab.setTimeout( () => {

    if( $( tab.document ).find( '.fp-spinner-wrap' ).length ) { 
      tab.alert( timeoutMessage )
      tab.close()
    }

  }, timeout * 1000 )

}

/**
 * Adds a stylesheet reference to a document head with absolute url to the style file 
 * @param {string} stylesheetRef Link ref string to the style 
 * @param {Document} document Target document to append the stylesheetRef to 
 */
function addStylesheetToDoc(stylesheetRef, document) {

  const href = $( stylesheetRef ).attr( 'href' ),
        stylesheetRefAbsolute = stylesheetRef.replace( href, `${ baseUrl() }/${ href }` )

  $( document ).find( 'head' ).append( stylesheetRefAbsolute )

}

export {
  linkRedirectInNewTab
}
