import { $confirm } from 'shared/helpers/confirmable'
import { $ajax } from 'shared/helpers/ajax'

/**
 * Simple Confirmable Button
 * @description Initializes a click handler for a button that will redirect to a link / maje AJAX request
 * The buttons must have the following properties: 'data-url' and 'data-type'
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ConfirmableButtons {

  /**
   * Set confirmable click action handler to a set of buttons
   * @static
   * @param {string} outerSelector Selector for to attach the click event to
   * @param {string} buttonSelector Actual button selector (e.g. css class)
   * @param {string} title Confirmation Dialog title, optional
   * @param {string} subtitle Confirmation Dialog subtitle, optional
   * @param {boolean} dangerous Confirmation Dialog dangerous styling, optional
   */
  static init({
    outerSelector,
    buttonSelector,
    title,
    subtitle,
    dangerous,
  }) {

    $( outerSelector ).on('click', buttonSelector, e => {

      $confirm({
        title,
        subtitle,
        dangerous,
        callback: () => {

          let method = $( e.currentTarget ).attr( 'data-type' ),
              url = $( e.currentTarget ).attr( 'data-url' );

          if ( method.toUpperCase() === 'GET' )
            location.href = url;
          else
            $ajax({
              url,
              type: method,
              done: d => {

                if ( d?.redirect_url )
                  location.href = d.redirect_url 
                else 
                  location.reload()

              }
            });

        }
      });

    })

  }

}
