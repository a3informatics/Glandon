/**
 * Expandable Content initializer
 * @description Initializes all Expandable Content elements in the page, handles UI updates. Runs once, globally
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ExpandableContent {

  /**
   * Initialize all Expandable Content elements in the page
   * @static
   */
  static initialize() {

    if ( !window.pageHasExpandableContent )
      return;

    $( 'body' ).on( 'click', '.expandable-content-btn', e => {

      // Get values
      let ecButton = $( e.currentTarget ),
          ecParent = ecButton.closest( '.expandable-content-wrap' ),
          ecText = ecButton.find( '.expandable-content-text' ),
          expandText = ecText.attr( 'data-expand-text' ),
          collapseText = ecText.attr( 'data-collapse-text' );

      // Update styles
      ecParent.toggleClass( 'collapsed' )
              .find( '.icon-arrow-d' )
              .toggleClass( 'arrow-rotate' );

      // Update button text
      ecText.text( ecParent.hasClass( 'collapsed' ) ? expandText : collapseText );

      // Trigger change event on button
      ecButton.change();

    });

  }

}
