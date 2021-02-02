import ModalView from 'shared/base/modal_view'
import ManagedItemsPanel from 'shared/custom/iso_managed/managed_items_panel'

import { $get } from 'shared/helpers/ajax'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'
import { dtTrueFalseColumn } from 'shared/helpers/dt/dt_columns'

/**
 * Status Impact Modal module
 * @description Modal-based view of items impacted by item state change
 * @extends ModalView module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class StatusImpactModal extends ModalView {

  /**
   * Create a Status Panel instance
   * @param {string} selector Modal element selector 
   * @param {string} dataUrl Data src url  
   */
  constructor({
    selector = '#state-change-impact-modal',
    dataUrl
  } = {}) {

    super({ selector }, { 
      dataUrl,
      param: 'iso_managed'
    })

    this.panel = this._initPanel()

  }

  /**
   * Show modal, attach action & handler to instance
   * @param {string} action Change state action 'fast_forward' / 'rewind'
   * @param {function} onConfirm User confirm impact callback   
   */
  show({
    action,
    onConfirm = () => {} 
  }){

    Object.assign( this, { action, onConfirm })
    super.show()

  }

  /**
   * Load and render data in Managed Items Panel 
   */
  load() {

    this._loading( true )

    $get({
      url: this.dataUrl,
      data: {
        [ this.param ]: { action: this.action }
      },
      done: data => this.panel._render( data, true ),
      always: () => {

        this._loading( false )
        // Disable Confirm button if not cleared to proceed 
        this.modal.find( '#modal-submit' )
                  .toggleClass( 'disabled', !this.allClear )
                  
      }
    })

  }

  /**
   * Confirm and execute callback if checks pass, hide self 
   */
  confirm() {

    if ( !this.allClear || this.panel.isProcessing )
      return 

    this.onConfirm( this.panel.table.rows().count() ) 
    this.hide()

  }

  /**
   * Check if all dependencies are clear to proceed with status update 
   * @return {boolean} True if all currently loaded items can be updated 
   */
  get allClear() {
    
    return this.panel
               .rowDataToArray
               .filter( item => item.state_update_allowed === false )
               .length === 0
              
  }


  /*** Private ***/


  /**
   * Set modal event listeners and handlers
   */
  _setModalListeners() {

    super._setModalListeners()

    // Confirm and proceed button click handler 
    this.modal.find( '#modal-submit' )
              .click( () => this.confirm() )

  }


  /*** Events ***/


  /**
   * On Modal show, adjust table columns 
   */
  _onShow() {

    this.load()

    setTimeout( () => 
      this.panel.table.columns.adjust(), 
      200 
    )
    
  }

  /**
   * Clear panel data on Modal hide 
   */
  _onHideComplete() {
    this.panel.clear()
  }


  /*** Support ***/


  /**
   * Toggle loading state of Modal & panel
   * @param {boolean} enable Target loading state 
   */
  _loading(enable) {

    this.panel._loading( enable )
    this.modal.find( '.btn' )
              .toggleClass( 'disabled', enable )

  }

  /**
   * Create a new ManagedItemsPanel instance with custom params  
   * @return {ManagedItemsPanel} New instance 
   */
  _initPanel() {

    return new ManagedItemsPanel({
      selector: this.selector,
      deferLoading: true,
      autoHeight: true,
      buttons: [ 
        csvExportBtn(), 
        excelExportBtn() 
      ],
      addedColumns: [
        { data: 'registration_status' },
        dtTrueFalseColumn( 'state_update_allowed', { orderable: false } )
      ],
      tableOptions: {
        order: [[3, 'asc']]
      }
    })

  }

}