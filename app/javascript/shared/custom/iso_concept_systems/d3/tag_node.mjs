import TreeNode from 'shared/base/d3/tree/tree_node'

import { getColorByTag } from 'shared/ui/tags'
import colors from 'shared/ui/colors'

/**
 * D3 Tag Graph Node
 * @description D3-based Tag Node module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class TagNode extends TreeNode {


  /**
   * Get Node label
   * @return {string} Node label value (pref_label)
   */
  get label() {
    return this.data.pref_label;
  }

  /**
   * Get Node color
   * @return {string} Node color code from its data RDF type
   */
  get color() {
    return TagNode.color( this.d );
  }

  /**
   * Check if Node type is allowed to be edited
   * @return {boolean} Value specifying if Node's type is a allowed to be edited
   */
  get editAllowed() {
    return !( this.parent === null && this.label === 'Tags' );
  }

  /**
   * Check if Node type is allowed to be removed
   * @return {boolean} Value specifying if Node's type is a allowed to be removed
   */
   get removeAllowed() {
    return this.editAllowed;
  }


  /** Actions **/


  /**
   * Remove a child Node from this instance
   * @param {TagNode} node Node instance to be removed
   */
  removeChild(node) {

    if ( !this.data.narrower )
      return;

    let nodeIndex = this.data.narrower.indexOf( node.d.data );

    this.data.narrower.splice( nodeIndex, 1 );

  }

  /**
   * Add a child to Tag Node
   * @param {Object} data New child data object
   */
  addChild(data) {

    if ( !this.data.narrower )
      this.data.narrower = [];

    if ( this.data.narrower.indexOf( data ) === -1 )
      this.data.narrower.push( data );

  }

  /**
   * Update Tag Node data
   * @param {Object} data New data object
   */
  update(data) {

    data.narrower = this.data.narrower; // Copy children
    Object.assign( this.data, data ); // Override fields with new fields

  }


  /** Support **/


  /**
   * Toggle node selected styles depending on target selected state
   * @param {boolean} selected Target selected state
   * @override parent implementation
   */
  toggleSelectStyles(selected) {

    if ( selected ) {

      this.$.find( '.label' ).css( 'fill', '#fff' );
      this.$.find( '.label-border' ).css( 'fill', this.color );
      this.$.find('circle').css( 'fill', this.color );

    }

    else {

      this.$.find( '.label' ).css( 'fill', colors.greyMedium );
      this.$.find( '.label-border' ).css( 'fill', '#fff' );
      this.$.find('circle').css( 'fill', this.color );

    }

  }


  /** Static **/


  /**
   * Get color from D3 Node data
   * @static
   * @param {Object} d D3 Node data
   * @return {string} Node color code from its data Tag type
   */
  static color(d) {

    return getColorByTag( d.data.pref_label );

  }

}
