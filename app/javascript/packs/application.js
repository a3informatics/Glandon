/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

$( () => {

  ( async() => {

    // Handles events of all Expandable Contents on page, if present
    if ( window.pageHasExpandableContent ) {

      let ExpandableContent = await import( 'shared/ui/expandable_content' );
      ExpandableContent.default.initialize();

    }

    // Adds color to any Tags in page headers, if present
    if ( window.pageHeaderHasTags ) {

      let { tagOutlines } = await import( 'shared/ui/tags' );
      tagOutlines();

    }

  } )()

});
