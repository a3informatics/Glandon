import ModalView from 'shared/base/modal_view'
import ItemsPicker from 'shared/ui/items_picker/v2/items_picker' 
import { managedItemRef } from 'shared/ui/strings'

export default class EndpointEditor extends ModalView {

  constructor({
    formatText = () => {}
  }) {

    super({
      selector: '#edit-endpoint-modal'
    }, { formatText })

    this._setListeners()
    this._initPicker() 

  }

  edit(endpoint) {

    Object.assign( this, { endpoint })
    this.show()

  }

  _onShow() {

    this.modal.find( '#endpoint-label' ).html( this.endpoint.type )
    this.modal.find( '#endpoint-text' ).html( this.formatText( this.endpoint.text ) )
    this.modal.find( '#timepoint-value' ).val(0)
    this.modal.find( '#timepoint-unit' ).val('days')
    this.modal.find( '#endpoint-reference' ).html( 'None' )

  }

  _setListeners() {

    this.modal.find( '#endpoint-reference' ).click( () => this.picker.show() )

  }

  _initPicker() {

    this.picker = new ItemsPicker({
      id: `endpoint-ref-item`,
      types: [ ItemsPicker.allTypes.BC, ItemsPicker.allTypes.ASSESSMENT, ItemsPicker.allTypes.FORM ],
      onSubmit: s => this.modal.find( '#endpoint-reference' ).html( managedItemRef( s.asObjects()[0] ))
    })

  }

}