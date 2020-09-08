import TreeNode from 'shared/base/d3/tree/tree_node'

import colors from 'shared/ui/colors'
import { iconTypes } from 'shared/ui/icons'
import { getRdfNameByType as nameFromRdf, rdfTypesMap } from 'shared/helpers/rdf_types'

/**
 * D3 Form Editor Tree Graph Node
 * @description D3-based Form Editor Node module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class FormNode extends TreeNode {

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
   * Get Node's name
   * @return {string} Value representing Node's name corresponding to its RDF type
   */
  get rdfName() {
    return nameFromRdf( this.rdf );
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
    return [ rdfTypesMap.TC_REF.rdfType, rdfTypesMap.TUC_REF.rdfType ].includes( this.rdf );
  }

  /**
   * Check if Node type is allowed to add a child into
   * @return {boolean} Value specifying if Node's type is a allowed to add a child in the Editor
   */
  get addChildAllowed() {

    return [
      rdfTypesMap.NORMAL_GROUP.rdfType,
      rdfTypesMap.FORM.rdfType,
      rdfTypesMap.QUESTION.rdfType
    ].includes( this.rdf );

  }

  /**
   * Check if Node type is allowed to be Common
   * @return {boolean} Value specifying if Node's type is a allowed to be Common
   */
   get commonAllowed() {
    return rdfTypesMap.BC_QUESTION.rdfType === this.rdf;
  }

  /**
   * Check if Node type is allowed to be removed
   * @return {boolean} Value specifying if Node's type is a allowed to be removed
   */
   get removeAllowed() {
    return ![
      rdfTypesMap.BC_QUESTION.rdfType,
      rdfTypesMap.FORM.rdfType,
      rdfTypesMap.TC_REF.rdfType,
      rdfTypesMap.TUC_REF.rdfType
    ].includes( this.rdf );
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
    return iconTypes.typeIconMap( d.data.rdf_type ).color;
  }

}
