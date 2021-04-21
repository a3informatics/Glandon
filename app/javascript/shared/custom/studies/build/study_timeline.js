import Timeline from 'shared/base/d3/timeline/timeline'
import dayjs from 'dayjs'

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
    this.render() // Only displays timeline for dev purposes, normally will be rendered after data fetched / attached so remove this line 
    
  }


  /*** Renderers ***/


  /**
   * Initialize & render Timeline and additional elements - Timepoints, Arm label
   */
  _renderTimeline() {

    super._renderTimeline()

    // Timepoints wrapping group 
    this._xAxis.append( 'g' )
               .attr( 'class', 'timepoints' )

    // Render Timepoints 
    this.graph.timepoints = this._renderTimepoints( this._mockData )

    // Render Arm label 
    this._xAxis.append( 'text' )
               .attr( 'class', 'arm-label' )
               .attr( 'dy', -20 ) 
               .text( this.armLabel )

  }

  /**
   * Render Timepoints from given data and properties
   * @param {Array} data Array of Timepoint data objects to render
   * @param {Object} props Additional props object
   * @param {integer} props.radius Timepoint radius, optional
   * @param {D3 Scale} props.scale Scale on which to render Timepoints
   * @return {D3 Selection} Rendered Timepoints in graph svg 
   */
  _renderTimepoints(data, { radius = 14, scale = this.graph.xTimeScale } = {}) {

    // Filter to Timepoints within the range of the current scale 
    data = data.filter( d => this._offsetInRange( d.offset, scale ) )

    const tps = this._timepointsG?.selectAll( 'circle' )
                                  .data( data )

    // Remove old Timepoints
    tps.exit()
       .remove()

    // Update existing Timepoints' locations
    tps.attr( 'cx', d => this._scaledOffset( d.offset, scale ) )

    // Render new Timepoints
    tps.enter()
        .append( 'circle' )
        .attr( 'class', 'timepoint' )
        .attr( 'cx', d => this._scaledOffset( d.offset, scale ) )
        .attr( 'r', radius )

    return tps

  }


  /*** Events ***/


  /**
   * Graph zoomed event, rescale axis & update timepoints
   * @return {D3 Scale} Rescaled timeScale to current zoom level and transform
   */
  _onZoom() {

    const rescaledX = super._onZoom()

    // Re-render the Timepoints on the rescaled timeScale
    this.graph.timepoints = this._renderTimepoints( this._mockData, { scale: rescaledX })
    
    return rescaledX 

  }


  /*** Getters ***/


  /**
   * Get the X-Axis Timepoints group selection from the graph svg  
   * @return {D3 Selection | undefined} X-Axis Timepoints selection or undefined if axis doesn't exist  
   */
  get _timepointsG() {
    return this._xAxis?.select( '.timepoints' )
  }


  /*** Utils & Helpers ***/


  /**
   * Convert relative Timepoint offset to absolute and get its location on given timeScale 
   * @param {integer} offset Timepoint offset in ms (relative to baseline)  
   * @param {D3 Scale} scale Scale on which locate given offset
   * @return {float} Timepoint offset as a point on given timeScale  
   */
  _scaledOffset(offset, scale = this.graph.xTimeScale) {
    return scale( dayjs( this._props.baseline ).add( dayjs( offset ) ) )
  }
  
  /**
   * Check if given Timepoint offset is within the scale's range
   * @param {integer} offset Timepoint offset in ms (relative to baseline, not absolute)  
   * @param {D3 Scale} scale Scale which to check given offset is within  
   * @return {boolean} X-Axis Timepoints selection or undefined if axis doesn't exist  
   */
  _offsetInRange(offset, scale = this.graph.xTimeScale ) {

    const [ rangeStart, rangeEnd ] = scale.range(),
          scaledOffset = this._scaledOffset( offset, scale )

    return rangeStart <= scaledOffset && scaledOffset <= rangeEnd

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

  /** Mock timepoints data for the timeline **/
  get _mockData() {
    return [
      {
        id: 1,
        offset: 3600000,
        label: 'Test TP',
        // More fields to be added 
      },
      {
        id: 2,
        offset: 6.048e8,
        label: 'Test TP 2'
      },
      {
        id: 3,
        offset: -8.95e8,
        label: 'Test TP 3'
      }
    ]
  }


}
  