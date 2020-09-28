import ModalView from 'shared/base/modal_view'

import Validator from 'shared/ui/validator'

import { $put } from 'shared/helpers/ajax'
import { isCharLetter } from 'shared/helpers/strings'

/**
 * Node Editor
 * @description RDF-Type based Editor of a Form Node
 * @requires FormNode module
 * @extends ModalView base module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class NodeEditor extends ModalView {

  /**
   * Create a Node Editor instance
   * @param {Object} params Instance parameters
   * @param {string} params.formId ID of the currently edited form
   * @param {string} params.selector JQuery selector of the node editor view
   * @param {Function} params.onShow Callback to execute on Editor show, optional
   * @param {Function} params.onHide Callback to execute on Editor hide, optional
   * @param {Function} params.onUpdate Callback to execute on node edit submit success, optional
   */
  constructor({
    formId,
    selector = "#node-editor",
    onShow = () => {},
    onHide = () => {},
    onUpdate = () => {}
  } = {} ) {

    super( { selector } );

    Object.assign( this, {
      formId, onUpdate, onShow, onHide
    });

    this._setListeners();

  }

  /**
   * Set Node to this instance and show modal
   * @param {FormNode} node Node instance to Edit
   */
  edit(node) {

    if ( !node || !node.editAllowed )
      return;

    this.node = node;
    this.show();

  }

  /**
   * Validate and submit the changed data to the server
   */
  submit() {

    // Stop if no fields have been changed
    if ( !this.changedFields || _.isEmpty( this.changedFields ) ) {

      this.hide();
      return;

    }

    // Validate fields based on defined rules
    if ( !Validator.validate( this.content, this._validationRules ) )
      return;

    // Update data server request
    this._loading( true );

    $put({
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
   * Empty and reset the editor
   */
  reset() {

    this.content.empty();
    $(this.selector).find('.modal-footer .btn')
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
   * Get the Node Editor content div
   * @return {JQuery Element} Editor content
   */
  get content() {
    return this.modal.find('.ne-content');
  }


  /** Private **/


  /**
   * Set event listeners, handlers
   */
  _setListeners() {

    this.modal.find( '#editor-submit' )
              .on( 'click', () => this.submit() );

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
  _onHideComplete() {

    if ( this.onHide )
      this.onHide();

  }

  /**
   * On node update success, append updated properties and call onSubmit
   */
  _onSuccess(data) {

    for ( let property of Object.keys( this.changedFields ) ) {
      this.node.data[property] = data[property];
    }

    this.onUpdate();
    this.hide();

  }

  /**
   * On node update error, (validation only) render errors
   */
  _onError(errors) {

    for ( let error of errors ) {

      let field = this.content.find( `[name='${ error.name }']` );
      Validator._renderError( field, error.status );

    }

  }

  /**
   * Render complete callback, adjust textarea heights to fit their contents
   */
  _onRenderComplete() {

    setTimeout( () => {

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
   * Render the Node Editor content for the current Node instance
   */
  _renderContent() {

    this.content.append( this._editorTitle() );

    if ( this.node.is( 'FORM' ) )
      this._renderForm();

    else if ( this.node.is( 'NORMAL_GROUP' ) )
      this._renderGroup();

    else if ( this.node.is( 'COMMON_GROUP' ) )
      this._renderCommon();

    else if ( this.node.is( 'BC_GROUP' ) )
      this._renderBC();

    else if ( this.node.is( 'BC_PROPERTY' ) )
      this._renderBCProperty();

    else if ( this.node.is( 'MAPPING' ) )
      this._renderMapping();

    else if ( this.node.is( 'TEXTLABEL' ) )
      this._renderTextLabel();

    else if ( this.node.is( 'PLACEHOLDER' ) )
      this._renderPlaceholder();

    else if ( this.node.is( 'COMMON_ITEM' ) )
      this._renderCommonItem();

    else if ( this.node.is( 'TUC_REF' ) )
      this._renderTUCRef();

    else if ( this.node.is( 'QUESTION' ) ) {
      this._renderQuestion();
      this._questionListeners();
    }

    this._onChangeListeners();
    this._onRenderComplete();

  }

  /**
   * Render the Form type Editor
   */
  _renderForm() {

    let identifier = [ 'Identifier', this._labelStyled( this.node.data.has_identifier.identifier ) ],
        label =      [ 'Label', this._textarea( 'label' ) ],

        fields =      this._fieldTable(
                        [ identifier, label, this._completion, this._notes ]
                      )

    this.content.append( fields );

  }

  /**
   * Render the Normal Group type Editor
   */
  _renderGroup() {

    let label =     [ 'Label', this._textarea( 'label' ) ],
        repeating = [ 'Repeating', this._checkbox( 'repeating' ) ],
        optional =  [ 'Optional', this._checkbox( 'optional' ) ],

        fields =    this._fieldTable(
                      [ label, this._completion, this._notes, repeating, optional ]
                    )

    this.content.append( fields );

  }

  /**
   * Render the Common Group type Editor
   */
  _renderCommon() {

    let label =   [ 'Label', this._textarea( 'label' ) ],
        fields =  this._fieldTable(
                    [ label ]
                  )

    this.content.append( fields );

  }

  /**
   * Render the BC Group type Editor
   */
  _renderBC() {

    // Show loading message if reference data not available
    if ( typeof this.node.data.reference === 'string' ) {

      this.content.append( 'Loading reference data...' );
      return;

    }

    let bcId =    [ 'BC Identifier', this._labelStyled(
                    this.node.data.reference.has_identifier.identifier
                  ) ],
        bcLabel = [ 'BC Label', this._labelStyled(
                    this.node.data.reference.label
                  ) ],
        label =   [ 'Label', this._textarea( 'label' ) ],

        fields =  this._fieldTable(
                    [ bcId, bcLabel, label, this._completion, this._notes ]
                  );

    this.content.append( fields );

  }

  /**
   * Render the BC Property type Editor
   */
  _renderBCProperty() {

    let label =    [ 'Label', this._labelStyled( this.node.data.label ) ],
        enabled =  [ 'Enabled', this._checkbox( 'enabled', this.node.data.has_property.enabled ) ],
        optional = [ 'Optional', this._checkbox( 'optional', this.node.data.has_property.optional ) ],

        fields =    this._fieldTable(
                      [ label, this._completion, this._notes, enabled, optional ]
                    );

    this.content.append( fields );

  }

  /**
   * Render the Mapping type Editor
   */
  _renderMapping() {

    let label =   [ 'Label', this._textarea( 'label' ) ],
        mapping = [ 'Mapping', this._input( 'mapping' ) ],

        fields =  this._fieldTable(
                    [ label, mapping ]
                  );

    this.content.append( fields );

  }

  /**
   * Render the Textlabel type Editor
   */
  _renderTextLabel() {

    let label =     [ 'Label', this._textarea( 'label' ) ],
        labelText = [ 'Label Text', this._textarea( 'label_text' ) ],

        fields =    this._fieldTable(
                      [ label, labelText ]
                    );

    this.content.append( fields );

  }

  /**
   * Render the Placeholder type Editor
   */
  _renderPlaceholder() {

    let label =       [ 'Label', this._textarea( 'label' ) ],
        placeholder = [ 'Placeholder Text', this._textarea( 'free_text' ) ],

        fields =      this._fieldTable(
                        [ label, placeholder ]
                      );

    this.content.append( fields );

  }

  /**
   * Render the Question type Editor
   */
  _renderQuestion() {

    let hasRefs = this.node.hasChildren;

    let label =    [ 'Label', this._textarea( 'label' ) ],
        qText =    [ 'Question Text', this._textarea( 'question_text' ) ],
        mapping =  [ 'Mapping', this._input( 'mapping' ) ],
        datatype = [ 'Datatype', this._select( 'datatype', this._datatypeOpts, hasRefs ) ],
        dFormat =  [ 'Format', this._input( 'format', true, hasRefs ) ],
        optional = [ 'Optional', this._checkbox( 'optional' ) ],

        fields =   this._fieldTable(
                      [ label, qText, mapping, datatype,
                        dFormat, this._completion, this._notes, optional ]
                    );

    this.content.append( fields );

  }

  /**
   * Render the TUC Reference type Editor
   */
  _renderTUCRef() {

    // Show loading message if reference data not available
    if ( typeof this.node.data.reference === 'string' ) {

      this.content.append( 'Loading reference data...' );
      return;

    }

    let parentQuestion = this.node.parent.is( 'QUESTION' );

    let identifier = [ 'Identifier', this._labelStyled(
                          this.node.data.reference.identifier
                     ) ],
        dLabel =     [ 'Default Label', this._labelStyled(
                          this.node.data.reference.label
                     ) ],
        notation =   [ 'Submission Value', this._labelStyled(
                          this.node.data.reference.notation
                     ) ],
        label =      [ 'Label', this._input( 'local_label' ) ],
        enable =     [ 'Enabled', this._checkbox( 'enabled', null, parentQuestion ) ],
        optional =   [ 'Optional', this._checkbox( 'optional' ) ],

        fields =     this._fieldTable(
                      [ identifier, dLabel, notation, label, enable, optional ]
                     );

    this.content.append( fields );

  }


  /** Shared fields / Getters **/


  /**
   * Get the shared Completion Instructions field
   * @return {array} Completion Instructions field table row definition array
   */
  get _completion() {

    return [
      'Completion Instructions',
      this._textarea( 'completion', true )
    ]

  }

  /**
   * Get the shared Notes field
   * @return {array} Notes field table row definition array
   */
  get _notes() {

    return [
      'Notes',
      this._textarea( 'note', true )
    ]

  }

  /**
   * Get the Question type datatype options map
   * @return {object} Question type datatype options definition
   */
  get _datatypeOpts() {

    return {
      'string':   { default: '20', editable: true },
      'boolean':  { editable: false },
      'integer':  { default: '3', editable: true },
      'float':    { default: '6.2', editable: true },
      'dateTime': { editable: false },
      'date':     { editable: false },
      'time':     { editable: false }
    }

  }


  /** Event listeners **/


  /**
   * Listen to changes in input fields and add them to changedFields if user edits them
   */
  _onChangeListeners() {

    let cachedValues = this._cacheEditorValues;
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

  /**
   * Question type Editor event listeners
   */
  _questionListeners() {

    // Update Editor on Question datatype select change
    this.content.find( 'select[name="datatype"]' ).on( 'change', (e) => {

      let option = $( e.target ).val(),
          props = this._datatypeOpts[option],
          value = ( this.node.data.datatype === option ?
                                this.node.data.format :
                                (props.default || '') )

      if ( this.node.hasChildren )
        props.editable = false;

      this.content.find( 'input[name="format"]' )
                  .prop( 'disabled', !props.editable )
                  .val( value )
                  .trigger( 'input' );

    }).trigger( 'change' );

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
                        .css( 'border-color', this.node.color )
                        .html( text );

  }

  /**
   * Render a textarea element with given specifications
   * @param {string} property Name of the property in the instance Node data object to edit as textarea
   * @param {boolean} wide Value representing whether the textarea should include the 'wide' cssClass, optional [default=false]
   * @param {boolean} disabled Value representing whether the textarea should be disabled, optional [default=false]
   * @return {JQuery Element} Styled textarea for appending to DOM
   */
  _textarea(property, wide = false, disabled = false) {

    let input = $( '<textarea>' ).val( this.node.data[property] )
                                 .addClass(( wide ? ' wide' : '' ))
                                 .prop( 'name', property )
                                 .prop( 'disabled', disabled )
                                 .prop( 'placeholder', 'Enter text')
                                 .css( 'border-bottom-color', this.node.color ),

        wrapper = $( '<div>' ).addClass( 'form-group' )
                              .append( input );

    return wrapper;

  }

  /**
   * Render an input element with given specifications
   * @param {string} property Name of the property in the instance Node data object to edit as input
   * @param {boolean} narrow Value representing whether the input should include the 'narrow' cssClass, optional [default=false]
   * @param {boolean} disabled Value representing whether the input should be disabled, optional [default=false]
   * @return {JQuery Element} Styled input for appending to DOM
   */
  _input(property, narrow = false, disabled = false) {

    let input = $( '<input>' ).val( this.node.data[property] )
                              .prop( 'type', 'text' )
                              .prop( 'name', property )
                              .prop( 'disabled', disabled )
                              .prop( 'placeholder', 'Enter text')
                              .addClass( (narrow ? 'narrow' : '') )
                              .css( 'border-bottom-color', this.node.color ),

        wrapper = $( '<div>' ).addClass( 'form-group' )
                              .append( input );

    return wrapper;

  }

  /**
   * Render a checkbox element with given specifications
   * @param {string} property Name of the property in the instance Node data object to edit as checkbox
   * @param {string | null} value Value to set the checkbox's checked state to, only include if different than property value, optional [default=null]
   * @param {boolean} disabled Value representing whether the checkbox should be disabled, optional [default=false]
   * @return {JQuery Element} Styled checkbox for appending to DOM
   */
  _checkbox(property, value = null, disabled = false) {

    let input = $( '<input>' ).prop( 'type', 'checkbox' )
                              .addClass( 'styled' )
                              .prop( 'checked', value === null ? this.node.data[property] : value )
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
   * @param {string} property Name of the property in the instance Node data object to edit as select
   * @param {object} options Object containing the option names as keys
   * @param {boolean} disabled Value representing whether the select should be disabled, optional [default=false]
   * @return {JQuery Element} Styled select for appending to DOM
   */
  _select(property, options = [], disabled = false) {

    let select = $( '<select>' ).prop( 'name', property )
                                .prop( 'disabled', disabled )
                                .css( 'border-bottom-color', this.node.color );

    for ( let option of Object.keys(options) ) {

      let o = $( '<option>' ).prop( 'value', option )
                             .prop( 'selected', this.node.data[property] === option )
                             .text( option );
      select.append(o);

    }

    let wrapper = $( '<div>' ).addClass( 'form-group' )
                              .append( select );

    return wrapper;

  }

  /**
   * Render a styled title for the current Node type
   * @return {JQuery Element} Styled title for appending to DOM
   */
  _editorTitle() {

    let icon = $( '<div>' ).addClass( 'ne-icon' )
                            .css( 'font-family', isCharLetter( this.node.icon ) ? 'Roboto-Bold' : 'icomoon' )
                            .html( this.node.icon ),

        title = $( '<div>' ).addClass( 'ne-title')
                            .css( 'color', this.node.color )
                            .append( icon )
                            .append( this.node.rdfName );

    return title;

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
   * Get an object with currently displayed input names & values
   * @return {object} Cache object containing the values of the displayed input, textarea and select field names & values
   */
  get _cacheEditorValues() {

    let cache = { }

    this.content.find( 'input, textarea, select' )
            .each( (i, el) => {

              let field = $(el),
                  name = field.prop( 'name' ),
                  value = field.prop( 'type' ) === 'checkbox' ?
                            field.prop( 'checked' ) : field.val().trim()

               cache[ name ] = value;

            });

    return cache;

  }

  /**
   * Get the Node update request specification
   * @return {Object} Update request specs: url & data
   */
  get _requestSpec() {

    let url = `${ this.node.rdfObject.url }/${ this.node.data.id }`,
        data = {}

    data[ this.node.rdfObject.param ] = {
      ...this.changedFields,
      form_id: this.formId
    }

    return {
      url,
      data: JSON.stringify( data )
    }

  }

  /**
   * Get the Editor's error div
   * @return {JQuery Element} Node Editor modal error div
   */
  get $error() {
    return this.modal.find( '.error' );
  }

  /**
   * Get validation rules for current Node edit fields
   * @return {Object} validation rules compatible with Validator
   */
  get _validationRules() {

    let rules = {
      label: { value: 'not-empty' },
      local_label: { value: 'not-empty' },
      mapping: { value: 'not-empty' },
      question_text: { value: 'not-empty' },
      placeholder_text: { value: 'not-empty' },
      label_text: { value: 'not-empty' }
    }

    if ( this.node.is( 'QUESTION' ) )
      delete rules.mapping

    else if ( this.node.is( 'TUC_REF' ) )
      delete rules.label

    return rules;

  }

}
