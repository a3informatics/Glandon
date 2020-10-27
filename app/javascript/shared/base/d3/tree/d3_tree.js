import {
  select,
  selectAll,
  event
} from 'd3-selection'

import {
  hierarchy,
  tree
} from 'd3-hierarchy'

import {
  zoom,
  zoomIdentity
} from 'd3-zoom'


export default {
  select,
  selectAll,
  get event() { return event; },
  hierarchy,
  tree,
  zoom,
  zoomIdentity
}
