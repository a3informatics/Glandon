import ItemsPicker from 'shared/ui/items_picker/v2/items_picker'

import { $post } from 'shared/helpers/ajax'
import { alerts } from 'shared/ui/alerts'

/**
 * Pair Handler
 * @description Lets an item to be paired with another, user-selected item
 * @requires ItemsSelector JS to be included in page
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class PairHandler {

  /**
   * Create a Pair Handler
   * @param {string} pickerId ID of the Items Selector modal, without #
   * @param {string} param Strong param name, default = managed_concept
   * @param {string} pairUrl Path to which POST the pairing request data
   * @param {string} unpairUrl Path to which POST unpairing request
   * @param {boolean} isPaired Current paired? state of the target
   */
  constructor({
    pickerId = "pair",
    param = "managed_concept",
    isPaired,
    pairUrl,
    unpairUrl
  }) {

    Object.assign(this, { 
      pickerId, param, isPaired, pairUrl, unpairUrl 
    })

    this._setListeners()

  }

  /**
   * Opens the Pair Item Selector
   */
  open() {

    if ( this.isPaired )
      return 

    if ( this.picker )
      this.picker.show()
    else
      this._initPicker()
          .show()

  }

  /**
   * Builds and executes item pairing request
   * @param {string} id ID of the user-selected item to be paired with
   */
  pair(id) {

    this._processing(true)

    $post({
      url: this.pairUrl,
      data: { 
        [ this.param ]: { reference_id: id } 
      },
      done: () => {
        alerts.success( 'Paired successfully.' )
        setTimeout(() => location.reload(), 1000)
      },
      always: () => this._processing(false)
    })

  }

  /**
   * Builds and executes item unpairing request
   */
  unpair() {

    this._processing(true)

    $post({
      url: this.unpairUrl,
      done: () => {
        alerts.success( 'Unpaired successfully.' )
        setTimeout( () => location.reload(), 1000 )
      },
      always: () => this._processing(false)
    })

  }

  /** Private **/

  /**
   * Sets event listeners, handlers
   */
  _setListeners() {
    $('#pair-select-button').click( () => this.open() )
    $('#unpair-button').click( () => this.unpair() )
  }

  /**
   * Toggle processing state on the context menu Pair / Unpair button
   * @param {boolean} enable Target loading state
   */
  _processing(enable) {
    $('#pair-select-button').toggleClass('el-loading', enable)
  }

  /**
   * Initializes Items Picker for Pairing, sets callback
   */
  _initPicker() {
    
    this.picker = new ItemsPicker({
      id: this.pickerId,
      types: [ ItemsPicker.allTypes.TH_CL ],
      description: 'Select another Code List to pair this Code List with',
      onSubmit: s => this.pair( s.asIDs()[0] )
    })

    return this.picker 

  }

}
