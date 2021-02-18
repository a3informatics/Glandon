import GenericEditor from 'shared/base/generic_editor_modal'

import colors from 'shared/ui/colors'

/**
 * Managed Concept Properties Editor
 * @description Modal-based Editor of properties of a Managed Concept
 * @extends GenericEditor base module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class PropertiesEditor extends GenericEditor {

  /**
   * Create a Properties Editor instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the Editor modal
   * @param {Object} params.data Item property data object
   * @param {Function} params.onUpdate Callback to execute on submit success, page refresh by default, optional
   */
  constructor({
    selector = '#edit-properties-modal',
    data,
    onUpdate = null
  }) {

    super({
      selector, onUpdate
    });

    Object.assign( this, {
      item: { data },
      updateUrl: editItemPropertiesUpdateUrl
    });

  }

  /**
   * Validate data and submit data to server on validation success
   * @param {String} type Request type
   */
  submit(type) { 
    super.submit( 'PATCH' );
  }


  /** Private **/


  /**
   * Render the Node Editor content for the current action type
   * @extends _renderContent parent implementation
   */
  _renderContent() {

    this.content.append( this._editorTitle() );
    this._renderEditFields();

    super._renderContent();

  }

  /**
   * Render and pre-fill the Editor fields
   */
  _renderEditFields() {

    let notation =   [ 'Submission value', this._textarea( 'notation' ) ],
        prefTerm =   [ 'Preferred term', this._textarea( 'preferred_term' ) ],
        synonyms =   [ 'Synonyms', this._textarea( 'synonym' ) ],
        definition = [ 'Definition', this._textarea( 'definition', { wide: true } ) ],

        fields =      this._fieldTable( [ notation, prefTerm, synonyms, definition ] );

    this.content.append( fields );

  }

  /**
   * Render a styled title for the current item
   * @return {JQuery Element} Styled title for appending to DOM
   */
  _editorTitle() {

    let icon = $( '<div>' ).addClass( 'ge-icon icon-codelist' );

    let title = $( '<div>' ).addClass( 'ge-title')
                            .css( 'color', colors.primaryBright )
                            .append( icon )
                            .append( this.item.data.identifier );

    return title;

  }


  /** Events **/


  /**

   * On item update success call onUpdate or reload page
   */
  _onSuccess(data) {

    if ( this.onUpdate )
      this.onUpdate( data );
    else
      location.reload();

  }


  /** Utilities **/


  /**
   * Get the update request specification  
   * @return {Object} Update request specs: url & data
   */
  get _requestSpec() {

    return {
      url: this.updateUrl,
      data: JSON.stringify({
        edit: this.changedFields
      })
    }

  }

  /**
   * Get validation rules for current Item edit fields, override
   * @return {Object} validation rules compatible with Validator
   */
  get _validationRules() {

    return {
      notation: { value: 'not-empty' },
      preferred_term: { value: 'not-empty' }
    }

  }

}
