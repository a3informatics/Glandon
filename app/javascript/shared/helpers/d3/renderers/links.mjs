/**
 * Render simple Links in a Graph
 * @param {D3} target D3 selection to render links within
 * @param {Object} data Links data object
 * @param {Object} props Properties containing the width and color values, optional
 * @return {D3} Rendered D3 Links selection
 */
function renderSimpleLinks({
  target,
  data,
  props = defaultProps
}) {

  return target.selectAll( '.link' )
               .data( data )
               .enter()
                  .append( 'line' )
                  .attr( 'class', 'link' )
                  .style( 'stroke', props.color )
                  .style( 'stroke-width', props.width );

}

/**
 * Render simple Links in a Tree Graph
 * @param {D3} target D3 selection to render links within
 * @param {Object} data Links data object
 * @param {Object} props Properties containing the width and color values, optional
 * @return {D3} Rendered D3 Links selection
 */
function renderTreeLinks({
    target,
    data,
    props = defaultProps
}) {

  return target.selectAll( '.link' )
               .data( data )
               .enter()
                .append( 'path' )
                .attr( 'class', 'link' )
                // Link styles
                .style( 'fill', 'none' )
                .style( 'stroke-width', props.width )
                .style( 'stroke', props.color )
                // Link curve definition
                .attr( 'd', (d) => `M ${ d.y }, ${ d.x } C ${ (d.y + d.parent.y) / 2 },` +
                                   `${ d.x } ${ (d.y + d.parent.y) / 2 }, ` +
                                   `${ d.parent.x } ${ d.parent.y }, ${ d.parent.x}` );

}

const defaultProps = {
  width: 1.5,
  color: '#ddd'
}

export {
  defaultProps,
  renderSimpleLinks,
  renderTreeLinks
}
