import colors from 'shared/ui/colors'

/**
 * Render simple circle-based Nodes in a Graph
 * @param {D3} target D3 selection to render nodes within
 * @param {Object} data Nodes data object
 * @param {boolean} selectable Specifies if Nodes are selectable
 * @param {function} onClick Node click callback, optional
 * @param {function} onDblClick Node double click callback, optional
 * @param {function} onRightClick Node right click callback, optional
 * @param {Object} props Properties containing the radius and color values, optional
 * @return {D3} Rendered D3 Nodes selection
 */
function renderNodesSimple({
    target,
    data,
    selectable = true,
    onClick = () => {},
    onDblClick = () => {},
    onRightClick = () => {},
    props = defaultProps,
}) {

  let nodes = target.selectAll( '.node' )
                    .data( data )
                    .enter()
                      .append( 'g' )
                      // Transform node to coordinates
                      .attr( 'transform', (d) => `translate(${d.y}, ${d.x})` )
                      // CSS class dependent on selected data flag
                      .attr( 'class', (d) => ((selectable && d.data.selected) ? 'node selected' : 'node') )
                      // Pointer cursor if selectable set to true
                      .style( 'cursor', selectable ? 'pointer' : 'inherit' )
                      // Events
                      .on( 'click', onClick )
                      .on( 'dblclick', onDblClick )
                      .on( 'contextmenu', onRightClick );

  // Render circles in nodes
  nodes.append( 'circle' )
       .attr( 'r', props.radius )
       .style( 'fill', props.color );

   // Render node collapsed icons
   nodes.append( 'text' )
        .attr( 'x', props.radius - 4 )
        .attr( 'y', -props.radius )
        .text( '\ue93e' )
        .style( 'font-family', 'icomoon' )
        .style( 'font-size', '6pt' )
        // Only display if node's children are collapsed
        .style( 'display', (d) => d._children ? 'block' : 'none' )
        .style( 'fill', colors.greyLight );

    return nodes;

}

const defaultProps = {
  radius: 10,
  color: colors.primaryLight,
}

export {
  defaultProps,
  renderNodesSimple
}
