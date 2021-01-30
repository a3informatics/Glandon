import { iconBtn } from 'shared/ui/buttons'
import { icons } from 'shared/ui/icons'

// Element getters 
const getPanel = () => $('#status-panel'),
      getVersionLabel = () => getPanel().find( '#version-label' ),
      getVersion = () => getPanel().find( '#version' ),
      getCurrent = () => getPanel().find( '#current' )


/*** Version Information Renderers ***/


/**
 * Build and render the Version field 
 * @param {Object} data Status Panel data object
 * @param {boolean} editMode Specifies whether edit view should be rendered [default=false]
 * @param {function} submit Value submit callback, new value and option text passed as arguments
 */
function versionField({
  data,
  editMode = false,
  submit = () => {}
}) {

  let version = data.semantic_version,
      $content 

  editMode = editMode && version.editable
  
  // Render Edit view of Version field
  if ( editMode ) {

    let $sel = select({ options: version.next_versions, current: version.label })

    let $buttons = editingBtns({
      onSubmit: () => submit( $sel.val(), $sel.find('option:selected').text() ),
      onDismiss: () => versionField({ data, submit, editMode: false }) 
    })

    $content = $sel.add( $buttons )

  }

  // Render Display view of Version field
  else 

    $content = label({ 
      text: version.label, 
      enabled: version.editable,
      click: () => versionField({ data, submit, editMode: true }) 
    })

  getVersion().html( $content )

}

/**
 * Build and render the Version Label field 
 * @param {Object} data Status Panel data object
 * @param {boolean} editMode Specifies whether edit view should be rendered [default=false]
 * @param {function} submit Value submit callback, new value passed as argument
 */
function versionLabelField({
  data,
  editMode = false,
  submit = () => {}
}) {

  let versionLabel = data.version_label,
      $content 
    
  // Render Edit view of Version Label field
  if ( editMode ) {

    let $editInput = input({ 
      value: versionLabel, 
      placeholder: 'Version label',
      submit: () => submit( $editInput.val() )
    })

    let $buttons = editingBtns({
      onSubmit: () => submit( $editInput.val() ),
      onDismiss: () => versionLabelField({ data, submit, editMode: false }) 
    })

    $content = $editInput.add( $buttons )

  }

  // Render Display view of Version Label field
  else 

    $content = label({ 
      text: versionLabel, 
      click: () => versionLabelField({ data, submit, editMode: true }) 
    })

  getVersionLabel().html( $content )

}

/**
 * Build and render the Current field 
 * @param {Object} data Status Panel data object
 * @param {function} submit On click callback
 */
function currentField({ 
  data,
  submit = () => {}
}) {

  let { current, state } = data,
      $content = $( icons.checkMarkIcon( current ) )

  if ( current !== true ) {

    if ( state.label !== 'Standard' )
      $content = $content.add( '<small> Item status is not Standard</small>' )
      
    else 
      $content = $( '<button>' ).addClass( 'btn white' )
                                .text( 'Make Current' )
                                .click( () => submit() )

  }

  getCurrent().html( $content )

}


/*** Status Information Renderers ***/


/**
 * Render data in Status information 
 * @param {Object} data Status Panel data object
 */
function statusInfo(data) {

  const { state, next_state: nextState } = data,
        $status = getPanel().find( '#status' ),
        $nextStatus = getPanel().find( '#status-next' ),
        $details = getPanel().find( '#details-wrap' )

  // Clear textareas
  getPanel().find('textarea').val('')

  // Render current state
  renderStatusData({ data: state, div: $status })

  // Render next state if item not Superseded
  if ( state.label !== nextState.label )
    renderStatusData({ data: nextState, div: $nextStatus })

  // Clear & disable elements if item Superseded
  else {

    getPanel().find( '#status-actions .btn')
              .addClass( 'disabled' )
              .unbind()
    getPanel().find( '#status-arrow' )
              .add( $nextStatus )
              .add( $details )
              .remove()
    
  }

}

/**
 * Render data in a single Status block 
 * @param {Object} data Specific Status data 
 * @param {Element} div Target Status block div  
 */
function renderStatusData({data, div}) {

  div.find( '.status' ).text( data.label )
  div.find( '.description' ).text( data.definition )

}


/*** Header ***/


/**
 * Render data into the Managed Item header (when changed)
 * @param {Object} data Status Panel data object
 */
function headerFields(data) {

  const $header = $('#imh_header')
  $header.find( '.state' ).text( data.state.label )
  $header.find( '.semantic-version' ).text( data.semantic_version.label )
  $header.find( '.version-label' ).text( data.version_label )

}


/*** Element renderers ***/


function editingBtns({
  onSubmit = () => {}, 
  onDismiss = () => {}
}) {

  const $submitBtn = $(
    iconBtn({ id: 'sp-submit', icon: 'ok', color: 'white' })
  ).click( () => onSubmit() )

  const $dismissBtn = $(
    iconBtn({ id: 'sp-dismiss', icon: 'times', color: 'grey' })
  ).click( () => onDismiss() )

  return $submitBtn.add( $dismissBtn )

}

function label({ 
  text, 
  enabled = true,
  click = () => {} 
}) {

  return $('<div>').addClass( 'bg-label editable' )
                   .addClass( !enabled && 'disabled' )
                   .text( text || 'None' )
                   .click( () => enabled && click() )

}

function input({
  value, 
  placeholder, 
  type = 'text',
  submit = () => {}
}) {

  return $('<input>').prop( 'placeholder', placeholder )
                     .prop( 'type', type )
                     .val( value )
                     .keypress( ({ which }) => which === 13 ? submit() : true )

}

function select({ options = [], current }) {

  const $opts = Object.entries( options )
                      .map( ([value, text]) => 
                        option({ text, value, selected: text.includes( current ) })
                      )

  return $('<select>').html( $opts )

}

function option({ text, value, selected }) {
  
  return $('<option>').val( value )
                      .text( `${ value }: ${ text }`) 
                      .prop( 'selected', selected )

}

export default {
  versionLabelField,
  versionField,
  currentField,
  statusInfo,
  headerFields
}