import IPHelper from '../support/ip_helper'
import IPSRenderer from './support/ip_selector_renderer'

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

    // Validate type 
    if ( !IPHelper.validateTypes([ type ]) ) {

      IPHelper.onError({ 
        debug: `Invalid item type: ${ JSON.stringify( type ) }` 
      })
      return 

    }

    // Init instance
    const selector = '#' + IPHelper.typeToSelectorId( type )

    Object.assign( this, {
      selector,
      type, 
      options,
      _config: {
        rendered: false,
        renderer: new IPSRenderer( selector )
      }
    })

  }

  /**
   * Show Selector, render and initialize if required 
   */
  show() {

    console.log(`Showing ${ this.type.param }`)

    if ( !this._config.rendered )
      this._render()
  
  }

  /**
   * Destroy Selector, clear from DOM
   */
  destroy() {
    // Remove from DOM etc
  }


  /*** Private ***/

  /**
   * Render all Selector contents 
   */
  _render() {

    this._Renderer.renderManagedSelector( this.type )
    this._config.rendered = true 

    this._initialize()

  }

  /**
   * Initialize Selector modules
   */
  _initialize() {

    $( this.selector ).find( '#index' ).DataTable({
      columns: [
        {
          title: 'Test 1'
        }
      ]
    })

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

