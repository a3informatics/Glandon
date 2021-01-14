/*** Collection of helper functions for Sidebar UI manipulation ***/

const sb = '#sidebar',
      colH = 'collapsed-horizontal',
      colV = 'collapsed-vertical',
      col = 'collapsing'

/**
 * Initialize Sidebar-related event handlers
 */
function initialize() {

  // Toggle menu type handler 
  $(sb).find( '.menu-type-button' ).on( 'click', e => 
    toggleMenuType( $(e.target) ) 
  )

  // Horizontal collapse & expand handler 
  $(sb).find( '#sidebar-toggle-horizontal' ).on( 'click', () => 
    toggleSidebar()
  )

  // Vertical collapse & expand handler 
  $( '#sidebar-toggle-vertical' ).on( 'click', () => 
    toggleSidebar()
  )

  // Menu category collapse / expand 
  $(sb).find( '.menu-category' ).on( 'click', e => {
    toggleCategory( $(e.target) )
  })

}

/**
 * Toggle the Sidebar expanded state and trigger the window resize event 
 * @param {string | undefined} newState Enforce target state ['open', 'close'], optional 
 */
function toggleSidebar(newState) {

  // Convert state to boolean if defined
  if ( newState !== undefined )
   newState = newState === 'close'

  // Toggle Sidebar collapsed state horizontally
  if ( isHorizontal() )
    $(sb).toggleClass( `${col} ${colH}`, newState )

  // Toggle Sidebar collapsed state vertically
  else {

    $(sb).toggleClass( `${col} ${colV}`, newState )

    // Arrow rotation for vertical collapse state change
    $( '#sidebar-toggle-vertical' ).toggleClass( 'arrow-rotate', newState )

  }

  // On Sidebar transition end handler
  $(sb).one('transitionend', () => {
    
    // Trigger global window resize event  
    $( window ).trigger( 'resize' )

    // Remove collapsing css class  
    $( sb ).removeClass( col )

  })

}

/**
 * Toggle the Sidebar Menu category expanded state  
 * @param {JQuery Element} $category Menu Category element to toggle
 */
function toggleCategory($category) {

  $category.closest( '.category-container' )
           .toggleClass( 'collapsed' )

  toggleSidebar( 'open' )

}

/**
 * Change visible Menu Type 
 * @param {JQuery Element} $menuTypeBtn Menu Type button to switch visibility to 
 */
function toggleMenuType($menuTypeBtn) {

  const targetMenu = $menuTypeBtn.attr( 'data-target' )

  // Update styling of menu type buttons 
  $menuTypeBtn.addClass( 'active' )
              .siblings()
                .removeClass( 'active' )

  // Update visibility of menu types 
  $( targetMenu ).show()
                 .siblings( '.menu-type-wrap' )
                    .hide()

}

/**
 * Check if Sidebar state is horizontal
 * @return {boolean} True if document width is > 768
 */
function isHorizontal() {
  return $( document ).width() > 768
}

/**
 * Check if Sidebar is in open state (horizontally and vertically)
 * @return {boolean} True if sidebar is open
 */
function isOpen() {
  return !$(sb).hasClass( colH ) && !$(sb).hasClass( colV )
}

export {
  initialize,
  toggleSidebar,
  isOpen, 
  isHorizontal
}