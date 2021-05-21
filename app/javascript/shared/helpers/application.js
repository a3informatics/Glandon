import { initialize as initSidebar } from 'shared/ui/layouts/sidebar'

/**
 * Primary application initializer - only include code that is required in all pages in the app
 */
function initialize() {

  // Sidebar handle interaction events 
  initSidebar()

  // Handles events of all Expandable Contents on page, if present
  initExpandable()

  // Adds color to any Tags in page headers, if present
  initTags()

}

async function initExpandable() {

  if ( !window.pageHasExpandableContent )
    return

  let ExpandableContent = await import( 'shared/ui/expandable_content' )
  ExpandableContent.default.initialize()

}

async function initTags() {

  if ( !window.pageHeaderHasTags )
    return

  let { tagOutlines } = await import( 'shared/ui/tags' )
  tagOutlines()

}

export default initialize
