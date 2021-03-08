import { $put } from 'shared/helpers/ajax'

import { $confirm } from 'shared/helpers/confirmable'

/**
 * Upgrade Handler
 * @description Allows to upgrade an item (Subset / Extension)
 * @requires _upgrade_button Partial file to be included in the page 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class UpgradeHandler {

  /**
   * Create an Upgrade Handler
   */
  constructor() {

    const $button = $('#upgrade-button')

    // Upgrade not possible when button not rendered
    if ( !$button.length )
      return

    Object.assign( this, {
      $button, 
      url: upgradeItemUrl
    })
    
    this._setListeners()

  }

  /**
   * Make upgrade request to the server, refresh page on success
   */
  upgrade() {

    this._loading( true )

    $put({
      url: this.url,
      done: () => location.reload(),
      always: () => this._loading( false )
    })

  }


  /*** Private ***/


  /**
   * The event listeners 
   */
  _setListeners() {

    this.$button.click( () => 
      $confirm({ 
        subtitle: `The code list will be upgraded to the latest version of the source code list 
                  (items removed from the source will be taken out of this code list as well)`,
        callback: () => this.upgrade()
      }) 
    )

  }

  /**
   * Toggle loading state on the Upgrade button
   * @param {boolean} enable Target loading state
   */
  _loading(enable) {
    this.$button.toggleClass( 'el-loading', enable )
  }

}