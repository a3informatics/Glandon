import ModalView from 'shared/base/modal_view'

import ManagedItemsPanel from 'shared/custom/iso_managed/managed_items_panel'
import { renderSpinner } from 'shared/ui/spinners'

/**
 * Tagged Items Panel module
 * @description Modal-based table showing all items tagged with given Tag
 * @extends ModalView base Modal View class
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TaggedItemsPanel extends ModalView {

  /**
   * Create a Modal View
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the modal element
   * @param {string} params.dataUrl Base data url
   * @param {function} params.onShow Callback executed when modal is shown
   * @param {function} params.onHide Callback executed when modal is hidden
   */
   constructor({
     selector = '#tagged-items-modal',
     dataUrl,
     onShow,
     onHide
   }) {

    super({ selector });

    Object.assign(this, {
      dataUrl, onShow, onHide
    });

    this._initialize();

  }

  /**
   * Show Tagged Items modal for given Tag instance
   * @param {TagNode} tag Tag to show Items for
   */
  show(tag) {

    this.tag = tag;
    this.modal.find( '#tag-name' )
              .text( tag.label )
              .css( 'color', tag.color );

    super.show();

  }


  /*** Private ***/


  /**
   * Initialize the Table Panel instance
   */
  _initialize() {

    this.tp = new ManagedItemsPanel({
      selector: this.selector,
      deferLoading: true,
      paginated: false,
      tableOptions: {
        autoWidth: true,
        scrollY: '350px',
        scrollCollapse: true,
        language: {
          infoFiltered: '',
          emptyTable: 'No items with the selected tag were found.',
          processing: renderSpinner( 'small' )
        }
      }
    });

  }


  /*** Events ***/


  /**
   * Load data on show
   * @override parent
   */
  _onShow() {

    if ( this.onShow )
      this.onShow();

    this.tp.loadData( this.taggedItemsUrl );

  }

  /**
   * On modal hide callback
   * @override parent
   */
  _onHide() {

    if ( this.onHide )
      this.onHide();

    this.tp.clear();

  }

  /**
   * Adjust columns on modal shown
   * @override parent
   */
  _onShowComplete() {
    this.tp.table.columns.adjust();
  }


  /*** Support ***/


  /**
   * Get the data url to fetch tagged items for current Tag instance
   * @return {string} Data url pointing to the current Tag id
   */
  get taggedItemsUrl() {
    return this.dataUrl.replace( 'tagId', this.tag.data.id );
  }

}
