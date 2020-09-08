import * as d3Lib from 'd3'
import colors from 'shared/ui/colors'
import { defaultProps } from 'shared/helpers/d3/renderers/nodes'

/**
 * D3 Tree Graph Node
 * @description Extensible D3-based Node module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TreeNode {

  /**
   * Create a Node instance
   * @param {Object} d D3 Node object
   * @param {boolean} withElement Specifies if the instance should be initialized with Node's HTML element, optional [default=true]
   */
  constructor(d, withElement = true) {

    Object.assign( this, { d3: d3Lib.default, d });

    if ( withElement )
      this.el = this.d3.selectAll('.node')
                       .filter( (nd) => nd.data.id === d.data.id )
                       .node();

  }


  /** Getters **/


  /**
   * Get data
   * @return {Object} Node Data Object
   */
  get data() {
    return this.d.data;
  }

  /**
   * Get node element
   * @return {(JQuery Element | null)} Node Data Object or null if element not set
   */
  get $() {
    return this.el ? $(this.el) : null;
  }

  /**
   * Get node element bounding client rectangle
   * @return {Object} Node Element bounding rectangle object
   */
  get coordinates() {
    return this.$.get(0).getBoundingClientRect();
  }

  /**
   * Check if Node is valid
   * @return {boolean} Value representing whether Node data is valid
   */
  get exists() {
    return this.d && this.data;
  }

  /**
   * Check if Node is selected
   * @return {boolean} Value representing whether Node is selected
   */
  get selected() {
    return this.data.selected === true;
  }

  /**
   * Check if Node has children
   * @return {boolean} Value representing whether Node has children
   */
  get hasChildren() {
    return this.d.children;
  }

  /**
   * Get Node children
   * @return {array} Array of children TreeNode instances or empty array if Node has no children
   */
  get children() {

    if ( this.hasChildren )
      return this.d.children.map( (n) => new TreeNode(n) );

    return []

  }

  /**
   * Get Node parent
   * @return {(TreeNode | null)} Node parent instance or null if Node has no parent
   */
  get parent() {

    if ( this.d.parent )
      return new TreeNode( this.d.parent );

    return null;

  }

  /**
   * Get Node width
   * @return {(int | null)} Node's BBox width or null if Node element not defined
   */
  get width() {

    if ( this.el )
      return this.el.getBBox().width;

    return null;

  }


  /** Actions **/


  /**
   * Select node (add respective styles and data)
   */
   select() {

    // Update node data object
    this.data.selected = true;

    // Update node CSS class and styles
    this.$.addClass( 'selected' );
    this.$.find('circle').css( 'fill', colors.accent2 );

  }

  /**
   * Deselect node (clear respective styles and data)
   */
  deselect() {

    // Update node data object
    this.data.selected = false;

    // Update node CSS class and styles
    this.$.removeClass( 'selected' );
    this.$.find('circle').css( 'fill', defaultProps.color );

  }

  /**
   * Collapses / expands node opposite of its current state
   */
  collapseOrExpand() {

    if ( this.hasChildren )
      this.collapse();
    else
      this.expand();

  }

  /**
   * Collapse node children
   */
  collapse() {

    if ( this.hasChildren ) {
      this.d._children = this.d.children
      this.d.children = null;
    }

  }

  /**
   * Expand node children
   */
  expand() {

    if ( this.d._children ) {
      this.d.children = this.d._children;
      this.d._children = null;
    }

  }

}