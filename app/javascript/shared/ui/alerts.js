/*** Renderers for Alerts ***/

let alerts = {

  /**
   * Render Error alert
   * @param {string | array} text Alert text(s)
   * @param {JQuery Element} element DOM Element to render Alert inside of, optional
   * @param {boolean} dismissible Specifies if alert should be dismissible, optional
   */
  error(text, element, dismissible) {
    render( alertsHTML( 'danger', text, dismissible ), element );
  },

  /**
   * Render Warning alert
   * @param {string | array} text Alert text(s)
   * @param {JQuery Element} element DOM Element to render Alert inside of, optional
   * @param {boolean} dismissible Specifies if alert should be dismissible, optional
   */
  warning(text, element, dismissible) {
    render( alertsHTML( 'warning', text, dismissible ), element );
  },

  /**
   * Render Success alert
   * @param {string | array} text Alert text(s)
   * @param {JQuery Element} element DOM Element to render Alert inside of, optional
   * @param {boolean} dismissible Specifies if alert should be dismissible, optional
   */
  success(text, element, dismissible) {
    render( alertsHTML( 'success', text, dismissible ), element );
  }

}

/**
 * Render Alert(s) in DOM for a duration of time
 * @param {string} alerts Alert(s) HTML
 * @param {JQuery Element} element DOM Element to render Alert inside of, optional
 * @param {integer} duration Duration in seconds fater the Alert is removed from DOM, optional
 */
function render(alerts, element, duration = 5) {

  let wrapper = ( element || $( '#alerts' ) ),
      $alerts = $( alerts );

  wrapper.html( $alerts );

  setTimeout( () => $alerts.remove(), duration * 1000 );

}

/**
 * Clears all alerts from DOM
 * @param {JQuery Element} element DOM Element with Alerts inside of, optional
 */
function clearAlerts(element) {

  let wrapper = ( element || $( '#alerts' ) );
  wrapper.html();

}

/**
 * Render Alerts HTML
 * @param {string} type Alert type ( danger / warning / success )
 * @param {string | array} text Alert text(s)
 * @param {boolean} dismissible Specifies if alert should be dismissible, optional
 * @return {string} One or more alerts HTML
 */
function alertsHTML(type, texts, dismissible) {

  if ( !Array.isArray( texts ) )
    texts = [ texts ];

  return texts.reduce( ( html, text ) => html + _alertHTML( { type, text, dismissible } ), '' );

}


/*** Private ***/


/**
 * Render a customized Alert
 * @param {string} type Alert style type ( danger / warning / success )
 * @param {string} text Alert text
 * @param {boolean} dismissible Specifies if alert should be dismissible, optional [default=true]
 * @return {string} Custom Alert HTML
 */
function _alertHTML({
  type,
  text,
  dismissible = true
} = {}) {

  return `<div class='alert alert-${type} ${ dismissible ? 'alert-dismissible' : '' }' role='alert'>
            ${ dismissible ? `<button class='close' data-dismiss='alert'> <span>&times;</span> </button>` : '' }
            ${ text }
          </div>`;

}

export {
  alerts,
  alertsHTML,
  clearAlerts
}
