import dayjs from 'dayjs'
import { renderSpinnerIn$, removeSpinnerFrom$ } from 'shared/ui/spinners'
import { $get } from 'shared/helpers/ajax'

/**
 * D3 Timeline Class
 * @description Extensible D3-based Timeline Graph module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class Timeline {
  
  /**
   * Create a Timeline instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique selector of the timeline wrapper
   * @param {string} params.dataUrl Url to fetch the timeline data from
   * @param {boolean} params.zoomable Determines whether the timeline can be zoomed, optional [default=true]
   * @param {boolean} params.centerVertically Specifies if timeline should be vertically centered in parent, optional [default=false]
   * @param {boolean} params.deferLoading Specifies if data load request should be deferred, optional [default=false]
   * @param {function} params.onDataLoaded Data load completed callback, receives raw data as first argument, optional
   * @param {Object} args Further arguments assigned to instance, optional
   */
  constructor({
    selector = '#timeline-container',
    dataUrl,
    zoomable = true,
    centerVertically = false,
    deferLoading = false,
    onDataLoaded = () => {}
  } = {}, args = {}) {

    Object.assign( this, {
      selector, dataUrl, zoomable, centerVertically, deferLoading, onDataLoaded,
      ...args 
    })

    this._loadD3()

  }

  /**
   * Fetch timeline data from the server
   * @param {string} url Source data url (overrides dataUrl), optional
   */
  loadData(url) {

    // Overwrite instance's dataUrl
    if ( url )
      this.dataUrl = url

    this._loading( true )

    // TODO: Get request, handles response
    $get({
      url: this.dataUrl,
      errorDiv: this._alertDiv,
      done: rawData => this._onDataLoaded( rawData ),
      always: () => this._loading( false )
    })

  }

  /**
   * Render the Timeline 
   * @override for custom behavior
   * @return {Timeline} This instance for method chaining
   */
  render() {

    this._renderTimeline()
    return this

  }

  
  /*** Actions ***/


  /**
   * Clears the graph object and removes the graph svg from the DOM 
   */
  clear() {

    this.graph = {}
    this.d3.select( `${ this.selector } #d3 svg` )
           .remove()

  }

  /**
   * Reset the timeline zoom to initial state  
   * @requires zoomable parameter enabled
   * @return {Timeline} This instance for method chaining
   */
   resetZoom() {

    if ( this.zoomable )
      this._resetZoom()

    return this

  }


  /*** Private ***/


  /**
   * Create instance graph object, set listeners, load data
   */
  _init() {

    this.graph = {}
    this._setListeners()

    if ( !this.deferLoading )
      this.loadData()
    
  }

  /**
   * Set event listeners & handlers
   * Should only be called once on init to prevent duplicate event binding
   */
  _setListeners() {

    // On window resize event 
    $( window ).on( 'resize', () => this._onResize() )

    // Reset graph zoom on btn click
    $( this.selector ).find( '#reset-graph' )
                      .on( 'click', () => this.resetZoom() )

  }

  /**
   * Initialize & render Timeline
   * @override for custom behavior
   */
  _renderTimeline() {

    const { 
      height, 
      margin: { top, bottom, left } 
    } = this._props.svg 

    // Initialize Zoom and SVG 
    this.graph.zoom = this._newZoom()
    this.graph.svg = this._newSVG()

    // Initialize X-Axis Scales
    this.graph.xIntervalScale = this._newIntervalScale(),
    this.graph.xTimeScale = this._newTimeScale()
        
    // Build and render X-Axis
    this.graph.svg.append( 'g' )
                  .attr( 'transform', `translate(${ left }, ${ top })` )  // Margin offsets
                  .attr( 'class', 'x-axis' )
                  .call( 
                    this._generateTicks.bind( this ),
                    this.graph.xTimeScale 
                  ) 
    
    // Vertical centering
    if ( this.centerVertically )
      this._xAxis.attr( 'transform', `translate(0, ${ ( height - (top + bottom) ) / 2 })`)


  }


  /*** Actions ***/


  /**
   * Resets zoom to initial state
   */
  _resetZoom() {
    this.graph.svg?.call( this.graph.zoom.transform, this.d3.zoomIdentity )
  }


  /*** Events ***/


  /**
   * Process and render raw timeline data from the server
   * @override for custom behavior
   * @param {Object | undefined} rawData Compatible timeline data fetched from the server
   */
  _onDataLoaded(rawData) {

    // Save reference to the raw data structure
    if ( rawData )
      this.rawData = rawData

    if ( this.onDataLoaded ) 
      this.onDataLoaded( rawData )

    this.render() 

  }

  /**
   * Window resized event, adjust scale range and reapply scaled zoom
   */
  _onResize() {

    const { width, margin: { left, right } } = this._props.svg 

    const prevRange = this.graph.xTimeScale.range(),
          newRange = [ 0, width - (left + right) ],
          ratio = newRange[1] / prevRange[1]

    // Update range
    this.graph.xTimeScale.range( newRange )

    // Build transform scaled to range difference ratio to a new zoomIdentity 
    let transform = this.d3.zoomIdentity 
    const prevTransform = this.graph.cachedTransform
    
    if ( prevTransform ) 
      transform = transform.scale( prevTransform.k )
                           .translate( 
                              prevTransform.x / prevTransform.k * ratio, 
                              prevTransform.y / prevTransform.k 
                           )

    // Apply zoom transform to svg 
    this.graph.svg?.call( this.graph.zoom.transform, transform )

  }

  /**
   * Graph zoomed event, rescale axis 
   * Extend method for custom behavior
   */
  _onZoom() {

    const transform = this.d3.event.transform,
          rescaledX = transform.rescaleX( this.graph.xTimeScale )
    
    // Cache transform state for resizing
    this.graph.cachedTransform = transform

    // Apply rescaled X 
    this._xAxis?.call(
      this._generateTicks.bind( this ),
      rescaledX
    )
    
  }


  /*** Custom Ticks ***/


  /**
   * Generator of custom Timeline Ticks
   * @param {D3 Selection} selection Current selection 
   * @param {D3 Scale} scale Current scale 
   */
  _generateTicks(selection, scale) {

    const [ t1, t2 ] = scale.ticks(),
          // Interval between ticks
          tickInterval = this._timeDiff( t1, t2, 'day' ), 
          // Convert to time unit 
          tickUnit = this.graph.xIntervalScale( tickInterval )

    // Map Tick labels to custom format 
    const customTicks = scale.ticks()
                             .map( t => this._customTickText( t, tickUnit ) )
    
    // Update axis - d3 will apply tick values based on dates
    selection.call( this.d3.axisBottom( scale ) )

    // Override the d3 default tick values with the new labels based on interval type
    this.d3.selectAll( '.tick' ).each( (t, i, elements) => this._customTick( elements[i], customTicks[i]) )  

  }

  /**
   * Customizes a single Tick instance on Timeline Axis
   * @param {Element} tickElement Tick element to customise 
   * @param {string} tickText Custom Tick text (e.g. 5 days) 
   */
  _customTick(tickElement, tickText) {

    const tick = this.d3.select( tickElement )
    const [ tickValue, tickUnit ] = tickText.split(' ')

    tick.selectAll( 'text' )
        .remove() 

    tick.append('text')
        .attr( 'dy', 30 )
        .text( tickValue )
    
    tick.append( 'text' )
        .attr( 'dy', 40 )
        .text( tickUnit )

    tick.select( 'line' )
        .attr( 'y2', 14 )

  }

  /**
   * Parse tick to custom string format (relative distance)  
   * @param {Date} tick Tick to parse
   * @param {string} unit Tick unit (year/month/day...)
   * @return {string} Tick parsed to custom value relative to the instance's baseline and given unit
   */
  _customTickText(tick, unit) {

    const tickValue = this._timeDiff( this._props.baseline, tick, unit, false )

    return `${ tickValue } ${ unit }${ Math.abs( tickValue ) === 1 ? '' : 's' }`

  }


  /** Graph utils **/


  /**
   * Get a new D3 SVG with custom size and zoom
   * Override for custom implementation
   * @param {boolean} responsive Specifies if the graph is responsive horizontally, optional [default=true]
   * @return {D3} New D3 SVG view
   */
   _newSVG(responsive = true) {

    const { width, height } = this._props.svg 

    return this.d3.select( `${ this.selector } #d3` )
                  .append( 'svg' )
                  // Dimensions
                  .attr( 'width', (responsive ? '100%' : width) )
                  .attr( 'height', height )
                  // Zoom 
                  .call( this.zoomable ? this.graph.zoom : null )
    

  }

  /**
   * Get a new D3 zoom behavior instance
   * Override for custom implementation
   * @requires zoomable enabled
   * @return {(D3 | null)} New D3 zoom behavior or null if zoomable disabled
   */
  _newZoom() {

    if ( !this.zoomable )
      return null

    const { min, max } = this._props.zoom

    return this.d3.zoom()
                  .on('zoom', () => this._onZoom() )
                  .scaleExtent([ min, max ])

  }

  /**
   * Get a new D3 TimeScale relative to instance's baseline
   * @return {D3} New D3 TimeScale 
   */
  _newTimeScale() {

    const { width, margin: { left, right } } = this._props.svg 

    // Domain start & end +- 10 days relative to baseline
    const baseline = dayjs( this._props.baseline ),
          domainStart = baseline.subtract( 10, 'day' ).toDate(),
          domainEnd = baseline.add( 10, 'day' ).toDate()

    return this.d3.scaleTime()
                  .domain([ domainStart, domainEnd ])
                  .range([ 0, width - (left + right) ])

  }

  /**
   * Get a new D3 ScaleThreshhold instance - custom interval scale
   * @return {D3} New D3 ScaleThreshold
   */
  _newIntervalScale() {

    return this.d3.scaleThreshold()
                  .domain([ 0.00069, 0.03, 1, 7, 28, 365, Infinity ])
                  .range([ 'second', 'minute', 'hour', 'day', 'week', 'month', 'year' ]) 

  } 


  /*** Getters ***/


  /**
   * Get the X-Axis selection from the graph svg  
   * @return {D3 Selection | undefined} X-Axis selection or undefined if svg doesn't exist  
   */
  get _xAxis() {
    return this.graph.svg?.select( '.x-axis' )
  }


  /*** Utils & Helpers ***/


  /**
   * Calculate time difference between two Dates in given unit
   * @param {Date} t1 First date to compare
   * @param {Date} t2 Second date to compare
   * @param {string} unit Comparison result unit (year/month/day...)
   * @param {boolean} asFloat Get difference as a float, optional [default = true]
   * @return {int | float} Difference between the two dates in a specified unit and format 
   */
  _timeDiff(t1, t2, unit, asFloat = true) {
    return dayjs( t2 ).diff( dayjs( t1 ), unit, asFloat )
  }

  /**
   * Toggle loading state of the D3 Graph
   * @param {boolean} enable Desired loading state
   */
  _loading(enable) {

    this.loading = enable
    const graph = $( this.selector ).find( '#d3' )

    graph.toggleClass( 'loading', enable )

    enable ? 
      renderSpinnerIn$( graph, 'small' ) : 
      removeSpinnerFrom$( graph )
  
  }

  /**
   * Graph properties definitions
   * Extend and override method to customize
   * @return {Object} Graph properties for svg, zoom, baseline date
   */
    get _props() {

    let props = {
      baseline: new Date(2021, 2, 1),
      container: $(this.selector),
      svg: {
        margin: {
          top: 70,
          bottom: 0,
          left: 20,
          right: 20
        },
        get width() { return props.container.width() },
        get height() { return props.container.height()  }
      },
      zoom: {
        min: 0.002,
        max: 10000
      }
    }

    return props

  }

  /**
   * Get the wrapper element for Graph alerts 
   * @return {JQuery Element} Graph alert element 
   */
  get _alertDiv() {
    return $( this.selector ).find( '#graph-alerts' )
  }

  /**
   * Load D3 modules asynchronously and init graph afterwards
   * @override for custom behavior
   */
  async _loadD3() {

    // Load D3 modules here  
    let d3 = await import( /* webpackPrefetch: true */ './d3_timeline' )
    this.d3 = d3.default

    this._init() // Call init after load 

  }

}