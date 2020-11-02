import ModalView from 'shared/base/modal_view'

import TablePanel from 'shared/base/table_panel'
import { render as renderMenu } from 'shared/ui/context_menu'
import { dtContextMenuColumn } from 'shared/helpers/dt/dt_columns'
import { $post } from 'shared/helpers/ajax'


/**
 * Subsets Manager module
 * @description Modal-based show & create Subsets manager
 * @extends ModalView base Modal View class
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SubsetsManager extends ModalView {

  /**
   * Create a Subsets Manager instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the modal element
   * @param {string} params.conceptId ID of the target Managed Concept
   * @param {string} params.dataUrl Url to fetch Subsets data
   * @param {boolean} params.userEditPolicy Specifies whether current user is allowed to Edit
   */
   constructor({
     selector = '#subsets-manager',
     conceptId,
     dataUrl = subsetDataUrl,
     userEditPolicy
   }) {

    super({ selector });

    Object.assign(this, {
      dataUrl, conceptId, userEditPolicy
    });

    this._initialize();

  }

  /**
   * Create Subset - open the Thesaurus Picker and set its onSubmit callback
   */
  createNew() {

    if ( !this.thPicker )
      return;

    this.hide();
    this.thPicker.onSubmit = s => this._createNew( s.asIDsArray()[0] );
    this.thPicker.show();

  }


  /*** Private ***/


  /**
   * Set event listeners & handlers
   */
  _setListeners() {

    if ( this.userEditPolicy )
      this.modal.find( '#new-subset-btn' ).on( 'click', () => this.createNew() );

  }

  /**
   * Initialize the Table Panel instance with parameters
   */
  _initialize() {

    this.tp = new TablePanel({
      selector: `${ this.selector } #subsets-index-table`,
      extraColumns: this.columns,
      deferLoading: true,
      paginated: false,
      tableOptions: {
        language: { emptyTable: 'No subsets found.' }
      }
    });

    this._setListeners();

  }

  /**
   * Execute a server request to create a new Subset
   * @param {string} thesaurus ID of the thesaurus to create the subset within, optional
   */
  _createNew(thesaurus = null) {

    if ( !this.userEditPolicy )
      return;

    let url = thesaurus ?
              subsetCreateInUrl.replace( 'thId', thesaurus ) :
              subsetCreateUrl,
        data = thesaurus ?
               { thesauri: { concept_id: this.conceptId } } :
               {}

    $post({
      url, data,
      done: r => location.href = r.edit_path
    });

  }


  /*** Events ***/


  /**
   * Load data on show
   * @override parent
   */
  _onShow() {
    this.tp.loadData( this.dataUrl );
  }

  /**
   * Clear data on hide complete
   * @override parent
   */
  _onHideComplete() {
    this.tp.clear();
  }

  /**
   * Adjust columns on modal show complete
   * @override parent
   */
  _onShowComplete() {
    this.tp.table.columns.adjust();
  }


  /*** Support ***/


  /**
   * Renderer for the context menu of a single Subset item
   * @param {object} data Item data object
   * @param {int} rowNumber Item row index
   * @return {string} Rendered context menu HTML
   */
  _renderMenu(data, rowNumber) {

    let menuItems = [];

    menuItems.push({
      url: data.show_path,
      icon: 'icon-view',
      text: 'Show'
    });

    if ( this.userEditPolicy )
      menuItems.push({
        url: data.edit_path,
        icon: 'icon-edit',
        text: 'Edit',
        disabled: data.edit_path === ''
      });

    return renderMenu({
      menuId: `subset-menu-${rowNumber}`,
      menuItems,
      menuStyle: {
        side: 'left',
        color: 'blue'
      }
    });

  }

  /**
   * Get the panel column definitions
   * @return {array} DT column definitions
   */
  get columns() {

    return [
      { data: 'identifier' },
      { data: 'notation' },
      { data: 'label' },
      {
        width: '50%',
        data: 'definition'
      },
      dtContextMenuColumn( this._renderMenu.bind(this) )
    ];

  }

}
