import {
  select,
  selectAll,
  event
} from 'd3-selection'

import {
  zoom,
  zoomIdentity
} from 'd3-zoom'

import { 
  axisBottom
} from 'd3-axis'

import { 
  scaleThreshold,
  scaleTime
} from 'd3-scale'

export default
{
  select,
  selectAll,
  get event() { return event; },
  zoom,
  zoomIdentity,
  axisBottom,
  scaleThreshold,
  scaleTime
}
