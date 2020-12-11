import D3Node from 'shared/base/d3/d3_node'

import colors from 'shared/ui/colors'
import { iconTypes } from 'shared/ui/icons'
import { getRdfNameByType, rdfTypesMap, getRdfObject } from 'shared/helpers/rdf_types'

/**
 * D3 Impact Graph Node
 * @description Extensible D3-based Node module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ImpactNode extends D3Node {

  /** Getters **/

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
   * @return {string} Node label value
   */
  get label() {
    return this.data.label;
  }

  /**
   * Get value that the Node is found by
   * @return {string} Node search value (identifier)
   */
  get searchLabel() {
    return this.data.identifier;
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
    return getRdfNameByType( this.rdf );
  }

  /**
   * Get Node icon
   * @return {string} Node icon from its data RDF type (char code / character)
   */
  get icon() {
    return ImpactNode.icon( this.d );
  }

  /**
   * Get Node color
   * @return {string} Node color code from its data RDF type
   */
  get color() {
    return ImpactNode.color( this.d );
  }


  /** Actions **/


  /** Support **/


  /**
   * Toggle node selected styles depending on target selected state
   * @param {boolean} selected Target selected state
   * @override parent implementation
   */
  toggleSelectStyles(selected) {

    if ( selected ) {

      this.$.find( '.label' ).css( 'fill', '#fff' );
      this.$.find( '.label-border' ).css( 'fill', this.color )
                                    .css( 'stroke', this.color );

    }

    else {

      this.$.find( '.label' ).css( 'fill', colors.greyMedium );
      this.$.find( '.label-border' ).css( 'fill', '#fff')
                                    .css( 'stroke', colors.greyLight );

    }

  }


  /** Static **/


  /**
   * Get icon from D3 Node data
   * @static
   * @param {Object} d D3 Node data
   * @return {string} Node icon from its data RDF type (char code / character)
   */
  static icon(d) {
    return iconTypes.typeIconMap( d.rdf_type ).char;
  }

  /**
   * Get color from D3 Node data
   * @static
   * @param {Object} d D3 Node data
   * @return {string} Node color code from its data RDF type
   */
  static color(d) {
    return iconTypes.typeIconMap( d.rdf_type ).color;
  }


}
