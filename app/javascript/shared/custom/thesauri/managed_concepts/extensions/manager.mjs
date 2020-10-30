import { $post } from 'shared/helpers/ajax'
import { $confirm } from 'shared/helpers/confirmable'

/**
 * Extension Manager module
 * @description Simple module for methods aiding in creating an Extension
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ExtensionsManager {

  /**
   * Create an Extensions Manager instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the modal element
   * @param {string} params.conceptId ID of the target Managed Concept
   * @param {string} params.dataUrl Url to fetch Subsets data
   * @param {Object} params.options Specifies Extend options defined by the controller
   * @param {boolean} params.userEditPolicy Specifies whether current user is allowed to Edit
   */
   constructor({
     selector = '#extend-btn',
     conceptId,
     options,
     userEditPolicy
   }) {

    Object.assign(this, {
      selector, conceptId, options, userEditPolicy
    });

    this._setListeners();

  }

  /**
   * Create Extension, validatie
   */
  createNew() {

    if ( !this.thPicker )
      return;

    if ( this.options.allowed )
      this.openPicker();

    // Override non-extensible code lists
    else if ( this.options.override )
      $confirm({
        dangerous: true,
        subtitle: 'You are trying to Extend a Non-Extensible Code List.',
        callback: () => this.openPicker()
      });

  }

  /**
   * Open Thesaurus picker for Extension create and set callback
   */
  openPicker() {

    this.thPicker.onSubmit = s => this._createNew( s.asIDsArray()[0] );
    this.thPicker.show();

  }


  /*** Private ***/


  /**
   * Set event listeners & handlers
   */
  _setListeners() {

    if ( this.userEditPolicy )
      $( this.selector ).on( 'click', () => this.createNew() );

  }

  /**
   * Execute a server request to create a new Extension
   * @param {string} thesaurus ID of the thesaurus to create the subset within, optional
   */
  _createNew(thesaurus = null) {

    if ( !this.userEditPolicy )
      return;

    let url = thesaurus ?
              extensionCreateInUrl.replace( 'thId', thesaurus ) :
              extensionCreateUrl,
        data = thesaurus ?
               { thesauri: { concept_id: this.conceptId } } :
               {}

    $post({
      url, data,
      errorDiv: this.$error,
      done: r => location.href = r.edit_path
    });

  }

}
