import IPHelper from '../support/ip_helper'
import IPSRenderer from './support/ip_selector_renderer'

import PickerPanel from './panels/ip_panel'

import { tableInteraction } from 'shared/helpers/utils'

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

    // Remove from DOM etc
    this._config.buildRequired = true 

  }


  /*** Private ***/


  /**
   * Build, render and initialize Selector 
   */
  _build() {

    this._Renderer.renderManagedSelector( this.type )
    this._initialize()

    // Load index table data automatically 
    this.indexPanel.load()

    this._config.buildRequired = false 

  }

  /**
   * Initialize Selector modules
   */
  _initialize() {

    this.indexPanel = new PickerPanel({
      selector: this.selector,
      type: this.type,
      tableId: 'index',
      onSelect: s => this._onIndexSelect( s.data() ),
      onDeselect: s => this._onIndexDeselect( s.data() )
    })

    this.historyPanel = new PickerPanel({
      selector: this.selector,
      type: this.type,
      tableId: 'history'
    })

  }


  /*** Events ***/


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
   * @param {array} deselected Deelected item data 
   */
  _onIndexDeselect(deselected) {
    this.historyPanel.clear()
  }


  /*** Getters ***/

  
  /**
   * Get the current Renderer instance 
   * @return {IPSRenderer} 
   */
  get _Renderer() {
    return this._config.renderer
  }


  /*** Support ***/


  _loading(enable) {

    if ( enable )
      tableInteraction.disable( this.indexPanel.selector )
    else 
      tableInteraction.enable( this.indexPanel.selector )

  }

}

