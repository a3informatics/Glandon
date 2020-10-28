import ModalView from 'shared/base/modal_view'

import Validator from 'shared/ui/validator'

import { alerts } from 'shared/ui/alerts'
import colors from 'shared/ui/colors'
import { $ajax } from 'shared/helpers/ajax'

/**
 * Generic Modal-based Editor
 * @description Generic Editor of fields based in a Modal, with custom & dynamic content rendering
 * @extends ModalView base module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class GenericEditor extends ModalView {

  /**
   * Create a Generic Modal Editor instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the editor modal
   * @param {Function} params.onShow Callback to execute on Editor show, optional
   * @param {Function} params.onHide Callback to execute on Editor hide, optional
   * @param {Function} params.onUpdate Callback to execute on edit submit success, optional
   * @param {boolean} params.submitChangedOnly Specifies whether only changed fields should be submitted on update, [default=true]
   */
  constructor({
    selector = "#generic-editor",
    onShow = () => {},
    onHide = () => {},
    onUpdate = () => {},
    submitChangedOnly = true
  } = {} ) {

    super({ selector });

    Object.assign( this, {
      onUpdate, onShow, onHide,
      submitChangedOnly
    });

    this._setListeners();

  }

  /**
   * Set Item to this instance and show modal
   * @param {?} item Item instance / data to Edit
   */
  edit(item) {

    if ( !item )
      return;

    this.item = item;
    this.show();

  }

  /**
   * Validate data and submit data to server on validation success
   * @param {String} type Request type, [default='PUT']
   */
  submit(type = 'PUT') {

    // Stop if no fields have been changed
    if ( !this.changedFields || _.isEmpty( this.changedFields ) ) {

      if ( this.submitChangedOnly ) {
        this.hide();
        return;
      }

    }

    // Validate fields based on defined rules
    if ( !Validator.validate( this.content, this._validationRules ) )
      return;

    this._submit( type );

  }

  /**
   * Empty and reset the editor
   */
  reset() {

    this.content.empty();
    $( this.selector ).find( '.modal-footer .btn' )
                      .show();

  }

  /**
   * Render Editor contents
   */
  render() {

    this.reset();
    this._renderContent();

  }

  /**
   * Change the title of the Editor Modal
   * @param {String} newTitle New modal title
   * @return {GenericEditor} Returns itself (for method chaining)
   */
  setTitle(newTitle) {

    if ( !newTitle )
      return;

    this.modal.find( '#title' )
              .text( newTitle );

    return this;

  }

  /**
   * Change the title icon of the Editor Modal
   * @param {String} newIcon New icon css class name
   * @return {GenericEditor} Returns itself (for method chaining)
   */
  setTitleIcon(newIcon) {

    if ( !newIcon )
      return;

    this.modal.find( '#title-icon' )
              .removeClass()
              .addClass( `${ newIcon } text-link text-small` );

    return this;

  }

  /**
   * Change the Submit button text of the Editor Modal
   * @param {String} newText New submit button text
   * @return {GenericEditor} Returns itself (for method chaining)
   */
  setSubmitText(newText) {

    if ( !newText )
      return;

    this.modal.find( '#editor-submit' )
              .text( newText );

    return this;

  }

  /**
   * Get the Editor content div
   * @return {JQuery Element} Editor content element
   */
  get content() {
    return this.modal.find( '.ge-content' );
  }


  /** Private **/


  /**
   * Set event listeners, handlers
   */
  _setListeners() {

    // Editor Submit button click
    this.modal.find( '#editor-submit' )
              .on( 'click', () => this.submit() );

  }

  /**
   * Submit data to the server, handle response
   * @param {String} type Request type
   */
  _submit(type) { 

    this._loading( true );

    $ajax({
      type,
      url: this._requestSpec.url,
      data: this._requestSpec.data,
      contentType: 'application/json',
      errorDiv: this.$error,
      done: d => d.fieldErrors ?
                  this._onError( d.fieldErrors ) :
                  this._onSuccess( d ),

      always: () => this._loading( false )
    });

  }

  /**
   * Render content on modal show
   * @override parent
   */
  _onShow() {

    if ( this.onShow )
      this.onShow();

    this.render();

  }

  /**
   * On modal hide callback
   * @override parent
   */
  _onHide() {

    if ( this.onHide )
      this.onHide();

  }

  /**
   * On modal show complete callback, autofocus on first input
   * @override parent
   */
  _onShowComplete() {

    this.content.find( 'textarea, input' )
                .first()
                .focus();

  }

  /**
   * On item update success, append updated properties and call onSubmit
   */
  _onSuccess(data) { }

  /**
   * On Item submit request error, (validation only) render errors
   */
  _onError(errors) {

    for ( let error of errors ) {

      let field = this.content.find( `[name='${ error.name }']` );
      Validator._renderError( field, error.status );

    }

  }

  /**
   * Render complete callback, adjust textarea heights to fit their contents and set default focus
   */
  _onRenderComplete() {

    setTimeout( () => {

      // Textarea scaling
      this.content.find('textarea')
                  .each( (i, ta) => {
                    let newHeight = ta.scrollHeight > ta.clientHeight ?
                                      ta.scrollHeight + 5 : ''
                    $(ta).css( 'height', newHeight );
                  });

    }, 200);

  }


  /** Content Type Renderers **/


  /**
   * Render the item Editor content for the current Item instance
   */
  _renderContent() {

    // Extend function to render contents before the code below

    this._onChangeListeners();
    this._onRenderComplete();

  }


  /** Event listeners **/


  /**
   * Listen to changes in input fields and add them to changedFields if user edits them
   */
  _onChangeListeners() {

    let cachedValues = this._allEditorValues;
    this.changedFields = {};

    // Update the changed fields set on field input
    this.content.find( 'input, textarea, select' )
                .on( 'input', (e) => {

                  let field = $( e.target ),
                      name = field.prop( 'name' ),
                      value = field.prop( 'type' ) === 'checkbox' ?
                                field.prop( 'checked' ) : field.val().trim()

                  if ( value !== cachedValues[name] )
                    this.changedFields[name] = value;
                  else
                    delete this.changedFields[name];
                });

  }


  /** Element Renderers **/


  /**
   * Render an Editor field table with given row definitions
   * @param {array} rows Array of two-element arrays containing the row name at 0th index and row content at 1st index
   * @return {JQuery Element} Editor field table for appending to DOM
   */
  _fieldTable(rows) {

    let table = $( '<table>' ).addClass( 'field-table' );

    for (let row of rows) {

      let r = $( '<tr>' );

      let labelC = $( '<td>' ).html( row[0]),
          valueC = $( '<td>' ).html( row[1] );

      r.append( labelC ).append( valueC );
      table.append( r );

    }

    return table;

  }

  /**
   * Render a non-editable styled label
   * @param {string} text Label text
   * @return {JQuery Element} Styled label for appending to DOM
   */
  _labelStyled(text) {

    return $( '<span>' ).addClass( 'label-styled' )
                        .css( 'border-color', this._colorAccent )
                        .html( text );

  }

  /**
   * Render a textarea element with given specifications
   * @param {string} property Name of the property in the instance item data object to edit as textarea
   * @param {string | null} value Value to fill the textarea with, only include if different than property value, optional
   * @param {boolean} wide Value representing whether the textarea should include the 'wide' cssClass, optional [default=false]
   * @param {boolean} disabled Value representing whether the textarea should be disabled, optional [default=false]
   * @return {JQuery Element} Styled textarea for appending to DOM
   */
  _textarea(property, { value = null, wide = false, disabled = false }  = {}) {

    let input = $( '<textarea>' ).val( value === null ? this.item.data[property] : value )
                                 .addClass(( wide ? ' wide' : '' ))
                                 .prop( 'name', property )
                                 .prop( 'disabled', disabled )
                                 .prop( 'placeholder', 'Enter text')
                                 .css( 'border-bottom-color', this._colorAccent ),

        wrapper = $( '<div>' ).addClass( 'form-group' )
                              .append( input );

    return wrapper;

  }

  /**
   * Render an input element with given specifications
   * @param {string} property Name of the property in the instance item data object to edit as input
   * @param {string | null} value Value to fill the input with, only include if different than property value, optional
   * @param {boolean} narrow Value representing whether the input should include the 'narrow' cssClass, optional [default=false]
   * @param {boolean} disabled Value representing whether the input should be disabled, optional [default=false]
   * @return {JQuery Element} Styled input for appending to DOM
   */
  _input(property, { value = null, narrow = false, disabled = false }  = {}) {

    let input = $( '<input>' ).val( value === null ? this.item.data[property] : value )
                              .prop( 'type', 'text' )
                              .prop( 'name', property )
                              .prop( 'disabled', disabled )
                              .prop( 'placeholder', 'Enter text')
                              .addClass( (narrow ? 'narrow' : '') )
                              .css( 'border-bottom-color', this._colorAccent ),

        wrapper = $( '<div>' ).addClass( 'form-group' )
                              .append( input );

    return wrapper;

  }

  /**
   * Render a checkbox element with given specifications
   * @param {string} property Name of the property in the instance item data object to edit as checkbox
   * @param {string | null} value Value to set the checkbox's checked state to, only include if different than property value, optional [default=null]
   * @param {boolean} disabled Value representing whether the checkbox should be disabled, optional [default=false]
   * @return {JQuery Element} Styled checkbox for appending to DOM
   */
  _checkbox(property, { value = null, disabled = false } = {}) {

    let input = $( '<input>' ).prop( 'type', 'checkbox' )
                              .addClass( 'styled' )
                              .prop( 'checked', value === null ? this.item.data[property] : value )
                              .prop( 'disabled', disabled )
                              .prop( 'name', property ),

        styledInput = $( '<span>' ).addClass( 'checkbox-styled green' ),

        label = $( '<label>' ).append( input )
                              .append( styledInput ),

        wrapper = $( '<div>' ).addClass( 'form-group' )
                              .append( label );

    return wrapper;

  }

  /**
   * Render a select element with given specifications
   * @param {string} property Name of the property in the instance item data object to edit as select
   * @param {object} options Object containing the option names as keys
   * @param {boolean} disabled Value representing whether the select should be disabled, optional [default=false]
   * @return {JQuery Element} Styled select for appending to DOM
   */
  _select(property, options = [], { disabled = false } = {}) {

    let select = $( '<select>' ).prop( 'name', property )
                                .prop( 'disabled', disabled )
                                .css( 'border-bottom-color', this._colorAccent );

    for ( let option of Object.keys(options) ) {

      let o = $( '<option>' ).prop( 'value', option )
                             .prop( 'selected', this.item.data[property] === option )
                             .text( option );
      select.append(o);

    }

    let wrapper = $( '<div>' ).addClass( 'form-group' )
                              .append( select );

    return wrapper;

  }


  /** Utilities **/


  /**
   * Toggle Editor's loading state
   * @param {boolean} enable Value representing the target loading state
   */
  _loading(enable) {

    this.content.toggleClass( 'loading', enable );

    this.modal.find( '.btn' )
              .toggleClass( 'disabled', enable )
              .filter( '#editor-submit' )
                .toggleClass( 'el-loading', enable );

  }

  /**
   * Get the Item's color accent, override for custom behavior
   * @return {string} Item accent color-code
   */
  get _colorAccent() {
    return colors.secondaryLight;
  }

  /**
   * Get an object with all input names & values
   * @return {object} Object containing the values of all input, textarea and select field names & values
   */
  get _allEditorValues() {

    let editorValues = { }

    this.content.find( 'input, textarea, select' )
            .each( (i, el) => {

              let field = $(el),
                  name = field.prop( 'name' ),
                  value = field.prop( 'type' ) === 'checkbox' ?
                            field.prop( 'checked' ) : field.val().trim()

               editorValues[ name ] = value;

            });

    return editorValues;

  }

  /**
   * Get the Item update request specification, override
   * @return {Object} Update request specs object containing url & data properties
   */
  get _requestSpec() {
    return { }
  }

  /**
   * Get the Editor's error div
   * @return {JQuery Element} Editor modal error div
   */
  get $error() {
    return this.modal.find( '.error' );
  }

  /**
   * Get validation rules for current Item edit fields, override
   * @return {Object} validation rules compatible with Validator
   */
  get _validationRules() {
    return { }
  }

}
