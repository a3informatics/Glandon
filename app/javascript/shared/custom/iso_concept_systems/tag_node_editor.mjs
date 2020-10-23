import GenericEditor from 'shared/base/generic_editor_modal'

import TagNode from 'shared/custom/iso_concept_systems/d3/tag_node'
import Validator from 'shared/ui/validator'

import { $ajax } from 'shared/helpers/ajax'
import { alerts } from 'shared/ui/alerts'
import { $confirm } from 'shared/helpers/confirmable'

/**
 * Tag Node Editor
 * @description Modal-based Editor of a Tag Node
 * @requires TagNode module
 * @extends GenericEditor base module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TagEditor extends GenericEditor {

  /**
   * Create a Tag Node Editor instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the tag node editor
   * @param {Object} params.urls Urls for tag actions (create, update)
   * @param {Function} params.onLoading Callback to execute on Loading state toggle, optional
   * @param {Function} params.onShow Callback to execute on Editor show, optional
   * @param {Function} params.onHide Callback to execute on Editor hide, optional
   * @param {Function} params.onUpdate Callback to execute on Editor submit success, optional
   */
  constructor({
    selector,
    urls,
    onLoading = () => {},
    onShow = () => {},
    onHide = () => {},
    onUpdate = () => {}
  }) {

    super({
      selector, onUpdate, onShow, onHide
    });

    Object.assign( this, {
      onLoading, urls
    });

  }

  /**
   * Edit a Tag Node; set parameters and show modal
   * @param {TagNode} tag Tag instance to Edit
   */
  edit(tag) {

    if ( !tag.editAllowed )
      return;

    this.type = 'edit';
    this.setTitle('Edit Tag')
        .setTitleIcon('icon-edit')
        .setSubmitText( 'Save changes' );

    super.edit( tag );

  }

  /**
   * Create a new Tag within given Tag Node; set parameters and show modal
   * @param {TagNode} tag Tag instance to Add a child tag to
   */
  addTag(tag) {

    this.type = 'add';
    this.setTitle('Add Tag')
        .setTitleIcon('icon-tag')
        .setSubmitText( 'Submit' );

    super.edit( tag );

  }

  /**
   * Remove Tag Node upon user confirmation
   * @param {TagNode} tag Node instance to remove
   */
  remove(tag) {

    if ( !tag || !tag.removeAllowed )
      return;

    this.item = tag;
    this.type = 'remove';

    $confirm({
      callback: () => this.submit( 'DELETE' ),
      dangerous: true,
      subtitle: 'This Tag will be deleted only if it is not used.'
    });

  }

  /**
   * Calls the parent submit with respective request type
   * @extends submit parent implementation
   */
  submit() {

    if ( this.type === 'add' )
      super.submit( 'POST' );

    else if ( this.type === 'edit' )
      super.submit( 'PUT' );

    else if ( this.type === 'remove' )
      super._submit( 'DELETE' );

  }


  /** Private **/


  /**
   * On Submit request success, handle data updates and execute onUpdate callback
   */
  _onSuccess(data) {

    switch ( this.type ) {

      case 'edit':
        this.item.update( data );
        this.onUpdate( 'Tag updated successfully.' );
        break;

      case 'add':
        this.item.addChild( data );
        this.onUpdate( 'Tag created successfully.' );
        break;

      case 'remove':
        this.item.parent.removeChild( this.item );
        this.onUpdate( 'Tag deleted successfully.' );
        break;

    }

    this.hide(); // Hide modal if shown

  }


  /** Content Renderers **/


  /**
   * Render the Node Editor content for the current action type
   * @extends _renderContent parent implementation
   */
  _renderContent() {

    if ( this.type === 'edit' ) {
      this.content.append( this._editorTitle() );
      this._renderEditFields();
    }

    else if ( this.type === 'add' )
      this._renderAddTagFields();

    super._renderContent();

  }

  /**
   * Render and pre-fill the Edit Tag fields
   */
  _renderEditFields() {

    let label =       [ 'Label', this._input( 'label', { value: this.item.label } ) ],
        description = [ 'Description', this._textarea( 'description', { wide: true } ) ],

        fields =      this._fieldTable( [ label, description ] );

    this.content.append( fields );

  }

  /**
   * Render the Add Tag fields
   */
  _renderAddTagFields() {

    let label =       [ 'Label', this._input( 'label', { value: '' } ) ],
        description = [ 'Description', this._textarea( 'description', { value: '', wide: true } ) ],

        fields =      this._fieldTable( [ label, description ] );

    this.content.append( fields );

  }

  /**
   * Render a styled title for the current Node
   * @return {JQuery Element} Styled title for appending to DOM
   */
  _editorTitle() {

    let icon = $( '<div>' ).addClass( 'ge-icon icon-tag' );

    let title = $( '<div>' ).addClass( 'ge-title')
                            .css( 'color', this._colorAccent )
                            .append( icon )
                            .append( this.item.label );

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
   * Get the Editor's error div
   * @return {JQuery Element} Editor modal error div or Tags Manager error div when removing tag
   */
  get $error() {

    if ( this.type === 'remove' )
      return $( '#graph-alerts' );

    return super.$error;

  }

  /**
   * Toggle Editor's loading state
   * @param {boolean} enable Value representing the target loading state
   */
  _loading(enable) {

    this.onLoading( enable );
    super._loading( enable );

  }

  /**
   * Get the Node update request specification depending on action type (add / edit / remove)
   * @return {Object} Update request specs: url & data
   */
  get _requestSpec() {

    let url,
        data = {};

    if ( this.type === 'add' )
      url = this.urls.create;

    if ( this.type === 'edit' || this.type === 'remove' )
      url = this.urls.update;

    if ( this.type === 'edit' || this.type === 'add' )
      data.iso_concept_systems_node = { ...this._allEditorValues }

    return {
      url: url.replace( 'tagID', this.item.data.id ),
      data: JSON.stringify( data )
    }

  }

  /**
   * Get validation rules for current Node edit fields
   * @return {Object} validation rules compatible with Validator
   */
  get _validationRules() {

    return {
      label: {
        value: 'not-empty',
        'max-length': 30
      },
      description: {
        value: 'not-empty',
        'max-length': 500
      }
    }

  }

}
