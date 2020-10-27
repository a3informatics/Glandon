import * as d3 from 'd3-selection'

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

    this.d = d;

    if ( withElement )
      this.findElement();

  }

  /**
   * Find the DOM element belonging to this Node Instance and set it to 'el' property
   */
  findElement() {

    this.el = d3.default.selectAll( '.node' )
                        .filter( nd => {

                          // Check parent ids if available as some Nodes have duplicate IDs (TUCRefs)
                          if ( nd.parent && this.d.parent )
                            return nd.parent.data.id === this.d.parent.data.id &&
                                   nd.data.id === this.d.data.id;

                          return nd.data.id === this.d.data.id;

                        })
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
   * Get node label
   * @return {string} Node label value
   */
  get label() {
    return this.data.label;
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
    return this.d.children && this.d.children.length > 0;
  }

  /**
   * Get Node children
   * @return {array} Array of children TreeNode instances or empty array if Node has no children
   */
  get children() {

    if ( this.hasChildren )
      return this.d.children.map( (n) => new this.constructor(n) );

    return []

  }

  /**
   * Get Node parent
   * @return {(TreeNode | null)} Node parent instance or null if Node has no parent
   */
  get parent() {

    if ( this.d.parent )
      return new this.constructor( this.d.parent );

    return null;

  }

  /**
   * Get previous Node (sibling)
   * @return {(TreeNode | null)} Previous Node instance or null if Node has no previous sibling
   */
  get previous() {
    return this.sibling(-1);
  }

  /**
   * Get next Node (sibling)
   * @return {(TreeNode | null)} Next Node instance or null if Node has no next sibling
   */
  get next() {
    return this.sibling(1);
  }

  /**
   * Get the middle child Node
   * @return {(TreeNode | null)} Middle child Node instance or null if Node has no children
   */
  get middleChild() {

    if ( this.hasChildren )
      return this.children[ Math.floor((this.d.children.length - 1) / 2) ];

    return null;

  }

  get hasSiblings() {
    return this.d.parent && this.d.parent.children.length > 1;
  }

  /**
   * Get the sibling of a node by a given offset
   * @param {integer} offset Offset - distance of the sibling from this Node, positive offset for next, negative for previous sibling
   * @return {(TreeNode | null)} Sibling Node instance or null if Node sibling with specified offset does not exist
   */
  sibling(offset) {

    if ( !this.hasSiblings )
      return null;

    let parent = this.d.parent,
        index = parent.children.indexOf( this.d );

    if ( parent.children[index + offset] )
      return new this.constructor( parent.children[index + offset] )

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
   * Remove a child Node from this instance
   * @param {TreeNode} node Node instance to be removed
   */
  removeChild(node) {

    if ( !this.hasChildren )
      return;

    let nodeIndex = this.d.children.indexOf( node.d );

    this.d.children.splice( nodeIndex, 1 );

    if ( this.d.children.length === 0 )
      delete this.d.children;

  }

  /**
   * Replace Node's children with a new set, set children's references and depths
   * @param {array} children New children to replace the current ones
   */
  replaceChildren(children) {

    // Set new children
    this.d.children = children;
    // Set children parent to this instance
    this.d.children.forEach( child => child.parent = this.d );
    // Offset descendants' depths relative to this instance
    this.d.descendants().slice(1)
                        .forEach( d => d.depth += this.d.depth );

  }

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
