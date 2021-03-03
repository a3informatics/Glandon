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
   * @param {EventHandler} params.eventHandler ItemsPicker shared EventHandler instance 
   */
  constructor({
    type,
    options,
    eventHandler
  }) {
    super({ type, options, eventHandler })
  }

  /**
   * Reset Selector to initial state, clear caches
   */
  reset() {

    super.reset()
    this.childrenPanel.clear(true)
    this._toggleCards( 'index' )

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
    this.indexPanel.on( 'refresh', () => this.childrenPanel.clear(true) )

    this.historyPanel.on( 'refresh', () => this.childrenPanel.clear(true) )

    // Children panel events 
    this.childrenPanel
      .on( 'selected', s => this._onChildrenSelect(s) )
      .on( 'deselected', d => this._onChildrenDeselect(d) )
      .on( 'interactionStateChanged', enable => 
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

  /**
   * On Children Panel item selected event, dispatch add to selection event
   * @param {array} selected Selected item data 
   */
  _onChildrenSelect(selected) {
    this._EventHandler.dispatch( 'addToSelection', this._addContextToItems( selected ) )
  }

  /**
   * On Children Panel item deselected event, dispatch remove from selection event
   * @param {array} deselected Deselected item data 
   */
  _onChildrenDeselect(deselected) {
    this._EventHandler.dispatch( 'removeFromSelection', deselected )
  }


  /*** Support ***/


  /**
   * Add context (parent Managed Concept data) to Unmanaged Concept items
   * @param {array} items Unmanaged Concepts data objects
   * @return {array} Unmanaged Concepts data objects with _context property set to Managed Concept data 
   */
  _addContextToItems(items) {

    const [context] = this.historyPanel.selected

    return items.map( item => 
      Object.assign( item, { _context: context })
    )

  }

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

