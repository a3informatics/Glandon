import ManagedSelector from './ip_managed_selector'

import IPHelper from '../support/ip_helper'
import PickerPanel from './panels/ip_panel'

/**
 * Unmanaged Selector (Items Picker) 
 * @description Unmanaged Items Selector for version-based selection of unmanaged code list item types 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class UnmanagedSelector extends ManagedSelector {

  /**
   * Create a new Unmanaged Selector instance
   * @param {Object} params Instance parameters
   * @param {Object} params.type Selector type, must an entry be from the RdfTypesMap
   * @param {Object} params.options ItemsPicker options object 
   */
  constructor({
    type,
    options
  }) {
    super({ type, options })
  }

  /**
   * Destroy Selector, clear from DOM
   */
  destroy() {

    super.destroy() 
    this.childrenPanel.destroy()

  }


  /*** Private ***/


  /**
   * Initialize Selector modules along with the additional Children Panel
   * @return {UnmanagedSelector} This instance (for chaining)
   */
  _initialize() {

    super._initialize()

    const { selector, type, _Renderer } = this 

    // Disable multiple option on History Panel and use on the Children Panel instead  
    this.historyPanel.setMultiple( false )

    this.childrenPanel = new PickerPanel({
      selector, type,  _Renderer,
      id: 'children'
    }).setMultiple( this.options.multiple )

    return this 

  }

  /**
   * Render Selector contents
   * @return {UnmanagedSelector} This instance (for chaining)
   */
  _render() {

    this._Renderer.renderUnmanagedSelector()
    return this 

  }


  /*** Events ***/


  /**
   * Picker Panel event listeners & handlers
   */
  _setPanelListeners() {

    super._setPanelListeners() 

    // Clear children panel data & cache when other panels refresh their data 
    this.indexPanel.on( 'refresh', () => 
      this.childrenPanel.clear(true) 
    )

    this.historyPanel.on( 'refresh', () => 
      this.childrenPanel.clear(true) 
    )

    // Toggle interaction on History panel on children panel load 
    this.childrenPanel.on( 'interactionStateChanged', enable => 
      this.historyPanel._toggleInteraction(enable) 
    )

  }

  /**
   * On Index Panel item deselected event, clear history and children panels
   * @param {array} deselected Deselected item data 
   */
  _onIndexDeselect(deselected) {

    super._onIndexDeselect()
    this.childrenPanel.clear()

  }

  /**
   * On History Panel item selected event, set-up and load children panel data
   * @param {array} selected Selected item data 
   */
  _onHistorySelect(selected) {

    this._toggleCards( 'children' )
    this.childrenPanel.setData( selected[0] )
                      .load()
  
  }

  /**
   * On History Panel item deselected event, clear children panel, toggle cards visibility
   * @param {array} deselected Deselected item data 
   */
  _onHistoryDeselect(deselected) {

    this._toggleCards( 'index' )
    this.childrenPanel.clear()

  }


  /*** Support ***/


  /**
   * Toggle the visibility of the index / children cards in Unmanaged Selector 
   * @param {string} targetCard Identifier of the target card (index / children) 
   */
  _toggleCards(targetCard) {

    const cardId = IPHelper.cardId( targetCard ),
          otherCardId = IPHelper.cardId( targetCard === 'index' ? 'children' : 'index' )

    $( this.selector ).find( '#' + cardId )
                      .show() 
                      .siblings( '#' + otherCardId )
                      .hide()

  }


}

