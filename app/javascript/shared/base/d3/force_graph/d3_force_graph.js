import {
    select,
    selectAll,
    event
  } from 'd3-selection'
  
  import * as force from 'd3-force'
  
  import {
    zoom,
    zoomIdentity
  } from 'd3-zoom'
  
  export default
  {
    select,
    selectAll,
    get event() { return event; },
    zoom,
    zoomIdentity,
    ...force
  }
  