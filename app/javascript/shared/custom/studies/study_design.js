import TabsLayout from 'shared/ui/tabs_layout'
import ItemsPicker from 'shared/ui/items_picker/items_picker'

import { $post } from 'shared/helpers/ajax'
import { managedItemRef } from 'shared/ui/strings'

/**
 * Study Design and Interventions
 * @description
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class StudyDesign {

  /**
   * Create a Modal View
   */
   constructor({
     selector = '#study-design',
     tab = '#tab-design'
   } = {}) {

     Object.assign( this, {
       selector, tab,
       picker: new ItemsPicker({
         id: 'protocol-template',
         types: ['protocol_template'],
         onSubmit: s => this._setProtocolTemplate( s.asObjectsArray()[0] )
       })
     });

     this._setListeners();

  }


  /*** Private ***/


  _setListeners() {

    $( this.selector ).find( '#select-template' )
                      .on( 'click', () => this.picker.show() );

  }

  _setProtocolTemplate(template) {

    this._loading( true );

    $post({
      url: templateUpdateUrl,
      data: {
        protocols: {
          template_id: template.id
        }
      },
      done: r => {

        $( this.selector ).find( '#template-name' )
                          .text( managedItemRef( template ) );
        $( this.selector ).find( '#select-template' )
                          .addClass( 'disabled' )
                          .unbind();

      },
      always: () => this._loading( false )
    });

  }

  _loading(enable) {
    TabsLayout.tabLoading( null, 'tab-design', enable );
  }

}
