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

  /**
   * Empty all content
   */
  empty() {
    this.$tabs.remove()
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

    const { rdfType, name } = type 

    const id = IPHelper.typeToTabId( type ),
          tabName = IPHelper.pluralize( name ),
          icon = icons.renderIcon( rdfType, { size: 'text-large' } )
          
    return $( '<div>' ).addClass( 'tab-option with-icon no-badge')
                       .prop( 'id', id )
                       .append([ icon, tabName ])

  }

  /**
   * Render a single Picker tab wrap element
   * @param {object} type Item type definition, must be from RdfTypesMap
   * @return {JQuery Element} Tab content element for appending to the DOM 
   */
  _tabContent(type) {

    return $( '<div>' ).addClass( 'tab-wrap closed' )
                       .prop( 'id', IPHelper.typeToSelectorId( type ) )
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

  /**
   * Get the content (main) element
   * @return {JQuery Element} Main content element
   */
  get content() {
    return $( this.selector ) 
  }


  /*** Support ***/


  /**
   * Get the default values for various prompts in the Picker 
   * @return {object} Default string values
   */
  static get defaults() {

    return {
      description: 'To proceed, select one or more items',
      submit: 'Submit and proceed'
    }

  }

}