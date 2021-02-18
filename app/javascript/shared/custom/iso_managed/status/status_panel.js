import StatusImpactModal from 'shared/custom/iso_managed/status/status_impact_modal'

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
   * @param {string} selector Status panel selector string 
   * @param {Object} urls Urls for Status related requests 
   */
  constructor({
    selector = '#status-panel',
    urls
  } = {}) {

    Object.assign( this, { 
      selector, urls, 
      param: 'iso_managed',
      impactModal: new StatusImpactModal({
        dataUrl: urls.changeStateImpact
      })
    })

    // Prevent urls from being changed
    Object.freeze( this.urls )

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
    else if ( this._withDependencies )
      this._showStatusImpact( 'fast_forward' )
    else 
      this._changeState( 'fast_forward' )

  }

  /**
   * Rewind item state to Draft
   */
  rewindState() {

    if ( this.isInState('Superseded') )
      return
    else if ( this.isInState('Incomplete') ) 
      alerts.warning( 'Item is already in Draft state' )
    else if ( this._withDependencies )
      this._showStatusImpact( 'rewind' )
    else
      this._changeState( 'rewind' )

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
        alerts.success( `Changed Status to ${ data.state.label }`)

      } 
    })

  }

  /**
   * Request to change item state, handle response
   * @param {string} action State change action - 'forward' / 'rewind'
   */
  _changeState(action) {

    this._update({
      url: this.urls.changeState,
      data: {
        action,
        ...this._detailsData
      },
      onSuccess: data => {   

        this._renderAll( data )
        alerts.success( `Changed Status to ${ data.state.label }` )

      } 
    })

  }

  /**
   * Request to Change state with dependencies, handle response
   * @param {string} action Change state action 'fast_forward' / 'rewind'
   * @param {integer} depCount Amount of dependencies (for building success alert)
   */
  _changeStateWithDeps(action, depCount) {

    this._update({
      url: this.urls.changeState,
      data: {
        action,
        with_dependencies: true,
        ...this._detailsData
      },
      onSuccess: data => {   

        this._renderAll( data )
        alerts.success( `Changed Status of ${ depCount } items to ${ data.state.label }.` )

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

  /**
   * Show Status Impact modal and run changeStateWithDeps after user confirmation
   * @param {string} action Change state action 'fast_forward' / 'rewind'
   */
  _showStatusImpact(action) {

    this.impactModal.show({
      action,
      onConfirm: depCount => this._changeStateWithDeps( action, depCount )
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
