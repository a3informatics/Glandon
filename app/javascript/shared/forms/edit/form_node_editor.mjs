import ModalView from 'shared/base/modal_view'

import { $post } from 'shared/helpers/ajax'
import { rdfTypesMap as rdfs } from 'shared/helpers/rdf_types'
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
   * @param {string} params.selector JQuery selector of the node editor view
   * @param {Function} params.onEdited Callback to execute on node edit, optional
   */
  constructor({
    selector = "#node-editor",
    onEdited = () => {}
  } = {} ) {

    super( { selector } );

    Object.assign( this, { onEdited } );

  }

  /**
   * Edit a Node instance and show
   * @param {FormNode} node Node instance to Edit
   */
  edit(node) {

    if ( !node )
      return;

    this.node = node;
    this.show();

  }

  reset() {

    this.div.empty();
    $(this.selector).find('.modal-footer .btn')
                    .show();

  }

  render() {

    this.reset();
    this._renderContent();

  }

  /**
   * Get the Node Editor content div
   * @return {JQuery Element} Editor content div
   */
  get div() {
    return $(this.selector).find('.ne-content');
  }


  /** Private **/


  /**
   * Set event listeners, handlers
   */
  _setListeners() {

  }

  /**
   * Render content on modal show
   * @override parent
   */
  _onShow() {
    this.render();
  }

  /**
   * Render the Node Editor content for the current Node instance
   * @override parent
   */
  _renderContent() {

    this.div.append( this._editorTitle() );

    switch( this.node.rdf ) {
      case rdfs.FORM.rdfType:
        this._renderForm();
        break;
      case rdfs.NORMAL_GROUP.rdfType:
        this._renderGroup();
        break;
      case rdfs.COMMON_GROUP.rdfType:
        this._renderCommon();
        break;
      case rdfs.BC_GROUP.rdfType:
        this._renderBC();
        break;
      case rdfs.BC_PROPERTY.rdfType:
        this._renderBCProperty();
        break;
      case rdfs.MAPPING.rdfType:
        this._renderMapping();
        break;
      case rdfs.TEXTLABEL.rdfType:
        this._renderTextLabel();
        break;
      case rdfs.PLACEHOLDER.rdfType:
        this._renderPlaceholder();
        break;
      case rdfs.QUESTION.rdfType:
        this._renderQuestion();
        this._questionListeners();
        break;
      case rdfs.COMMON_ITEM.rdfType:
        this._renderCommonItem();
        break;
      case rdfs.TUC_REF.rdfType:
        this._renderTUCRef();
        break;
    }

    this._onRenderComplete();

  }

  _onRenderComplete() {

    setTimeout( () => {
      this.div.find('textarea').each( (i, ta) => {
        $(ta).css( 'height', ta.scrollHeight > ta.clientHeight ? ta.scrollHeight + 5 : '');
      });
    }, 200);

  }


  /** Content Type Renderers **/


  _renderForm() {

    let identifier = [ 'Identifier', this._labelStyled( this.node.data.has_identifier.identifier ) ],
        label = [ 'Label', this._textarea( 'label' ) ],

        fields = this._fieldTable( [ identifier, label, this._completion, this._notes ] );

    this.div.append( fields );

  }

  _renderGroup() {

    let label = [ 'Label', this._textarea( 'label' ) ],
        repeating = [ 'Repeating', this._checkbox( 'repeating' ) ],
        optional = [ 'Optional', this._checkbox( 'optional' ) ],

        fields = this._fieldTable([ label, this._completion, this._notes,
                                    repeating, optional ]);

    this.div.append( fields );

  }

  _renderCommon() {

    let label = [ 'Label', this._textarea( 'label' ) ],
        fields = this._fieldTable([ label ]);

    this.div.append( fields );

  }

  _renderBC() {

    let label = [ 'Label', this._labelStyled( this.node.data.label ) ],
        fields = this._fieldTable([ label, this._completion, this._notes ]);

    this.div.append( fields );

  }

  _renderBCProperty() {

    let label = [ 'Label', this._labelStyled( this.node.data.label ) ],
        enabled = [ 'Enabled', this._checkbox( 'enabled', this.node.data.has_property.enabled ) ],
        optional = [ 'Optional', this._checkbox( 'optional', this.node.data.has_property.optional ) ],

        fields = this._fieldTable([ label, this._completion, this._notes,
                                    enabled, optional ]);

    this.div.append( fields );

  }

  _renderMapping() {

    let label = [ 'Label', this._textarea( 'label' ) ],
        mapping = [ 'Mapping', this._input( 'mapping' ) ],

        fields = this._fieldTable([ label, mapping ]);

    this.div.append( fields );

  }

  _renderTextLabel() {

    let label = [ 'Label', this._textarea( 'label' ) ],
        labelText = [ 'Label Text', this._textarea( 'label_text' ) ],

        fields = this._fieldTable([ label, labelText ]);

    this.div.append( fields );

  }

  _renderPlaceholder() {

    let label = [ 'Label', this._textarea( 'label' ) ],
        placeholder = [ 'Placeholder Text', this._textarea( 'free_text' ) ],

        fields = this._fieldTable([ label, placeholder ]);

    this.div.append( fields );

  }

  _renderQuestion() {

    let hasRefs = this.node.hasChildren;

    let label = [ 'Label', this._textarea( 'label' ) ],
        qText = [ 'Question Text', this._textarea( 'question_text' ) ],
        mapping = [ 'Mapping', this._input( 'mapping' ) ],
        datatype = [ 'Datatype', this._select( 'datatype', this._datatypeOpts, null, hasRefs ) ],
        datatypeFormat = [ 'Format', this._input( 'format', true, hasRefs ) ],
        optional = [ 'Optional', this._checkbox( 'optional' ) ],

        fields = this._fieldTable([ label, qText, mapping, datatype, datatypeFormat,
                                    this._completion, this._notes, optional ]);

    this.div.append( fields );

  }

  _renderCommonItem() {

    let label =  [ 'Label', this._labelStyled( this.node.data.label ) ],
        fields = this._fieldTable([ label ]);

    this.div.append( fields );

    // Hide Save button as node is not ediftable
    $(this.selector).find( '#editor-submit' )
                    .hide();

  }

  _renderTUCRef() {

    // Show loading message if reference data not available
    if ( !this.node.data.referenceData ) {
      this.div.append( 'Loading reference data...' );
      return;
    }

    const qIsParent = this.node.parent.rdf === rdfs.QUESTION.rdfType;

    let identifier = [ 'Identifier', this._labelStyled( this.node.data.referenceData.identifier ) ],
        defLabel =  [ 'Default Label', this._labelStyled( this.node.data.referenceData.label ) ],
        submission = [ 'Submission Value', this._labelStyled( this.node.data.referenceData.notation ) ],
        label = [ 'Label', this._input( this.node.data.label ) ],
        enable = [ 'Enabled', this._checkbox( 'enabled', null, qIsParent ) ],
        optional = [ 'Optional', this._checkbox( 'optional' ) ],

        fields = this._fieldTable([ identifier, defLabel, submission, label,
                                    enable, optional ]);

    this.div.append( fields );

  }


  /** Event listeners **/


  _questionListeners() {

    this.div.find( 'select[name="datatype"]' ).on( 'change', (e) => {

      let option = $( e.target ).val(),
          props = this._datatypeOpts[option],
          value = ( this.node.data.datatype === option ?
                                this.node.data.format :
                                (props.default || '') )

      this.div.find( 'input[name="format"]' ).prop( 'disabled', !props.editable )
                                             .val( value );

    } );

  }


  /** Shared fields **/

  get _completion() {
    return [ 'Completion Instructions', this._textarea( 'completion', true ) ]
  }

  get _notes() {
    return [ 'Notes', this._textarea( 'notes', true ) ]
  }

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


  /** Element Renderers **/


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

  _labelStyled(text) {

    return $( '<span>' ).addClass( 'label-styled' )
                        .css( 'border-color', this.node.color )
                        .html( text );

  }

  _textarea(property, wide = false, disabled = false) {

    let input = $( '<textarea>' ).val( this.node.data[property] )
                                 .addClass(( wide ? ' wide' : '' ))
                                 .prop( 'name', property )
                                 .prop( 'disabled', disabled )
                                 .prop( 'placeholder', 'Enter text')
                                 .css( 'border-bottom-color', this.node.color ),

        wrapper = $( '<div>' ).addClass( 'ne-field' )
                              .append( input );

    return wrapper;

  }

  _input(property, narrow = false, disabled = false) {

    let input = $( '<input>' ).val( this.node.data[property] )
                              .prop( 'type', 'text' )
                              .prop( 'name', property )
                              .prop( 'disabled', disabled )
                              .prop( 'placeholder', 'Enter text')
                              .addClass( (narrow ? 'narrow' : '') )
                              .css( 'border-bottom-color', this.node.color ),

        wrapper = $( '<div>' ).addClass( 'ne-field' )
                              .append( input );

    return wrapper;

  }

  _checkbox(property, value = null, disabled = false) {

    let input = $( '<input>' ).prop( 'type', 'checkbox' )
                              .addClass( 'styled' )
                              .prop( 'checked', value === null ? this.node.data[property] : value )
                              .prop( 'disabled', disabled )
                              .prop( 'name', property ),

        styledInput = $( '<span>' ).addClass( 'checkbox-styled green' ),

        wrapper = $( '<label>' ).append( input )
                                .append( styledInput );

    return wrapper;

  }

  _select(property, options = [], value = null, disabled = false) {

    let select = $( '<select>' ).prop( 'name', property )
                                .prop( 'disabled', disabled )
                                .css( 'border-bottom-color', this.node.color );

    for ( let option of Object.keys(options) ) {

      let o = $( '<option>' ).prop( 'value', option )
                             .prop( 'selected', this.node.data[property] === option )
                             .text( option );
      select.append(o);

    }

    let wrapper = $( '<div>' ).addClass( 'ne-field' )
                              .append( select );

    return wrapper;

  }

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

  _loading(enable) {

    this.div.toggleClass( 'loading', enable );

    this.modal.find( '.btn' )
              .toggleClass( 'disabled', enable )
              .filter( '#editor-submit' )
                .toggleClass( 'el-loading', enable );

  }

}
