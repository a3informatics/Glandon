import { $get, $put } from 'shared/helpers/ajax'
import { renderTag } from 'shared/ui/tags'
import { alerts } from 'shared/ui/alerts'

/**
 * Concept Item Tags Editor module
 * @description Module allowing for IsoConcept Item tags to be viewed and edited
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ConceptTagsEditor {

  /**
   * Create a Concept Tags Editor instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the element
   * @param {object} params.urls Object containing the data, add, remove Concept Tag urls
   * @param {TagsManager} params.manager Tags Manager module reference
   */
   constructor({
     selector = '#concept-tags-editor',
     urls,
     manager
   }) {

    Object.assign(this, {
      selector, urls, manager
    });

    this._initialize();

  }

  /**
   * Load Concept Tags data
   */
  loadData() {

    this._loading( true, { dataLoad: true } );

    $get({
      url: this.urls.data,
      errorDiv: this.$alert,
      done: tags => this._addTags( tags ),
      always: () => this._loading( false )
    })

  }

  /**
   * Validate Tag and attach it to the Concept
   * @param {object} tag Tag data object
   */
  addTag(tag) {

    if ( !tag )
      return;

    if ( this.tags[ tag.id ] ) {
      alerts.error( 'This Tag is already used.', this.$alert );
      return;
    }

    this.executeRequest( 'add', tag );

  }

  /**
   * Validate Tag and detach it from the Concept
   * @param {string} tagId Id of the tag to remove from Concept
   */
  removeTag(tagId) {

    if ( !tagId )
      return;

    this.executeRequest( 'remove', { id: tagId } );

  }

  /**
   * Execute the server request to attach / detach Tag from Concept
   * @param {string} action Action to perform - add / remove
   * @param {object} tag Tag data object
   */
  executeRequest(action, tag) {

    this._loading( true );

    let url = this.urls[action],
        data = { iso_concept: { tag_id: tag.id } }

    $put({
      url,
      data,
      errorDiv: this.$alert,
      done: () => action === 'add' ?
          this._addTags( tag ) :
          this._removeTag( tag ),
      always: () => this._loading( false )
    });

  }

  /**
   * Get the current selected Tag data object from the Tags Manager Graph
   * @return {object | null} Tag data object ( props: id, label ), null if none selected
   */
  get selectedTag() {

    let selectedTag = this.manager.selected;

    if ( !selectedTag )
      return null;

    return {
      id: selectedTag.data.id,
      label: selectedTag.label
    }

  }


  /*** Private ***/


  /**
   * Initialize tags collection, listeners and load the initial data
   */
  _initialize() {

    this.tags = {};
    this._setListeners();
    this.loadData();

  }

  /**
   * Set event listeners, handlers
   */
  _setListeners() {

    // Tag node click, toggle Attach tag button's disbabled class
    $( this.manager.selector ).on( 'selectChanged', '.node', (e, selected) =>
          this.content.find( '#add-tag-btn' )
                      .toggleClass( 'disabled', !selected )
    );

    // Attach Tag click
    this.content.on( 'click', '#add-tag-btn', () =>
          this.addTag( this.selectedTag )
    );

    // Detach Tag click
    this.content.on( 'click', '.tag.bg-label', e =>
          this.removeTag( $( e.target ).attr( 'data-id' ) )
    );

  }

  /**
   * Add one or more Tags to the local collection and render
   * @param {object | array} tags One or more Tag data objects
   */
  _addTags(tags) {

    if ( Array.isArray( tags ) )
      tags.forEach( tag => this.tags[ tag.id ] = tag );

    else
      this.tags[ tags.id ] = tags;

    this._render();

  }

  /**
   * Remove a single Tag instance from the local collection and render
   * @param {object} tag Tag data object
   */
  _removeTag(tag) {

    delete this.tags[ tag.id ],

    this._render();

  }

  /**
   * Check if local collection contains given Tag
   * @param {object} tag Tag data object
   * @return {boolean} True if Tag is included in local collection
   */
  _hasTag(tag) {
    return this.tags[ tag.id ] != null;
  }

  /**
   * Sort and render the local Tags collection
   */
  _render() {

    this.$tags.empty();

    let tags = Object.values( this.tags );

    // No tags present, render empty message
    if ( tags.length === 0 ) {

      this.$tags.append( '<i> No tags </i>' );
      return;

    }

    tags.sort( ( a, b ) => a.label.localeCompare( b.label ) );

    // Render
    for ( let tag of tags ) {

      let $tag = renderTag( tag.label, { cssClasses: 'removable', id: tag.id } );
      this.$tags.append( $tag );

    }

  }

  /**
   * Toggle loading state of Editor
   * @param {boolean} enable Specifies the desired loading state
   */
  _loading(enable) {
    this.content.toggleClass( 'el-loading', enable );
  }

  /**
   * Get the content element
   * @return {JQuery Element} Editor content div
   */
  get content() {
    return $( this.selector );
  }

  /**
   * Get the tags wrapper element
   * @return {JQuery Element} Tags wrapper div
   */
  get $tags() {
    return this.content.find( '#tags' );
  }

  /**
   * Get the alerts div from the TagsManager instance
   * @return {JQuery Element} Alerts div
   */
  get $alert() {
    return this.manager._alertDiv;
  }

}
