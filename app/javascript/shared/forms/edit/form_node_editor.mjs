import ModalView from 'shared/base/modal_view'

import { $post } from 'shared/helpers/ajax'
import { $confirm } from 'shared/helpers/confirmable'
import { iconTypes } from 'shared/ui/icons'
// import { iconBtn } from 'shared/ui/buttons'
import { getRdfNameByType as nameFromRdf, rdfTypesMap as rdfs } from 'shared/helpers/rdf_types'
import { isCharLetter } from 'shared/helpers/strings'
// import colors from 'shared/ui/colors'

/**
 * Node Editor
 * @description D3-Graph based Editor of a Form
 * @extends ModalView base module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class NodeEditor extends ModalView {

  /**
   * Create a Form Editor instance
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
   * Set Edit Node instance and show dialog
   * @param {FormNode} node Node instance to Edit
   */
  edit(node) {

    if ( !node )
      return;

    this.node = node;
    this.show();

  }

  get div() {
    return $(this.selector).find('.ne-content');
  }


  /** Private **/


  _setListeners() {

  }

  _onShow() {
    this._renderContent();
  }

  _renderContent() {

    // Empty div contents
    this.div.empty();

    // Render item type and icon
    this.div.append( this._editorTitle() );

    switch( this.node.rdf ) {
      case rdfs.FORM.rdfType:
        this._renderForm();
        break;
      case rdfs.NORMAL_GROUP.rdfType:
        this._renderGroup();
        break;
    }

  }


  /** Content Type Renderers **/


  _renderForm() {

    let identifier = {
      label: 'Identifier',
      value: this._labelStyled( this.node.data.has_identifier.identifier )
    },
    label = {
      label: 'Label',
      value: this._textarea( this.node.data.label, 'label' )
    },
    completion = {
      label: 'Completion Instructions',
      value: this._textarea( this.node.data.completion, 'completion', true )
    },
    notes = {
      label: 'Notes',
      value: this._textarea( this.node.data.note, 'note', true )
    },
    fieldTable = this._fieldTable( [ identifier, label, completion, notes ] );

    this.div.append( fieldTable );

  }

  _renderGroup() {

    let label = {
      label: 'Label',
      value: this._textarea( this.node.data.label, 'label' )
    },
    tfProps = {
      label: '',
      value: this._checkbox( this.node.data.repeating, 'Repeating', 'repeating' )
    },
    completion = {
      label: 'Completion Instructions',
      value: this._textarea( this.node.data.completion, 'completion', true )
    },
    notes = {
      label: 'Notes',
      value: this._textarea( this.node.data.note, 'note', true )
    },
    fieldTable = this._fieldTable( [ label, tfProps, completion, notes ] );

    this.div.append( fieldTable );

  }


  /** Element Renderers **/


  _fieldTable(rows) {

    let table = $( '<table>' ).addClass( 'field-table' );

    for (let row of rows) {

      let r = $( '<tr>' );

      let labelC = $( '<td>' ).html( row.label ),
          valueC = $( '<td>' ).html( row.value );

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

  _textarea(value, dataName, wide = false, disabled = false) {

    let input = $( '<textarea>' ).val( value )
                                 .addClass(( wide ? ' wide' : '' ))
                                 .attr( 'name', dataName )
                                 .attr( 'disabled', disabled )
                                 .css( 'border-bottom-color', this.node.color ),

        wrapper = $( '<div>' ).addClass( 'ne-field' )
                              .append( input );

    return wrapper;

  }

  _input(value, dataName, disabled = false) {

    let input = $( '<input>' ).val( value )
                              .attr( 'name', dataName )
                              .attr( 'disabled', disabled )
                              .css( 'border-color', this.node.color )
                              .css( 'border-bottom-color', this.node.color ),

        wrapper = $( '<div>' ).addClass( 'ne-field' )
                              .append( input );

    return wrapper;

  }

  _checkbox(checked, text, dataName, disabled = false) {

    let input = $( '<input>' ).attr( 'type', 'checkbox' )
                              .attr( 'checked', checked)
                              .attr( 'disabled', disabled )
                              .attr( 'name', dataName ),

        label = $( '<label>' ).append( input )
                              .append( text )

    return label;

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

}
