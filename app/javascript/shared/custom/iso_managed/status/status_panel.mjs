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
   * @param {Object} urls Urls for Status related requests 
   * { data, updateVersion, updateVersionLabel, makeCurrent, nextState, forwardState, rewindState }
   */
  constructor({
    selector = '#status-panel',
    urls
  } = {}) {

    Object.assign( this, { 
      selector, urls, param: 'iso_managed'
    })

    this._loadData()
    this._setListeners()
    
  }


  /*** Actions ***/


  /**
   * Move Item to next state
   */
  nextState() {

    if ( this.isInState('Superseded') )
      return
    else if ( this.isInState('Standard') )
      $confirm({ callback: () => this._nextState() }) // Require user confirmation to move to Superseded
    else 
      this._nextState()

  }

  /**
   * Forward item state to Released
   */
  forwardState() {

    if ( this.isInState('Superseded') ) 
      return
    else if ( this.isInState('Standard') ) 
      alerts.warning( 'Item is already in Released state' )
    else 
      this._forwardState()

  }

  /**
   * Rewind item state to Draft
   */
  rewindState() {

    if ( this.isInState('Superseded') )
      return
    else if ( this.isInState('Incomplete') ) 
      alerts.warning( 'Item is already in Draft state' )
    else 
      this._rewindState()

  }

  /**
   * Update Version Label
   * @param {string} newLabel New value to set the Version Label to 
   */
  updateVersionLabel(newLabel) {

    if ( this.data.version_label === newLabel )
      this._renderAll()
    else 
      this._updateVersionLabel( newLabel )

  }

  /**
   * Update Version 
   * @param {string} versionType New Version Type to set (major/minor/patch) 
   * @param {string} version New Version option text (to compare against current version) 
   */
  updateVersion(versionType, version) {

    if ( version.includes( this.data.semantic_version.label ) )
      this._renderAll()
    else 
      this._updateVersion( versionType )

  }

  /**
   * Make item Current
   */
  makeCurrent() {

    if ( this.data.current === false )
      this._makeCurrent()

  }


  /*** Getters ***/


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

    this.$panel.find( '#rewind-status' )
               .click( () => this.rewindState() )
    
    this.$panel.find( '#forward-status' )
               .click( () => this.forwardState() )

    this.$panel.find( '#with-dependencies' )
               .on( 'change', e => 
      this.$panel.find( '#next-status' )
                 .toggleClass( 'disabled', e.target.checked ) 
    )

  }


  /*** Actions ***/


  /**
   * Request to move item to next state, handle response
   */
  _nextState() {

    this._update({
      url: this.urls.nextState,
      data: this._detailsData,
      onSuccess: data => {

        this._renderAll( data )
        alerts.success( `Moved to ${ data.state.label }`)

      } 
    })

  }

  /**
   * Request to forward item to Released state, handle response
   */
  _forwardState() {

    this._update({
      url: this.urls.forwardState,
      data: {
        ...this._detailsData,
        with_dependencies: this._withDependencies
      },
      onSuccess: data => {   

        this._renderAll( data )
        alerts.success( `Forwarded to ${ data.state.label }` )

      } 
    })

  }

  /**
   * Request to rewind item to Draft state, handle response
   */
  _rewindState() {

    this._update({
      url: this.urls.rewindState,
      data: {
        ...this._detailsData,
        with_dependencies: this._withDependencies
      },
      onSuccess: data => {   
        
        this._renderAll( data )
        alerts.success( `Rewinded to ${ data.state.label }`)

      } 
    })

  }

  /**
   * Request to update item Version Label, handle response
   * @param {string} newLabel New Version Label value 
   */
  _updateVersionLabel(newLabel) {

    this._update({
      url: this.urls.updateVersionLabel,
      type: 'PUT',
      data: { version_label: newLabel },
      onSuccess: versionLabel => {
        
        this.data.version_label = versionLabel
        this._renderAll()

      }
    })

  }

  /**
   * Request to update item Version, handle response
   * @param {string} versionType New Version Type value 
   */
  _updateVersion(versionType) {

    this._update({
      url: this.urls.updateVersion,
      type: 'PUT',
      data: { sv_type: versionType },
      onSuccess: version => {

        this.data.semantic_version = version
        this._renderAll()

      }
    })

  }

  /**
   * Request to make item Current, handle response
   */
  _makeCurrent() {

    this._update({
      url: this.urls.makeCurrent,
      onSuccess: () => {

        this.data.current = true 
        this._renderAll() 

      }
    })

  }


  /*** Requests ***/


  /**
   * Load Status Panel data
   */
  _loadData() {

    this._loading( true )

    $get({
      url: this.urls.data,
      done: data => this._renderAll( data ),
      always: () => this._loading( false )
    })

  }

  /**
   * Make Update request to the server, handle UI
   * @param {string} url Request URL
   * @param {object} data Request data (without strong param)
   * @param {function} onSuccess Invoked on request sucess, response passed as first arg
   * @param {string} type Request type [default=POST]
   */
  _update({ url, data, onSuccess, type = 'POST' }) {

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


  /*** Render ***/


  /**
   * Render Status Panel based on given data 
   * @param {Object} data Status data to render, optional (will use cached data)
   */
  _renderAll(data) {

    data ? this.data = data : data = this.data

    // Render Version information
    Renderer.versionField({
      data, 
      submit: (type, text) => this.updateVersion( type, text )
    })
    Renderer.versionLabelField({
      data, 
      submit: versionLabel => this.updateVersionLabel( versionLabel )
    })
    Renderer.currentField({
      data,
      submit: () => this.makeCurrent()
    })
    // Render Version information in the Header
    Renderer.headerFields( data )
    // Render Status information
    Renderer.statusInfo( data )

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

  /**
   * Get the checked value of the with-dependencies checkbox
   * @return {boolean} True if checkbox checked
   */
  get _withDependencies() {
    return this.$panel.find( '#with-dependencies' ).prop( 'checked' )
  }

  /**
   * Get the data values of the administrative note & unresolved issue fields
   * @return {Object} Object with keys as param names and entered texts as values
   */
  get _detailsData() {
    
    return {
      administrative_note: this.$panel.find( '#adm-note' ).val(),
      unresolved_issue: this.$panel.find( '#unr-issue' ).val()
    }

  }

}
