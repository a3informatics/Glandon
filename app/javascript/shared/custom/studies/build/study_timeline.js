import Timeline from 'shared/base/d3/timeline/timeline'

/**
 * Study Timeline Class
 * @description D3-based Study Timeline module representing the data of a single Arm
 * @extends Timeline base module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class StudyTimeline extends Timeline {

  /**
   * Create a StudyTimeline instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique selector of the timeline wrapper
   * @param {string} params.dataUrl Url to fetch the timeline data from
   * @param {string} params.armLabel Label of the Arm instance which the Timeline displays
   * @param {function} params.onDataLoaded Data load completed callback, receives raw data as first argument, optional
   */
  constructor({
    selector,
    dataUrl,
    armLabel = 'High Dose',
    onDataLoaded = () => {}
  } = {}) {

    super({
      selector, dataUrl, onDataLoaded,
      deferLoading: true // Do not load data initially 
    }, {
      armLabel
    })

  }


  /*** Private ***/


  /**
   * Initializes instance deps
   */
  _init() {

    super._init()
    this.render() // Only to display timeline for dev purposes, normally will be rendered after data fetched / attached 
    
  }

  /**
   * Initialize & render Timeline and additional elements 
   */
  _renderTimeline() {

    super._renderTimeline()

    // Render Arm label 
    this._xAxis.append( 'text' )
               .attr( 'class', 'arm-label' )
               .attr( 'dy', -20 )
               .text( this.armLabel )

  }

  /**
   * Graph properties definitions
   * @return {Object} Graph properties for svg, zoom, baseline date
   */
   get _props() {

    const props = super._props

    // Offset the left side due to Arm label being rendered
    props.svg.margin.left = 40

    return props

  }


}
  