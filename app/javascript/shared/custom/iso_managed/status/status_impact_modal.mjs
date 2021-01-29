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

  constructor({
    selector = '#state-change-impact-modal',
    dataUrl
  } = {}) {

    super({ selector }, { 
      dataUrl,
      param: 'iso_managed'
    })

    this.mip = new ManagedItemsPanel({
      selector,
      deferLoading: true,
      buttons: [ csvExportBtn(), excelExportBtn() ],
      autoHeight: true,
      addedColumns: [
        { data: 'registration_status' },
        dtTrueFalseColumn( 'state_update_allowed', { orderable: false } )
      ]
    })

  }

  show({
    action,
    onConfirm = () => {} 
  }){

    Object.assign( this, { action, onConfirm })
    super.show()

  }

  load() {

    // this._loading( true )

    // $get({
    //   url: this.dataUrl,
    //   data: {
    //     [ this.param ]: {
    //       action: this.action
    //     }
    //   },
    //   done: data => this.mngItemsPanel._render( data, true ),
    //   always: () => this._loading( false )
    // })
    
    this.mip._render( this.data, true )

    this.modal.find( '#modal-submit' )
              .toggleClass( 'disabled', !this.bulkUpdateAllowed )
    
  
  }

  confirm() {

    if ( !this.bulkUpdateAllowed || this.mip.isProcessing )
      return 

    this.onConfirm() 
    this.hide()

  }

  get bulkUpdateAllowed() {
    
    return this.mip
               .rowDataToArray
               .filter( item => item.state_update_allowed === false )
               .length === 0
              
  }


  /*** Private ***/


  _setModalListeners() {

    super._setModalListeners()

    this.modal.find( '#modal-submit' )
              .click( () => this.confirm() )

  }


  /*** Events ***/


  _onShow() {

    this.load()

    setTimeout( () => 
      this.mip.table.columns.adjust(), 
      200 
    )
    
  }

  _onHideComplete() {
    this.mip.clear()
  }


  /*** Support ***/


  _loading(enable) {

    this.mip._loading( enable )
    this.modal.find( '.btn' )
              .toggleClass( 'disabled', enable )

  }

  get data() {
    return [
      {
        id: '12345',
        identifier: 'C123456',
        label: 'Label',
        semantic_version: '1.2.3',
        version_label: 'V Label',
        owner: 'S-cubed',
        registration_status: 'Standard',
        rdf_type: 'http://www.assero.co.uk/Thesaurus#ManagedConcept',
        state_update_allowed: true
      },
      {
        id: '12346',
        identifier: 'BMI',
        label: 'BC Label',
        semantic_version: '1.0.0',
        version_label: 'V Label BC',
        owner: 'S-cubed',
        registration_status: 'Incomplete',
        rdf_type: 'http://www.assero.co.uk/BiomedicalConcept#BiomedicalConceptInstance',
        state_update_allowed: false
      }
    ]
  }

}