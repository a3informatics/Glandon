import Timeline from 'shared/base/d3/timeline/timeline'

/**
 * Study Timeline Class
 * @description D3-based Study Timeline module
 * @extends Timeline base module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class StudyTimeline extends Timeline {

  constructor({
    selector,
    dataUrl,
    onDataLoaded = () => {}
  } = {}) {

    super({
      selector, dataUrl, onDataLoaded,
      deferLoading: true
    })

  }


  /*** Private ***/


  /**
   * Create instance graph object, set listeners, load data
   */
  _init() {

    super._init()
    this.render() // Only to display timeline for dev purposes, normally will be rendered after data fetched / attached 
    
  }
  

}
  