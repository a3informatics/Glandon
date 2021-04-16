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
      selector, dataUrl, onDataLoaded
    })

  }

}
  