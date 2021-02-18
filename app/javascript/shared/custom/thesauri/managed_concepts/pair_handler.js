import ItemsPicker from 'shared/ui/items_picker/items_picker'

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
   * @param {string} selectorId ID of the Items Selector modal, without #
   * @param {string} param Strong param name, default = managed_concept
   * @param {string} pairUrl Path to which POST the pairing request data
   * @param {string} unpairUrl Path to which POST unpairing request
   * @param {boolean} isPaired Current paired? state of the target
   */
  constructor({
    selectorId = "pair",
    param = "managed_concept",
    pairUrl,
    unpairUrl,
    isPaired
  }) {

    Object.assign(this, { selectorId, pairUrl, param, unpairUrl, isPaired });
    this._setListeners();

    if (!isPaired)
      this._initSelector();
  }

  /**
   * Opens the Pair Item Selector
   */
  open() {
    if (this.selector)
      this.selector.show();
  }

  /**
   * Builds and executes item pairing request
   * @param {string} id ID of the user-selected item to be paired with
   */
  pair(id) {
    this._processing(true);

    let data = {};
    data[this.param] = { reference_id: id };

    $post({
      url: this.pairUrl,
      data: data,
      done: () => {
        alerts.success('Paired successfully.')
        setTimeout(() => location.reload(), 1000);
      },
      always: () => this._processing(false)
    })
  }

  /**
   * Builds and executes item unpairing request
   */
  unpair() {
    this._processing(true);

    $post({
      url: this.unpairUrl,
      done: () => {
        alerts.success('Paired successfully.')
        setTimeout(() => location.reload(), 1000);
      },
      always: () => this._processing(false)
    })
  }

  /** Private **/

  /**
   * Sets event listeners, handlers
   */
  _setListeners() {
    $('#pair-select-button').on('click', () => this.open());
    $('#unpair-button').on('click', () => this.unpair());
  }

  /**
   * Toggle processing state on the context menu Pair / Unpair button
   * @param {boolean} enable Target loading state
   */
  _processing(enable) {
    $('#pair-select-button').toggleClass('el-loading', enable);
  }

  /**
   * Initializes ItemsSelector for Pairing, sets callback
   */
  _initSelector() {
    this.selector = new ItemsPicker({
      id: this.selectorId,
      types: ['managed_concept'],
      onSubmit: s => this.pair( s.asIDsArray()[0] )
    });
  }

}
