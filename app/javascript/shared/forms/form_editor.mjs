import TreeGraph from 'shared/base/d3/tree_graph'

import { $post } from 'shared/helpers/ajax'
import { iconTypes } from 'shared/ui/icons'
import { getRdfNameByType } from 'shared/helpers/rdf_types'
import { isCharLetter, cropText } from 'shared/helpers/strings'
import colors from 'shared/ui/colors'

/**
 * Form Editor
 * @description D3-Graph based Editor of a Form
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class FormEditor extends TreeGraph {

  /**
   * Create a Form Editor instance
   * @param {Object} params Instance parameters
   * @param {object} params.urls Must contain urls for 'data', 'update'
   * @param {string} params.selector JQuery selector of the editor panel
   * @param {function} params.onEdited Callback executed on any edit action
   */
  constructor({
    urls,
    selector = "#form-editor",
    onEdited = () => {}
  }) {

    super( { selector, dataUrl: urls.data } );

    Object.assign( this, { onEdited } );

  }

  /**
   * Clear the graph contents
   * @extends clearGraph parent implementation
   * @param {boolean} reset Specifies whether the graph should be reset completely (true) or just re-drawn (false)
   */
  clearGraph(reset) {

    super.clearGraph();
    // Remove tooltip element
    this.d3.select(`.graph-tooltip`).remove();

  }


  /** Private **/


  /**
   * Preprocess data and convert it into a D3 hierarchy
   * @override parent implementation
   * @param {Object} rawData Graph data fetched from the server
   */
  _preprocessData(rawData) {

    return this.d3.hierarchy( rawData, (d) => [
          ...d.has_group||[],
          ...d.has_biomedical_concept||[],
          ...d.has_common||[],
          ...d.has_item||[],
          ...d.has_sub_group||[]
      ] );

  }


  /** Renderers **/


  /**
   * Render tooltip in the graph
   * @override parent implementation
   */
  _renderCustom() {
    this.graph.tooltip = this._newTooltip();
  }

  /**
   * Render nodes in the tree graph based on custom properties
   * @extends _renderNodes parent implementation
   * @param {Object} nodeProps Properties object containing the node radius and color values
   * @return {D3} Rendered D3 nodes selection
   */
  _renderNodes(nodeProps) {

    // Call super's _renderNodes first
    let nodes = super._renderNodes(nodeProps);

    // Render icons
    this._renderNodeIcons(nodes, nodeProps);
    // Render labels
    this._renderNodeLabels(nodes, nodeProps)

    return nodes;

  }

  /**
   * Render and node icons by its rdf type
   * @param {D3} nodes D3 selection of nodes
   * @param {Object} nodeProps Properties object containing the node radius and color values
   */
  _renderNodeIcons(nodes, nodeProps) {

    nodes.append( 'text' )
         .attr( 'x', 0 )
         .attr( 'y', 7 )
         .attr( 'class', 'icon' )
         // Character alignment
         .attr( 'text-anchor', 'middle' )
         .text( (d) => this._nodeIcon(d) )
         .style( 'fill', (d) => this._nodeColor(d) )
         // Icon font depending whether it is a letter or a font-icon
         .style( 'font-family', (d) => isCharLetter( this._nodeIcon(d) ) ? 'Roboto-Bold' : 'icomoon' );

  }

  /**
   * Render and node labels with borders
   * @param {D3} nodes D3 selection of nodes
   * @param {Object} nodeProps Properties object containing the node radius and color values
   */
  _renderNodeLabels(nodes, nodeProps) {

    // Render labels
    nodes.append( 'text' )
         .attr( 'dy', 4 )
         .attr( 'dx', nodeProps.radius + 12 )
         .attr( 'class', 'label' )
         .text( (d) => cropText(d.data.label) )
         .style( 'fill', colors.greyMedium )
         // Render and hide tooltip on mouse hover
         .on( 'mouseover mousemove', (d) => this._renderTooltip(d) )
         .on('mouseout', (d) => this._hideTooltip() );

    // Render node label border
    nodes.insert( "rect", ".label" )
         .attr( 'y', -11 )
         .attr( 'x', nodeProps.radius + 4 )
         .attr( 'rx', 10 )
         .attr( 'ry', 10 )
         .attr( 'class', 'label-border' )
         .attr( 'width', function(d) { return this.parentNode.getBBox().width - 12 } );

  }


  /** Tooltip **/


  /**
   * Create a new tooltip div in the page body
   * @return {D3} new tooltip element
   */
  _newTooltip() {

    return this.d3.select( 'body' )
                  .append( 'div' )
                  .attr( 'class', 'graph-tooltip shadow-small' );

  }

  /**
   * Render tooltip contents, style and position tooltip
   * @param {Object} d D3 node object to render the tooltip for
   */
  _renderTooltip(d) {

    if ( !this.graph.tooltip )
      return;

    let $t = $('.graph-tooltip'),
        color = this._nodeColor(d),
        rdfName = getRdfNameByType( d.data.rdf_type ),
        text = d.data.label;

    // Inner tooltip HTML
    let tHTML = `<div>` +
                  `<div class='font-regular' style='color: ${ color }'> ${ rdfName } </div>` +
                  `${ text }` +
                `</div>`;

    // Render tooltip
    this.graph.tooltip.html( tHTML )
                      .style( 'visibility', 'visible' )
                      .style( 'left', `${ this._tooltipCoords($t).left }px`  )
                      .style( 'top', `${ this._tooltipCoords($t).top }px` );

  }

  /**
   * Hide tooltip
   */
  _hideTooltip() {

    if (this.graph.tooltip)
      this.graph.tooltip.style( 'visibility', 'hidden' );

  }

  /**
   * Get tooltip page coordinates
   * @param {JQuery Element} $t tooltip element
   * @return {Object} Tooltip coordinates depenedent on current mouse event { left, top }
   */
  _tooltipCoords($t) {
    let isOut = this.d3.event.pageX + $t.width() >= window.innerWidth - 40;

    return {
      left: ( isOut ? this.d3.event.pageX - $t.width() : this.d3.event.pageX ),
      top: this.d3.event.pageY - $t.height() - 30
    }
  }


  /** Support **/


  /**
   * Toggle node's selected state, update data and styles
   * @extends _toggleNodeSelected parent implementation
   * @param {JQuery element} $node Target node element
   * @param {Object} d Target D3 node object
   * @param {boolean} select Desired select state of the node
   */
  _toggleNodeSelected($node, d, select) {

    super._toggleNodeSelected($node, d, select);

    let nodeColor = this._nodeColor(d);

    // Update node style
    $node.find( 'circle' ).css( 'fill', '#fff' );
    $node.find( '.label' ).css( 'fill', (select ? '#fff' : colors.greyMedium) );
    $node.find( '.label-border' ).css( 'fill', (select ? nodeColor : '#fff') )
                                 .css( 'stroke', (select ? nodeColor : colors.greyLight) );

  }

  /**
   * Get color of node by its rdf type
   * @param {Object} node D3 Node object
   * @return {string} Color code for the node's rdf type
   */
  _nodeColor(node) {
    return iconTypes.typeIconMap( node.data.rdf_type ).color;
  }

  /**
   * Get icon of node by its rdf type
   * @param {Object} node D3 Node object
   * @return {string} Icon char code for the node's rdf type
   */
  _nodeIcon(node) {
    return iconTypes.typeIconMap( node.data.rdf_type ).char;
  }

  /**
   * Graph properties definitions
   * @extends _graphProps parent parameters
   * @return {Object} Graph properties for tree, svg, zoom, nodes and links
   */
  get _graphProps() {

    let props = super._graphProps;

    // Custom nodeWidth function
    Object.defineProperty(props.tree, 'nodeWidth', {
    	get: () => ( props.svg.width / this.treeDepth ) - 80
    });

    // Custom zoom values
    props.zoom.min = 0.3;
    props.zoom.max = 1.6;

    // Custom node color
    props.nodes.color = '#fff';

    return props;

  }

}
