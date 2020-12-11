import * as d3 from 'd3-selection'

import colors from 'shared/ui/colors'
import { defaultProps } from 'shared/helpers/d3/renderers/nodes'

/**
 * D3 Graph Node
 * @description Extensible D3-based Node module
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class D3Node {

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
                        .filter( nd => this._nodeMatches( nd ) )
                        .node();

  }


  /** Getters **/


  /**
   * Get data
   * @return {Object} Node Data Object
   */
  get data() {
    return this.d;
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
    return '';
  }

  /**
   * Get value that the Node is found by (same as label by default)
   * @return {string} Node search value
   */
  get searchLabel() {
    return this.label;
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
    return this.d !== null && this.d !== undefined;
  }

  /**
   * Check if Node is selected
   * @return {boolean} Value representing whether Node is selected
   */
  get selected() {
    return this.data.selected === true;
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

    // Update node CSS class and styles, trigger selectChagned event
    this.$.addClass( 'selected' )
          .trigger( 'selectChanged', [true] );

    this.toggleSelectStyles( true );

  }

  /**
   * Deselect node (clear respective styles and data)
   */
  deselect() {

    // Update node data object
    this.data.selected = false;

    // Update node CSS class and styles, trigger selectChanged event
    this.$.removeClass( 'selected' )
          .trigger( 'selectChanged', [false] );

    this.toggleSelectStyles( false );

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
   * Node comparator function to determine whether node matches (compared by ids by default)
   * @param {D3Node} node Node to compare with this instance
   * @return {boolean} True if nodes are the same
   */
  _nodeMatches(node) {
    return node.id === this.data.id;
  }

}
