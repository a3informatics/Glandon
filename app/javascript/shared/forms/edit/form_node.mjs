import TreeNode from 'shared/base/d3/tree/tree_node'

import colors from 'shared/ui/colors'
import { iconTypes } from 'shared/ui/icons'
import { getRdfNameByType, rdfTypesMap, getRdfObject } from 'shared/helpers/rdf_types'

/**
 * D3 Form Editor Tree Graph Node
 * @description D3-based Form Editor Node module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class FormNode extends TreeNode {

  /**
   * Check if Node is an RDF type
   * @param {string} rdfShortcut Key value for RDF Type in the rdfTypesMap
   * @return {boolean} Value representing Node being the argument rdf type
   */
  is(rdfShortcut) {
    return this.rdf === rdfTypesMap[ rdfShortcut ].rdfType;
  }

  /**
   * Get node label
   * @return {string} Node label value (local_label for TUC Reference)
   */
  get label() {
    return this.is('TUC_REF') ? this.data.local_label : this.data.label;
  }

  /**
   * Check if Node disabled
   * @return {boolean} Value representing Node's enabled data flag equal to false
   */
  get disabled() {
    return this.data.enabled === false;
  }

  /**
   * Get Node's RDF Type
   * @return {string} Value representing Node's RDF type data flag equal to false
   */
  get rdf() {
    return this.data.rdf_type;
  }

  /**
   * Get Node's Rdf Object definition
   * @return {Object} Rdf object from the rdfTypesMap
   */
  get rdfObject() {
    return getRdfObject( this.rdf );
  }

  /**
   * Get Node's name
   * @return {string} Value representing Node's name corresponding to its RDF type
   */
  get rdfName() {
    return getRdfNameByType( this.rdf );
  }

  /**
   * Get Node icon
   * @return {string} Node icon from its data RDF type (char code / character)
   */
  get icon() {
    return FormNode.icon( this.d );
  }

  /**
   * Get Node color
   * @return {string} Node color code from its data RDF type
   */
  get color() {
    return FormNode.color( this.d );
  }

  /**
   * Check if Node type is a reference
   * @return {boolean} Value specifying if Node's type is a reference
   */
  get isReference() {
    return this.is( 'TUC_REF' ) || this.is( 'BC_GROUP' );
  }

  /**
   * Check if Node instance has is_common flag set to true
   * @return {boolean} Value specifying if Node instance is_common
   */
  get isCommon() {
    return this.data.is_common === true;
  }

  /**
   * Check if Node type is allowed to be edited
   * @return {boolean} Value specifying if Node's type is a allowed to be edited
   */
  get editAllowed() {
    return !this.data.is_common && !this.is( 'COMMON_ITEM' );
  }

  /**
   * Check if Node type is allowed to add a child into
   * @return {boolean} Value specifying if Node's type is a allowed to add a child in the Editor
   */
  get addChildAllowed() {
    return this.is( 'FORM' ) || this.is( 'NORMAL_GROUP' ) || this.is( 'QUESTION' );
  }

  /**
   * Check if Node type is allowed to be Common
   * @return {boolean} Value specifying if Node's type is a allowed to be Common
   */
   get commonAllowed() {
    return this.is( 'BC_PROPERTY' ) && this.data.is_common === false;
  }

  /**
   * Check if Node type is allowed to be removed
   * @return {boolean} Value specifying if Node's type is a allowed to be removed
   */
   get removeAllowed() {

    if ( this.is( 'TUC_REF' ) )
      return this.parent.is( 'QUESTION' );

    if ( this.is( 'COMMON_GROUP' ) )
      return !this.hasChildren;

    return !this.is( 'BC_PROPERTY' ) && !this.is( 'FORM' ) && !this.is( 'COMMON_ITEM' );

  }

  /**
   * Check if Node type is allowed to be restored (from being common)
   * @return {boolean} Value specifying if Node's type is a allowed to be restored
   */
  get restoreAllowed() {
    return this.is( 'COMMON_ITEM' );
  }

  /**
   * Get a list of allowed children types for Node
   * @return {array} RDF shortcut names of types allowed as children for Node
   */
  get childTypes() {

    if ( this.is( 'NORMAL_GROUP' ) )
      return [ 'BC_GROUP', 'QUESTION',
               'MAPPING', 'TEXTLABEL', 'PLACEHOLDER', 'NORMAL_GROUP', 'COMMON_GROUP' ]

    else if ( this.is( 'FORM' ) )
      return [ 'NORMAL_GROUP' ]

    else if ( this.is( 'QUESTION' ) )
      return [ 'TUC_REF' ]

    return [];

  }


  /** Actions **/


  /**
   * Select node (add respective styles and data)
   */
   select() {

    super.select();

    // Update node style
    this.$.find( 'circle' ).css( 'fill', '#fff' );
    this.$.find( '.label' ).css( 'fill', '#fff' );
    this.$.find( '.label-border' ).css( 'fill', this.color )
                                  .css( 'stroke', this.color );

  }

  /**
   * Deselect node (clear respective styles and data)
   */
  deselect() {

    super.deselect();

    // Update node style
    this.$.find( 'circle' ).css( 'fill', '#fff' );
    this.$.find( '.label' ).css( 'fill', colors.greyMedium );
    this.$.find( '.label-border' ).css( 'fill', '#fff')
                                  .css( 'stroke', colors.greyLight );

  }

  /**
   * Remove a child Node from this instance and update sibling ordinals
   * @override parent implementation
   * @param {FormNode} node Node instance to be removed
   */
  removeChild(node) {

    if ( !this.hasChildren )
      return;

    let nodeIndex = this.d.children.indexOf( node.d );

    super.removeChild( node );

    // Update ordinals of siblings
    while( this.d.children && this.d.children[nodeIndex] ) {
      this.d.children[nodeIndex].data.ordinal -= 1;
      nodeIndex ++;
    }

  }

  /**
   * Swap ordinals between two Nodes
   * @param {FormNode} node Node to swap ordinals with
   */
  swapOrdinals(node) {

    let o = this.data.ordinal;

    this.data.ordinal = node.data.ordinal;
    node.data.ordinal = o;

  }

  /**
   * Sort Node children by their ordinal values
   */
  sortChildren() {

    if ( this.hasChildren )
      this.d.children.sort( (a, b) => (a.data.ordinal - b.data.ordinal) );

  }


  /** Static **/


  /**
   * Get icon from D3 Node data
   * @static
   * @param {Object} d D3 Node data
   * @return {string} Node icon from its data RDF type (char code / character)
   */
  static icon(d) {
    return iconTypes.typeIconMap( d.data.rdf_type ).char;
  }

  /**
   * Get color from D3 Node data
   * @static
   * @param {Object} d D3 Node data
   * @return {string} Node color code from its data RDF type
   */
  static color(d) {

    // Include reference URI to check for CDISC ownership if exists
    let param = d.data.reference ? (d.data.reference.uri || d.data.reference) : '';
    return iconTypes.typeIconMap( d.data.rdf_type, param ).color;

  }

}
