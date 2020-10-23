import colors from 'shared/ui/colors'
import { isCharLetter, cropText } from 'shared/helpers/strings'

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
                      // Add tabindex to node to make it focusable
                      .attr( 'tabindex', '-1' )
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
        .attr( 'class', 'collapsed-icon' )
        .text( '\ue93e' )
        .style( 'font-family', 'icomoon' )
        .style( 'font-size', '6pt' )
        // Only display if node's children are collapsed
        .style( 'display', (d) => d._children ? 'block' : 'none' )
        .style( 'fill', colors.greyLight );

    return nodes;

}

/**
 * Render icons and labels in a pre-rendered set of nodes
 * @param {D3} nodes Pre-rendered D3 Nodes selection (e.g. from renderNodesSimple)
 * @param {{string | function}} nodeIcon Defines the icon (char code or letter) for a node
 * @param {{string | function}} nodeColor Defines the color code for a node
 * @param {{string | function}} iconSize Defines the font size for a node icon
 * @param {string | function} labelProperty Specifies which Node data property should be used for the label text or specifies a text function
 * @param {function} onHover Node label hover callback, optional
 * @param {function} onHoverOut Node label hover-out callback, optional
 * @param {Object} props Properties containing the radius and color values, optional
 * @return {D3} Rendered D3 Nodes selection
 */
function renderIconsLabels({
    nodes,
    nodeIcon,
    nodeColor,
    iconSize = '20px',
    labelProperty = 'label',
    onHover = () => {},
    onHoverOut = () => {},
    props = defaultProps
}) {

  // Change Node circle fill to white for icons background
  nodes.select( 'circle' )
       .style( 'fill', '#fff' )
       .attr( 'class', 'with-icon' );

  // Render Icons
  nodes.append( 'text' )
       .attr( 'x', 0 )
       .attr( 'y', 7 )
       .text( nodeIcon )
       .attr( 'class', 'icon' )
       .attr( 'text-anchor', 'middle' ) // Character alignment
       .style( 'fill', nodeColor )
       .style( 'font-size', iconSize )
       // Icon font depending whether it is a letter or a font-icon
       .style( 'font-family', d => isCharLetter( nodeIcon( d ) ) ?
                                   'Roboto-Bold' :
                                   'icomoon'
             );

   // Render Labels
   nodes.append( 'text' )
        .attr( 'dy', 4 )
        .attr( 'dx', props.radius + 16 )
        // Crop label text or show '...' for empty labels
        .text( d => {

          if ( typeof labelProperty === 'function' )
            return labelProperty(d);

          return cropText( d.data[ labelProperty ] ) || '...';

        })
        .attr( 'class', 'label' )
        .style( 'fill', colors.greyMedium )
        .style ( 'font-size', '9pt' )
        // Events
        .on( 'mouseover mousemove', onHover )
        .on( 'mouseout', onHoverOut );

   // Render Label border
   nodes.insert( "rect", ".label" )
        .attr( 'y', -11 )
        .attr( 'x', props.radius + 4 )
        .attr( 'rx', 10 )
        .attr( 'ry', 10 )
        .attr( 'class', 'label-border' )
        .attr( 'width', function(d) { 
          return this.parentNode.getBBox().width - 12
        })
        .attr( 'height', '22px' )
        .style( 'stroke-width', '1px' )
        .style( 'stroke', colors.greyLight )
        .style( 'fill', '#fff' );

  return nodes;

}

/**
 * Render labels in a pre-rendered set of nodes
 * @param {D3} nodes Pre-rendered D3 Nodes selection (e.g. from renderNodesSimple)
 * @param {{string | function}} nodeColor Defines the color code for a node
 * @param {string | function} labelProperty Specifies which Node data property should be used for the label text or specifies a text function
 * @param {function} onHover Node label hover callback, optional
 * @param {function} onHoverOut Node label hover-out callback, optional
 * @param {Object} props Properties containing the radius and color values, optional
 * @return {D3} Rendered D3 Nodes selection
 */
function renderLabels({
    nodes,
    nodeColor,
    labelProperty = 'label',
    onHover = () => {},
    onHoverOut = () => {},
    props = defaultProps
}) {

  // Change Node circle radiu and fill
  nodes.select( 'circle' )
       .attr( 'r', props.radius )
       .style( 'fill', nodeColor )
       .attr( 'class', 'with-icon' );

 // Reposition the collapsed-icon
 nodes.select( '.collapsed-icon' )
      .attr( 'x', 2 );

 // Render Labels
 nodes.append( 'text' )
      .attr( 'dy', 4 )
      .attr( 'dx', props.radius + 14 )
      // Crop label text or show '...' for empty labels
      .text( d => {

        if ( typeof labelProperty === 'function' )
          return labelProperty(d);

        return cropText( d.data[ labelProperty ] ) || '...';

      })
      .attr( 'class', 'label' )
      .style( 'fill', colors.greyMedium )
      .style ( 'font-size', '9pt' )
      // Events
      .on( 'mouseover mousemove', onHover )
      .on( 'mouseout', onHoverOut );

   // Render Label border
   nodes.insert( "rect", ".label" )
        .attr( 'y', -11 )
        .attr( 'x', props.radius + 4 )
        .attr( 'rx', 10 )
        .attr( 'ry', 10 )
        .attr( 'class', 'label-border' )
        .attr( 'width', function(d) { 
          return $( this.parentNode ).find('.label').get(0).getBBox().width + 20;
        })
        .attr( 'height', '22px' )
        .style( 'stroke-width', '1px' )
        .style( 'stroke', nodeColor )
        .style( 'fill', '#fff' );

  return nodes;

}

const defaultProps = {
  radius: 10,
  color: colors.primaryLight,
}

export {
  defaultProps,
  renderNodesSimple,
  renderIconsLabels,
  renderLabels
}
