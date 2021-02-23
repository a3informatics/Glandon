import { iconTypes as icons } from 'shared/ui/icons'
import IPHelper from './ip_helper'

/**
 * Items Picker Renderer
 * @description Collection of helper functions for rendering the UI elements of an Items Picker 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class IPRenderer {

  /**
   * Create new IP Renderer instance 
   * @param {string} selector Unique Items Picker selector
   */
  constructor(selector) {
    this.selector = selector
  }

  /**
   * Render the tabs layout in the Picker 
   * @param {array} types Item types to render as tabs, must be from RdfTypesMap
   * @return {IPRenderer} Current IPRenderer instnace (for chaining) 
   */
  renderTabs(types) {

    this.$tabs.html( this._tabsLayout( types ) ) 

    return this 

  }

  /**
   * Render the description in the Picker 
   * @param {string} description Description to render 
   * @return {IPRenderer} Current IPRenderer instnace (for chaining) 
   */
  renderDescription(description) {

    this.content.find( '#items-picker-description' )
                .text( description )

    return this 

  }

  /**
   * Render text in submit button in the Picker 
   * @param {string} submitText Submit button text to render 
   * @return {IPRenderer} Current IPRenderer instnace (for chaining) 
   */
  renderSubmitText(submitText) {

    this.content.find( '#items-picker-submit' )
                .text( submitText )

    return this 

  }


  /*** Private ***/


  /*** Tabs ***/


  /**
   * Render Picker tabs layout
   * @param {array} types Item types to render as tabs, must be from RdfTypesMap
   * @return {JQuery Element} Tab layout element with rendered tabs layout for appending to the DOM 
   */
  _tabsLayout(types) {

    const tabOptionsWrap = $( '<div>' ).addClass( 'tabs-sel' ),

          tabs = this._typesAsTabs( types ),
          
          tabWraps = this._typesAsTabContents( types )
  
    return tabOptionsWrap.append( tabs )
                         .add( tabWraps )

  }

  /**
   * Render Picker tab options from given types
   * @param {array} types Item types to render as tabs, must be from RdfTypesMap
   * @return {JQuery Element} Tab options elements for appending to the DOM 
   */
  _typesAsTabs(types) {

    return types.map( type => this._tabOption(type) )
                .reduce( (html, tab) => html.add( tab ) )

  }

  /**
   * Render Picker tab content wrappers from given types
   * @param {array} types Item types to render as tabs, must be from RdfTypesMap
   * @return {JQuery Element} Tab content elements for appending to the DOM 
   */
  _typesAsTabContents(types) {

    return types.map( type => this._tabContent(type) )
                .reduce( (html, tabWrap) => html.add( tabWrap ) )

  }

  /**
   * Render a single Picker tab option
   * @param {object} type Item type definition, must be from RdfTypesMap
   * @return {JQuery Element} Tab option element for appending to the DOM 
   */
  _tabOption(type) {

    const { rdfType, name, param } = type 

    const id = IPHelper.typeToTabId( type ),
          tabName = this._pluralize( name ),
          icon = icons.renderIcon( rdfType, { size: 'text-large' } )
          
    return $( '<div>' ).addClass( 'tab-option with-icon no-badge')
                       .attr( 'id', id )
                       .text( tabName )
                       .prepend( icon )

  }

  /**
   * Render a single Picker tab wrap element
   * @param {object} type Item type definition, must be from RdfTypesMap
   * @return {JQuery Element} Tab content element for appending to the DOM 
   */
  _tabContent(type) {

    const { param } = type

    return $( '<div>' ).addClass( 'tab-wrap closed' )
                       .attr( 'id', IPHelper.typeToSelectorId( type ) )
                       .attr( 'data-tab', IPHelper.typeToTabId( type ) ) 

  }



  /*** Getters ***/


  /**
   * Get the Picker tabs element
   * @return {JQuery Element} Picker tabs element
   */
  get $tabs() {
    return this.content.find( '#items-picker-tabs' )
  }

  get content() {
    return $( this.selector ) 
  }


  /*** Support ***/


  /**
   * Plularizes the tab name
   * @param {string} name Tab name to pluralize
   * @return {string} Tab name in plural 
   */
  _pluralize(name) {

    if ( name === 'Terminology' )
      return 'Terminologies'
    else 
      return name + 's'

  }

}