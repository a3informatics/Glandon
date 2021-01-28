// import ManagedItemsPanel from '../managed_items_panel'

import { $get, $put } from 'shared/helpers/ajax'
import { renderSpinnerIn$, removeSpinnerFrom$ } from 'shared/ui/spinners'

import Renderer from './status_panel_renderers'

/**
 * Status Panel
 * @description Document Control panel for viewing and modifying Managed Item Status  
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class StatusPanel {

  /**
   * Create a Status Panel instance
   * @param {string} selector Unique selector string of the status-panel
   * @param {Object} urls Urls for Status related requests - data, updateVersion, updateVersionLabel,
   */
  constructor({
    selector = '#status-panel',
    urls
  } = {}) {

    Object.assign( this, { 
      selector, urls, param: 'iso_managed'
    })

    this.loadData();
    
  }

  /**
   * Load Status Panel data
   */
  loadData() {

    this._loading( true )

    $get({
      url: this.urls.data,
      done: data => this.renderAll( data ),
      always: () => this._loading( false )
    })

  }

  updateVersionLabel(newLabel) {

    this._update({
      url: this.urls.updateVersionLabel,
      data: { version_label: newLabel },
      onSuccess: versionLabel => {

        this.data.version_label = versionLabel

        Renderer.versionLabelField({
          data: this.data, 
          submit: versionLabel => this.updateVersionLabel( versionLabel )
        })

      }
    })

  }

  /**
   * Render Status Panel based on given data 
   * @param {Object} data Status data to render
   */
  renderAll(data) {

    // console.log(data);

    this.data = data; 

    Renderer.versionField({
      data, 
      submit: version => console.log({version})
    })

    Renderer.versionLabelField({
      data, 
      submit: versionLabel => this.updateVersionLabel( versionLabel )
    })

    Renderer.currentField({
      data,
      submit: () => console.log('currentUpdate')
    })

  }

  /**
   * Get the Status Panel element
   * @return {JQuery Element} Status Panel element
   */
  get $panel() {
    return $( this.selector )
  }


  /*** Private ***/


  /**
   * Make Update request (PUT) to the server, handle UI
   * @param {string} url Request URL
   * @param {object} data Request data (without strong param)
   * @param {function} onSuccess Invoked on request sucess, response passed as first arg
   */
  _update({ url, data, onSuccess }) {

    this._loading( true )

    $put({
      url, 
      data: { [this.param ]: data },
      done: response => onSuccess( response ),
      always: this._loading( false )
    })

  }


  /*** Support ***/


  _loading(enable) {

    if ( enable )
      renderSpinnerIn$( this.selector, 'small' )
    else 
      removeSpinnerFrom$( this.selector )

  }

}
