import CLEditor from 'shared/custom/thesauri/managed_concepts/code_list_editor'

import { $confirm } from 'shared/helpers/confirmable'
import { alerts } from 'shared/ui/alerts'

/**
 * Extension Editor
 * @description DataTable-based Editor of an Extension Code List
 * @extends CLEditor module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ExtensionEditor extends CLEditor {

  /**
   * Create an Extension Editor
   * @param {Object} params Instance parameters
   * @param {string} params.id ID of the currently edited item
   * @param {object} params.urls Must contain urls for 'data', 'update', 'newChild', 'addChildren' and 'newChildSynonym'
   * @param {string} params.selector JQuery selector of the target table
   * @param {function} params.onEdited Callback for Timer extend called on any Edit action
   */
  constructor({
    id,
    urls,
    selector = "#extension-editor #editor",
    onEdited = () => {}
  }) {

    super({
      id, selector, urls, onEdited,
      helpDialogId: 'extension-edit'
    });

  }

  /**
   * Add one or more existing Code List Items to Code List
   * @param {Array} childrenIds Set of Unmanaged Concept IDs to be added to Code List
   * @param {string} param Name of the UC IDs parameter
   */
  addChildren(childrenIds, param) {
    super.addChildren( childrenIds, 'extension_ids' );
  }

  /**
   * Override removeChild in parent, check if deletion allowed
   * @param {DataTable Row} childRow Reference to the DT Row instance to be removed
   */
  removeChild(childRow) {

    childRow.data().delete === true ?
        super.removeChild( childRow ) :
        alerts.error( 'This item cannot be removed as it is native to the extension.');

  }

  /**
   * Create new children in Extension based on given Item's synonyms
   * @param {object} item Data object of the Item to base new children on
   * @requires confirmable user confirmation
   */
  newItemsFromSynonyms(item) {

    // Check nifs enabled
    if ( !this.nifsEnabled )
      return;

    // Toggle nifs UI state to disabled
    this._toggleNifs( false );

    let synonyms = item.synonym.split(';'),
        count = synonyms[0] ? synonyms.length : 0;

    // Item has no synonyms
    if ( count < 1 ) {
      alerts.warning( 'Selected item has no synonyms.');
      return;
    }

    // User confirmation and request execution
    $confirm({
      subtitle: `${count} new item(s) will be created in this extension based
                 on the selected synonyms.`,
      callback: () => this._executeRequest({
        url: this.urls.newChildSynonym,
        type: 'POST',
        data: { reference_id: item.id },
        callback: () => this.refresh()
      })
    });

  }


  /** Private **/


  /**
   * Sets event listeners, handlers
   */
  _setListeners() {

    super._setListeners();

    // New Items from synonyms enable
    $( '#nifs-button' ).on( 'click', () => this._toggleNifs( true ) );

    // New Items from synonyms cancel
    $( '#nifs-cancel' ).on( 'click', () => this._toggleNifs( false ) );

    // New Items from synonyms select row
    $( this.selector ).on( 'click', 'tbody tr', e => {

      if ( this.nifsEnabled )
        this.newItemsFromSynonyms( this._getRowDataFrom$( e.target ) );

    });

  }

  /**
   * Toggle the UI state of NIFS mode (New Items From Synonyms)
   * @param {boolean} enable Specifies the target state, true ~ enabled
   */
  _toggleNifs(enable) {

    this.nifsEnabled = enable;

    $( '#nifs-help' ).toggle( enable );
    $( '#extension-editor .btns-wrap .btn' ).toggleClass( 'disabled', enable );
    $( this.selector ).find( 'tbody' )
                      .css( 'cursor', enable ? 'crosshair' : 'initial' );

  }

}
