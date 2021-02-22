import TabsLayout from 'shared/ui/tabs_layout'
import { rdfTypesMap } from 'shared/helpers/rdf_types'
import { iconTypes as icons } from 'shared/ui/icons'

/**
 * Items Picker Renderer
 * @description Collection of helper functions for rendering the UI elements of an Items Picker 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class IPRenderer {

  /**
   * Render Picker tabs (layout)
   * @param {array} types Item types to render as tabs, must be from RdfTypesMap
   * @return {JQuery Element} Tab layout element with rendered Tabs (layout) for appending to the DOM 
   */
  static renderTabs(types) {

    const tabsLayout = $( '<div>' ).addClass( 'tabs-layout text-small' )
                                   .attr( 'id', 'items-picker-tabs' ),

          tabOptionsWrap = $( '<div>' ).addClass( 'tabs-sel' ),

          tabs = this._typesAsTabs( types ),
          
          tabWraps = this._typesAsTabContents( types )

    tabOptionsWrap.append( tabs )
    tabsLayout.append( tabOptionsWrap ).append( tabWraps )
  
    return tabsLayout

  }


  /*** Private ***/


  /**
   * Render Picker tab options from given types
   * @param {array} types Item types to render as tabs, must be from RdfTypesMap
   * @return {JQuery Element} Tab options elements for appending to the DOM 
   */
  static _typesAsTabs(types) {

    return types.map( type => this._tabOption(type) )
                .reduce( (html, tab) => html.add( tab ) )

  }

  /**
   * Render Picker tab content wrappers from given types
   * @param {array} types Item types to render as tabs, must be from RdfTypesMap
   * @return {JQuery Element} Tab content elements for appending to the DOM 
   */
  static _typesAsTabContents(types) {

    return types.map( type => this._tabContent(type) )
                .reduce( (html, tabWrap) => html.add( tabWrap ) )

  }

  /**
   * Render a single Picker tab option
   * @param {object} type Item type definition, must be from RdfTypesMap
   * @return {JQuery Element} Tab option element for appending to the DOM 
   */
  static _tabOption(type) {

    const { rdfType, name, param } = type 

    const id = `tab-${ param }`,
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
  static _tabContent(type) {

    const { param } = type

    return $( '<div>' ).addClass( 'tab-wrap closed' )
                       .attr( 'id', `selector-${ param }` )
                       .attr( 'data-tab', `tab-${ param }` ) 

  }


  /*** Support ***/


  /**
   * Plularizes the tab name
   * @param {string} name Tab name to pluralize
   * @return {string} Tab name in plural 
   */
  static _pluralize(name) {

    if ( name === 'Terminology' )
      return 'Terminologies'
    else 
      return name + 's'

  }

}