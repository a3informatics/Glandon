import D3Node from 'shared/base/d3/d3_node'

import colors from 'shared/ui/colors'
import { defaultProps } from 'shared/helpers/d3/renderers/nodes'

/**
 * D3 Tree Graph Node
 * @description Extensible D3-based Node module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TreeNode extends D3Node {

  /** Getters **/

  /**
   * Get node label
   * @return {string} Node label value
   */
  get label() {
    return this.data.label;
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


  /** Support **/


  /**
   * Toggle node selected styles depending on target selected state
   * @param {boolean} selected Target selected state
   * @override for custom implementation
   */
  toggleSelectStyles(selected) {

    if ( selected )
      this.$.find('circle').css( 'fill', colors.accent2 );
    else
      this.$.find('circle').css( 'fill', defaultProps.color );

  }

  /**
   * Node comparator function to determine whether node matches 
   * @param {TreeNode} node Node to compare with this instance
   * @return {boolean} True if nodes are the same
   */
  _nodeMatches(node) {

    // Check parent ids if available as some Nodes have duplicate IDs (TUCRefs)
    if ( node.parent && this.d.parent )
      return node.parent.data.id === this.d.parent.data.id &&
             node.data.id === this.d.data.id;

    return super._nodeMatches( node )

  }

}
