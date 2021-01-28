// import ManagedItemsPanel from '../managed_items_panel'

import { $get, $ajax } from 'shared/helpers/ajax'
import { renderSpinnerIn$, removeSpinnerFrom$ } from 'shared/ui/spinners'
import { alerts } from 'shared/ui/alerts'
import { $confirm } from 'shared/helpers/confirmable'

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

    this.loadData()
    this._setListeners()
    
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

  /**
   * Move Item to next state request, handle response
   * @param {boolean} userConfirmed Overrides confirmation dialog when set to true. Only used when moving to Superseded
   */
  nextState(userConfirmed = false) {

    if ( this.isInState('Superseded') )
      return

    // Require user confirmation to move to Superseded
    if ( this.isInState('Standard') && userConfirmed === false ) {

      $confirm({ 
        callback: () => this.nextState( true ) 
      })
      return 

    }

    // Execute request 
    else {

      const note = this.$panel.find( '#adm-note' ).val(),
            issue = this.$panel.find( '#unr-issue' ).val()

      this._update({
        url: this.urls.nextState,
        type: 'POST',
        data: {
          administrative_note: note,
          unresolved_issue: issue
        },
        onSuccess: data => {   
          this.renderAll( data )
          alerts.success( `Moved to ${ data.state.label }`)
        } 
      })

    }

  }

  /**
   * Update Version Label request, handle response
   * @param {string} newLabel New value to set the Version Label to 
   */
  updateVersionLabel(newLabel) {

    this._update({
      url: this.urls.updateVersionLabel,
      data: { version_label: newLabel },
      onSuccess: versionLabel => {
        this.data.version_label = versionLabel
        this.renderAll()
      }
    })

  }

  /**
   * Update Version request, handle response
   * @param {string} newVersionType New type to set the Version to (major/minor/patch) 
   */
  updateVersion(newVersionType) {

    this._update({
      url: this.urls.updateVersion,
      data: { sv_type: newVersionType },
      onSuccess: version => {
        this.data.semantic_version = version
        this.renderAll()
      }
    })

  }

  /**
   * Make Item current request, handle response
   */
  makeCurrent() {

    this._update({
      url: this.urls.makeCurrent,
      type: 'POST',
      onSuccess: () => {
        this.data.current = true 
        this.renderAll() 
      }
    })

  }

  /**
   * Render Status Panel based on given data 
   * @param {Object} data Status data to render, optional (will use cached data)
   */
  renderAll(data) {

    data ? this.data = data : data = this.data

    Renderer.versionField({
      data, 
      submit: versionType => this.updateVersion( versionType )
    })

    Renderer.versionLabelField({
      data, 
      submit: versionLabel => this.updateVersionLabel( versionLabel )
    })

    Renderer.currentField({
      data,
      submit: () => this.makeCurrent()
    })

    Renderer.statusInfo( data )

    Renderer.headerFields( data )

  }

  /**
   * Check if item is in given state
   * @return {string} State to check for
   * @return {boolean} True if Item is Superseded
   */
  isInState(state) {
    return state.toLowerCase() === this.data.state.label.toLowerCase()
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
   * Set panel event listeners & handlers
   */
  _setListeners() {

    this.$panel.find( '#next-status' ) 
               .click( () => this.nextState() )

  }

  /**
   * Make Update request to the server, handle UI
   * @param {string} url Request URL
   * @param {object} data Request data (without strong param)
   * @param {function} onSuccess Invoked on request sucess, response passed as first arg
   * @param {string} type Request type [default=PUT]
   */
  _update({ url, data, onSuccess, type = 'PUT' }) {

    // Prevent updates while processing
    if ( this._processing )
      return

    this._loading( true )

    $ajax({
      url, type,
      data: { [this.param ]: data },
      done: response => onSuccess( response ),
      always: () => this._loading( false )
    })

  }


  /*** Support ***/


  /**
   * Toggle Loading state of panel
   * @param {boolean} enable Target loading state
   */
  _loading(enable) {

    this._processing = enable

    if ( enable )
      renderSpinnerIn$( this.selector, 'small' )
    else 
      removeSpinnerFrom$( this.selector )

  }

}
