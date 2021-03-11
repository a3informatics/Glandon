import IPHelper from '../support/ip_helper'
import IPSRenderer from './support/ip_selector_renderer'

import PickerPanel from './panels/ip_panel'

/**
 * Managed Selector (Items Picker) 
 * @description Managed Items Selector for version-based selection of managed item types 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ManagedSelector {

  /**
   * Create a new Managed Selector instance
   * @param {Object} params Instance parameters
   * @param {Object} params.type Selector type, must an entry be from the RdfTypesMap
   * @param {Object} params.options ItemsPicker options object 
   * @param {SelectionHandler} params.selectionHandler Items Picker SelectionHandler instance 
   * @param {EventHandler} params.eventHandler Items Picker shared EventHandler instance 
   */
  constructor({
    parentSelector,
    type,
    options,
    selectionHandler,
    eventHandler
  }) {

    const selector = `${ parentSelector } #${ IPHelper.typeToSelectorId( type ) }`

    Object.assign( this, {
      selector,
      type, 
      options,
      _config: {
        buildRequired: true,
        renderer: new IPSRenderer( selector ),
        selectionHandler,
        eventHandler
      }
    })

  }

  /**
   * Show Selector, render and initialize if required 
   */
  show() {

    if ( this._config.buildRequired )
      this._build()
  
  }

  /**
   * Reset Selector to initial state
   * @param {boolean} clearCache Specifies if Panel caches should be cleared
   */
  reset(clearCache) {

    this.indexPanel?.reset()
    this.historyPanel?.reset()  
                      .clear( clearCache )

  }

  /**
   * Set the Multiple selection option on the select Panel
   * @param {boolean} multiple Specifies new Multiple option value
   */
  setMultiple(multiple) {
    this.historyPanel?.setMultiple( multiple )
  }

  /**
   * Destroy Selector, clear from DOM
   */
  destroy() {

    this.indexPanel?.destroy()
    this.historyPanel?.destroy()

    this._EventHandler.unbindAll()    
    this._Renderer.empty()

    this._config.buildRequired = true 

  }


  /*** Private ***/


  /**
   * Build - render and initialize Selector 
   */
  _build() {

    this._render()
        ._initialize()
        ._setPanelListeners()

    // Load index table data automatically 
    this.indexPanel.load()

    this._config.buildRequired = false 

  }

  /**
   * Initialize Selector modules
   * @return {ManagedSelector} This instance (for chaining)
   */
  _initialize() {

    const { selector, type, _Renderer } = this 

    this.indexPanel = new PickerPanel({
      selector, type, _Renderer,
      id: 'index'
    })

    this.historyPanel = new PickerPanel({
      selector, type, _Renderer,
      id: 'history'
    }).setMultiple( this.options.multiple )

    return this 

  }

  /**
   * Render Selector contents
   * @return {ManagedSelector} This instance (for chaining)
   */
  _render() {

    this._Renderer.renderManagedSelector()
    return this 

  }

  /**
   * Update Selector's Panels selected rows to match Selection Handler  
   * Call when Selection changed from places other than the Panels
   * @param {PickerPanel} targetPanel Picker Panel instance to update  
   */
  _updatePanels(targetPanel = this.historyPanel) {
    targetPanel.updateSelection( data => this._SelectionHandler.has( data ) )
  }


  /*** Events ***/


  /**
   * Picker Panel event listeners & handlers
   * @return {ManagedSelector} This instance (for chaining)
   */
  _setPanelListeners() {

    this.indexPanel
      .on( 'selected', s => this._onIndexSelect(s) )
      .on( 'deselected', d => this._onIndexDeselect(d) )
      .on( 'refresh', () => this.historyPanel.clear(true) )

    this.historyPanel
      .on( 'selected', s => this._onHistorySelect(s) )
      .on( 'deselected', d => this._onHistoryDeselect(d) )
      .on( 'dataLoaded', () => this._updatePanels() )
      .on( 'interactionStateChanged', enable => 
        this.indexPanel._toggleInteraction(enable) 
      )

    this._EventHandler
      .on( 'selectionChange', (sh, requireUpdate) => requireUpdate && this._updatePanels() )

    return this 

  }

  /**
   * On Index Panel item selected event, set-up and load history panel data
   * @param {array} selected Selected item data 
   */
  _onIndexSelect(selected) {
    this.historyPanel.setData( selected[0] )
                     .load()
  }

  /**
   * On Index Panel item deselected event, clear history panel
   * @param {array} deselected Deselected item data 
   */
  _onIndexDeselect(deselected) {
    this.historyPanel.clear()
  }

  /**
   * On History Panel item selected event, add items to SelectionHandler
   * @param {array} selected Selected item data 
   */
  _onHistorySelect(selected) {
    this._SelectionHandler.add( selected, {
      updatePanels: !this.options.multiple // Update selection of other panels only when single item selection enabled 
    } )
  }

  /**
   * On History Panel item deselected event, remove items from SelectionHandler
   * @param {array} deselected Deselected item data 
   */
  _onHistoryDeselect(deselected) {
    this._SelectionHandler.remove( deselected )
  }


  /*** Getters ***/

  
  /**
   * Get the current Renderer instance 
   * @return {IPSRenderer} 
   */
  get _Renderer() {
    return this._config.renderer
  }

  /**
   * Get the current EventHandler instance 
   * @return {EventHandler} 
   */
  get _EventHandler() {
    return this._config.eventHandler
  }

  /**
   * Get the current SelectionHandler instance 
   * @return {SelectionHandler} 
   */
  get _SelectionHandler() {
    return this._config.selectionHandler
  }

}

