// import ItemsPicker from 'shared/ui/items_picker/items_picker'
// import { managedConceptRef } from 'shared/ui/strings'

/**
 * Create a Study Builder Instance
 * @description
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class StudyBuilder {

  /**
   * Create a Modal View
   */
   constructor({
     selector = '#study-build-tabs'
   } = {}) {

     Object.assign( this, {
       selector,
       tabs: this._initTabs()
     });

     this._setListeners();

     // Start with a default tab opened
     this.tabs.content.instance.show();

  }


  /*** Private ***/


  _setListeners() {

    $( this.selector ).find( '.tab-option' ).on( 'tab-switch', tabId => {

      let tabName = tabId.split('-')[1];

      this.tabs[ tabName ].enabled && this.tabs[ tabName ].instance.show();

    });

  }

  _initTabs() {

    let tabs = {
      content: {
        instance: new VerticalList( '#study-content-table', protocolShowUrl ),
        header: $( '#tab-content' ),
        enabled: true
      },
      timeline: {
        instance: new StudyMatrix(),
        header: $( '#tab-timeline' ),
        enabled: true
      },
      soa: {
        instance: new StudySchedule(),
        header: $( '#tab-soa' ),
        enabled: true
      },
      design: {
        instance: studyEmpty ? new StudyDesign() : null,
        header: $( '#tab-design' ),
        enabled: studyEmpty
      },
      objectives: {
        instance: new StudyObjectives(),
        header: $( '#tab-objectives' ),
        enabled: true
      },
      endpoints: {
        instance: new StudyEndpoints(),
        header: $( '#tab-endpoints' ),
        enabled: true
      }
    }

    tabs.design.header
               .toggleClass( 'disabled perm-disabled', !tabs.design.enabled );

    return tabs;

  }

}
