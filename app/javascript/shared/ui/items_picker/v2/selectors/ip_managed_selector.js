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
   */
  constructor({
    type,
    options
  }) {

    const selector = '#' + IPHelper.typeToSelectorId( type )

    Object.assign( this, {
      selector,
      type, 
      options,
      _config: {
        buildRequired: true,
        renderer: new IPSRenderer( selector )
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
   * Destroy Selector, clear from DOM
   */
  destroy() {

    this.indexPanel.destroy()
    this.historyPanel.destroy()

    $( this.selector ).unbind()
                      .empty() 
    
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


  /*** Events ***/


  /**
   * Picker Panel event listeners & handlers
   * @return {ManagedSelector} This instance (for chaining)
   */
  _setPanelListeners() {

    this.indexPanel
      .on( 'selected', s => this._onIndexSelect(s) )
      .on( 'deselected', s => this._onIndexDeselect(s) )
      .on( 'refresh', () => this.historyPanel.clear(true) )

    this.historyPanel
      .on( 'selected', s => this._onHistorySelect(s) )
      .on( 'deselected', s => this._onHistoryDeselect(s) )
      .on( 'interactionStateChanged', enable => 
        this.indexPanel._toggleInteraction(enable) 
      )

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
   * On History Panel item selected event, add to selection 
   * @param {array} selected Selected item data 
   */
  _onHistorySelect(selected) {

  }

  /**
   * On History Panel item deselected event, remove from selection
   * @param {array} deselected Deselected item data 
   */
  _onHistoryDeselect(deselected) {

  }


  /*** Getters ***/

  
  /**
   * Get the current Renderer instance 
   * @return {IPSRenderer} 
   */
  get _Renderer() {
    return this._config.renderer
  }

}

