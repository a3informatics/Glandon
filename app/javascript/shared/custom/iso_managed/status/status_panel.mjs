// import ManagedItemsPanel from '../managed_items_panel'

import { $get, $put } from 'shared/helpers/ajax'
import { iconBtn } from 'shared/ui/buttons'
import { renderSpinnerIn$, removeSpinnerFrom$ } from 'shared/ui/spinners'
import { icons } from 'shared/ui/icons'

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
      selector, urls,
      param: 'iso_managed'
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

    this._loading( true )

    $put({
      url: this.urls.updateVersionLabel,
      data: {
        [ this.param ]: {
          iso_scoped_identifier: { version_label: newLabel }
        }
      },
      done: data => {
        this.data.version_label = data
        this._renderVersionLabel()
      },
      always: () => this._loading( false )
    })
    
  }

  /**
   * Render Status Panel based on given data 
   * @param {Object} data Status data to render
   */
  renderAll(data) {

    console.log(data);

    this.data = data; 

    this._renderVersionLabel()
    this._renderVersion()
    this._renderCurrent()


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
   * Build and render the Version Label field 
   * @param {boolean} editing Specifies whether editing controls should be rendered, [deafult=false]
   */
  _renderVersionLabel(editing = false) {

    let label = this.data.version_label,
        $content
    
    // Read-only Version Label
    if ( !editing ) {
      
      $content = this.$label( 
        label, 
        () => this._renderVersionLabel( true ) 
      )

    }

    // Editable Version Label 
    else {

      const $input = this.$input( label, 'Version label' ),
            $editBtns = this.$editBtns(
              () => this.updateVersionLabel( $input.val() ),
              () => this._renderVersionLabel()
            )
      $content = $input.add( $editBtns )

    }

    // Render in DOM 
    this.$panel.find( '#version-label' )
               .html( $content )

  }

  /**
   * Build and render the Semantic Version field 
   * @param {boolean} editing Specifies whether editing controls should be rendered, [deafult=false]
   */
  _renderVersion(editing = false) {

    let { label, editable, next_versions: versions } = this.data.semantic_version,
        $content

editable = true
    // Prevent editing when not editable 
    editing = editing && editable 

    // Read-only Semantic Version 
    if ( !editing )
      $content = this.$label( 
        label, 
        () => this._renderVersion( true ), 
        editable 
      )

    // Editable Semantic Version 
    else {

      const $select = this.$select( versions ),
            $editBtns = this.$editBtns(
              () => console.log('submit'),
              () => this._renderVersion()
            )
      $content = $select.add( $editBtns )
    
    }

    // Render in DOM 
    this.$panel.find( '#version' )
        .html( $content )
    
  }

  /**
   * Build and render the Current (flag) field 
   */
  _renderCurrent() {

    let { current, state } = this.data,
        $content

// state.label = 'Standard'

    if ( current === true )
      $content = $( icons.checkMarkIcon( true ) )

    else {

      if ( state.label !== 'Standard' )
        $content = $( icons.checkMarkIcon( false ) )
                    .add( '<small> Item status is not Standard</small>' )
      else 
        $content = $( '<button>' ).addClass( 'btn white' )
                                  .text( 'Make Current' )
                                  .click( () => console.log('test') )

    }
    
    // Render in DOM 
    this.$panel.find( '#current' )
               .html( $content )

  }


  /*** Renderer Helpers ***/


  $editBtns(onSubmit, onDismiss) {

    const submitBtn = iconBtn({ id: 'sp-submit', icon: 'ok', color: 'white' }),
          dismissBtn = iconBtn({ id: 'sp-dismiss', icon: 'times', color: 'grey' }),
          $submit = $( submitBtn ).click( () => onSubmit() ),
          $dismiss = $( dismissBtn ).click( () => onDismiss() )

    return $submit.add( $dismiss )

  }

  $input(value, placeholder, type = 'text') {

    return $('<input>').prop( 'placeholder', placeholder )
                       .prop( 'type', type )
                       .val( value )

  }

  $select(options) {

    const $options = Object.entries( options )
                           .map( ([name, value]) => 
                              $('<option>').val( name )
                                           .text( `${ name }: ${ value }`) 
                            )

    return $('<select>').html( $options )

  }

  $label(text, click = () => {}, enabled = true ) {

    return $('<div>').addClass( 'bg-label editable' )
                     .addClass( !enabled && 'disabled' )
                     .text( text || 'None' )
                     .click( () => enabled && click() )

  }


  /*** Support ***/


  _loading(enable) {

    if ( enable )
      renderSpinnerIn$( this.selector, 'small' )
    else 
      removeSpinnerFrom$( this.selector )

  }

}
