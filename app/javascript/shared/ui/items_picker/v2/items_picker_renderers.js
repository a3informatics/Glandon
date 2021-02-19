import TabsLayout from 'shared/ui/tabs_layout'
import { rdfTypesMap } from 'shared/helpers/rdf_types'
import { iconTypes } from 'shared/ui/icons'

/**
 * Items Picker Renderer
 * @description Collection of helper functions for rendering the UI elements of an Items Picker 
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class IPRenderer {

  static render(types) {
    
  }

  static renderTabsLayout(types = []) {

    const tabsLayout = $( '<div>' ).addClass( 'tabs-layout text-small' )
                                   .attr( 'id', 'items-picker-tabs' ),

          tabsWrap = $('<div>').addClass('tabs-sel')

  
    return tabsLayout.append( tabsWrap.append( this._tabs( types ) ) )

  }


  /*** Private ***/

  static _tabs(types) {

    return types.map( type => this._tab( type ) )
                .reduce( (html, tab) => html.add( tab ) )

  }

  static _tab(type) {
    return $('<div>').text(type)
  }

}