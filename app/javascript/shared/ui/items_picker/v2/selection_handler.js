import SHRenderer from './support/sh_renderer'

/**
 * Selection Handler (Items Picker)
 * @description A module dedicated to rendering and handling Items Picker Selection state 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SelectionHandler {

  constructor({
    selector,
    multiple
  }) {

    const _selector = `${ selector } #items-picker-selection`

    Object.assign( this, {
      selector: _selector,
      options: {
        multiple 
      },
      _config: {
        renderer: new SHRenderer( _selector ),
        buildRequired: true 
      }
    })

    this._initialize()

  }

  add() {

  }

  remove() {

  }

  clear() {

  }

  destroy() {
    this._config.buildRequired = true
  }


  /*** Private ***/

  
  _initialize() {

    if ( this._config.buildRequired )
      this._build()

    return this 

  }

  _build() {

    this._config.renderer.renderSelectionHandler()
    this._config.buildRequired = false

  }

}