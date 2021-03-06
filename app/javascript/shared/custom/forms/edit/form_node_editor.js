import GenericEditor from 'shared/base/generic_editor_modal'

import { isCharLetter } from 'shared/helpers/strings'
import { alerts } from 'shared/ui/alerts'

/**
 * Form Node Editor
 * @description RDF-Type based Editor of a Form Node
 * @requires FormNode module
 * @extends GenericEditor base module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class NodeEditor extends GenericEditor {

  /**
   * Create a Node Editor instance
   * @param {Object} params Instance parameters
   * @param {string} params.formId ID of the currently edited form
   * @param {Function} params.onShow Callback to execute on Editor show, optional
   * @param {Function} params.onHide Callback to execute on Editor hide, optional
   * @param {Function} params.onUpdate Callback to execute on edit submit success, optional
   */
  constructor({
    formId,
    onShow = () => {},
    onHide = () => {},
    onUpdate = () => {}
  } = {} ) {

    super({
      onUpdate, onShow, onHide
    });

    Object.assign( this, { formId });

  }

  /**
   * Set Node to this instance and show modal
   * @param {FormNode} node Node instance to Edit
   */
  edit(node) {

    if ( !node.editAllowed )
      return;

    super.edit( node );

  }


  /** Private **/


  /**
   * Submit data to the server, handle response, override rawResult parameter
   * @param {String} type Request type
   * @param {boolean} rawResult Specifies whether the request should pass raw result from the server to the callback, optional
   */
  _submit(type, rawResult = false) { 

    super._submit( type, true );

  }

  /**
   * On node update success, append updated properties and call onSubmit
   * @param {object} result Raw result object returned from the server
   */
  _onSuccess(result) {

    let { ids, data } = result;

    try {

      for ( let prop of Object.keys( this.changedFields ) ) {

        // Setting BC Property ref's enabled or optional value
        if ( this.item.is( 'BC_PROPERTY' ) && ( prop === 'enabled' || prop === 'optional' ) )
            this.item.data.has_property[prop] = data.has_property[prop];
        else
          this.item.data[prop] = data[prop];

      }

    }
    catch(e) {

      alerts.error( 'Something went wrong while updating data.' );
      return;

    }

    this.onUpdate( ids );
    this.hide();

  }


  /** Content Type Renderers **/


  /**
   * Render the Node Editor content for the current Node instance
   */
  _renderContent() {

    this.content.append( this._editorTitle() );

    if ( this.item.is( 'FORM' ) )
      this._renderForm();

    else if ( this.item.is( 'NORMAL_GROUP' ) )
      this._renderGroup();

    else if ( this.item.is( 'COMMON_GROUP' ) )
      this._renderCommon();

    else if ( this.item.is( 'BC_GROUP' ) )
      this._renderBC();

    else if ( this.item.is( 'BC_PROPERTY' ) )
      this._renderBCProperty();

    else if ( this.item.is( 'MAPPING' ) )
      this._renderMapping();

    else if ( this.item.is( 'TEXTLABEL' ) )
      this._renderTextLabel();

    else if ( this.item.is( 'PLACEHOLDER' ) )
      this._renderPlaceholder();

    else if ( this.item.is( 'COMMON_ITEM' ) )
      this._renderCommonItem();

    else if ( this.item.is( 'TUC_REF' ) )
      this._renderTUCRef();

    else if ( this.item.is( 'QUESTION' ) ) {
      this._renderQuestion();
      this._questionListeners();
    }

    super._renderContent();

  }

  /**
   * Render the Form type Editor
   */
  _renderForm() {

    let identifier = [ 'Identifier', this._labelStyled( this.item.data.has_identifier.identifier ) ],
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

    let bcRef = this.item.data.has_biomedical_concept.reference,
        bcRefAvailable = typeof bcRef === 'object';

    let bcId =    [ 'BC Identifier', this._labelStyled(
                    bcRefAvailable ? bcRef.has_identifier.identifier : 'N/A'
                  ) ],
        bcLabel = [ 'BC Label', this._labelStyled(
                    bcRefAvailable ? bcRef.label : 'N/A'
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

    let label =    [ 'Label', this._labelStyled( this.item.data.label ) ],
        enabled =  [ 'Enabled', this._checkbox( 'enabled', { value: this.item.data.has_property.enabled } ) ],
        optional = [ 'Optional', this._checkbox( 'optional', { value: this.item.data.has_property.optional } ) ],

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

    let hasRefs = this.item.hasChildren;

    let label =    [ 'Label', this._textarea( 'label' ) ],
        qText =    [ 'Question Text', this._textarea( 'question_text' ) ],
        mapping =  [ 'Mapping', this._input( 'mapping' ) ],
        datatype = [ 'Datatype', this._select( 'datatype', this._datatypeOpts, { disabled: hasRefs } ) ],
        dFormat =  [ 'Format', this._input( 'format', { narrow: true, disabled: hasRefs } ) ],
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

    let cliRef = this.item.data.reference,
        parentQuestion = this.item.parent.is( 'QUESTION' )

    // Button element that sets the label value to default value
    let labelResetBtn = this._button({ 
      text: 'Reset', 
      css: 'white sm-margin',
      onClick: () => $( label[1] ).find( 'input' )
                                  .val( cliRef.label )
                                  .trigger( 'input' ),
    })

    let identifier = [ 'Identifier', this._labelStyled(
                          cliRef.identifier || 'N/A'
                     ) ],
        dLabel =     [ 'Default Label', this._labelStyled(
                          cliRef.label || 'N/A'
                     ) ],
        notation =   [ 'Submission Value', this._labelStyled(
                          cliRef.notation || 'N/A'
                     ) ],
        label =      [ 'Label', this._input( 'local_label' ).append( labelResetBtn ) ],
        enable =     [ 'Enabled', this._checkbox( 'enabled', { disabled: parentQuestion } ) ],
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
      this._textarea( 'completion', { wide: true } )
    ]

  }

  /**
   * Get the shared Notes field
   * @return {array} Notes field table row definition array
   */
  get _notes() {

    return [
      'Notes',
      this._textarea( 'note', { wide: true } )
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
   * Question type Editor event listeners
   */
  _questionListeners() {

    // Update Editor on Question datatype select change
    this.content.find( 'select[name="datatype"]' ).on( 'change', (e) => {

      let option = $( e.target ).val(),
          props = this._datatypeOpts[option],
          value = ( this.item.data.datatype === option ?
                                this.item.data.format :
                                (props.default || '') )

      if ( this.item.hasChildren )
        props.editable = false;

      this.content.find( 'input[name="format"]' )
                  .prop( 'disabled', !props.editable )
                  .val( value )
                  .trigger( 'input' );

    }).trigger( 'change' );

  }


  /** Element Renderers **/


  /**
   * Render a styled title for the current Node type
   * @return {JQuery Element} Styled title for appending to DOM
   */
  _editorTitle() {

    let icon = $( '<div>' ).addClass( 'ge-icon' )
                            .css( 'font-family', isCharLetter( this.item.icon ) ? 'Roboto-Bold' : 'icomoon' )
                            .html( this.item.icon ),

        title = $( '<div>' ).addClass( 'ge-title')
                            .css( 'color', this._colorAccent )
                            .append( icon )
                            .append( this.item.rdfName );

    return title;

  }


  /** Utilities **/


  /**
   * Get the Item's color accent
   * @return {string} Item accent color-code
   */
  get _colorAccent() {
    return this.item.color;
  }

  /**
   * Get the Node update request specification
   * @return {Object} Update request specs: url & data
   */
  get _requestSpec() {

    let url = `${ this.item.rdfObject.url }/${ this.item.data.id }`,
        data = {}

    data[ this.item.rdfObject.param ] = {
      ...this.changedFields,
      form_id: this.formId
    }

    return {
      url,
      data: JSON.stringify( data )
    }

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

    if ( this.item.is( 'QUESTION' ) )
      delete rules.mapping

    else if ( this.item.is( 'TUC_REF' ) )
      delete rules.label

    return rules;

  }

}
