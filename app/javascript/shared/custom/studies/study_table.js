import TablePanel from 'shared/base/table_panel'
import EndpointEditor from 'shared/custom/studies/endpoint_editor'

import { dtBooleanColumn } from 'shared/helpers/dt/dt_columns'
import { iconBtn } from 'shared/ui/buttons'
import colors from 'shared/ui/colors'

/**
 * Create a Study Table Instance
 * @description
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class StudyTable extends TablePanel  {

  /**
   * Create a Simple Study Table Instance
   */
   constructor({
     selector,
     url,
     type
   } = {}) {

    super({
      selector, url,
      paginated: false,
      deferLoading: true
    }, { 
      type
    });

    if ( type === 'endpoints' )
      this.endpointEditor = new EndpointEditor({ 
        formatText: text => this._formatText(text) 
      })

  }

  show() {
    this.loadData();
  }


  /*** Private ***/


  _setTableListeners() {

    if ( this.type === 'endpoints' )
      this.table.on( 'click', 'a.btn', 
        e => this.endpointEditor.edit( this._getRowDataFrom$( $(e.currentTarget) ) )
      )

  }

  /**
   * Get default column definitions for IsoManaged items
   * @return {Array} Array of DataTable column definitions
   */
  get _defaultColumns() {

    switch( this.type ) {

      case 'objectives':
        return this._objectivesColumns;
        break;

      case 'endpoints':
        return this._endpointColumns;
        break;
    }

  }

  _formatText(text) {

    let patterns = [
      { s: '[[[Timepoint]]]', c: colors.accent2 },
      { s: '[[[Intervention]]]', c: colors.primaryLight },
      { s: '[[[BC]]]', c: colors.accentPurple },
      { s: '[[[Assessment]]]', c: colors.accentPurple },
      { s: '[assessment]', c: colors.accentPurple }
    ]

    patterns.forEach( pattern =>
      text = text.replaceAll( pattern.s, this._colorise( pattern.s, pattern.c ))
    );

    return text;

  }

  _colorise(string, color) {
    return `<span class='font-regular' style='color: ${ color }'> ${ string } </span>`;
  }

  get _objectivesColumns() {

    return [
      {
        data: 'text',
        render: (data, type) => type === 'display' ? this._formatText( data ) : data
      },
      { data: 'type' },
      dtBooleanColumn( 'selected', { orderable: false } )
    ];

  }

  get _endpointColumns() {
 
    return [
      { data: 'type' },
      {
        data: 'text',
        render: (data, type) => type === 'display' ? this._formatText( data ) : data
      },
      dtBooleanColumn( 'selected', { orderable: false } ),
      {
        orderable: false,
        render: (data, type) => type === 'display' ? 
          iconBtn({ icon: 'edit', color: 'light' }) : '' 
      }
    ];

  }

  get _tableOpts() {

    let options = super._tableOpts;

    options.language.info = '';
    options.paging = false;
    options.autoWidth = true;

    return options;

  }

}
