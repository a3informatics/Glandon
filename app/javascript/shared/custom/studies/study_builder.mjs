import StudyDesign from 'shared/custom/studies/study_design'
import StudyTable from 'shared/custom/studies/study_table'
import ItemsPicker from 'shared/ui/items_picker/items_picker'

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

    $( this.selector ).on( 'tab-switch', (e, tabId) => {

      let tabName = tabId.split('-')[1],
          enabled = this.tabs[ tabName ].enabled,
          instance = this.tabs[ tabName ].instance;

      enabled && instance.show();

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
        instance: new StudyMatrix(ItemsPicker),
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
        instance: new StudyTable({
          type: 'objectives',
          selector: '#study-objectives #objectives',
          url: objectivesUrl
        }),
        header: $( '#tab-objectives' ),
        enabled: true
      },
      endpoints: {
        instance: new StudyTable({
          type: 'endpoints',
          selector: '#study-endpoints #endpoints',
          url: endpointsUrl
        }),
        header: $( '#tab-endpoints' ),
        enabled: true
      }
    }

    if ( !tabs.design.enabled )
      tabs.design.header.addClass('disabled');

    return tabs;

  }

}
