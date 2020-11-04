import TablePanel from 'shared/base/table_panel'
import SelectablePanel from 'shared/base/selectable_panel'

import { $ajax } from 'shared/helpers/ajax'
import { dtChildrenColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtIndicatorsColumn } from 'shared/helpers/dt/dt_columns'
import { tableInteraction } from 'shared/helpers/utils'
import { alerts } from 'shared/ui/alerts'

/**
 * Subset Editor module
 * @description Allows to edit Subset by selecting and reordering children
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SubsetEditor {

  /**
   * Create a Subsets Manager instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the editor element
   * @param {string} params.conceptId ID of the target Managed Concept
   * @param {string} params.dataUrl Url to fetch Subsets data
   */
   constructor({
     selector = '#subset-editor',
     param = 'subset',
     urls
   }) {

    Object.assign(this, {
      selector, param, urls
    });

    this._initialize();

  }

  addItems(items) {

    if ( !items.length )
      return;

    this._executeRequest({
      url: this.urls.add,
      type: 'POST',
      data: { cli_ids: items.map( i => i.id ) },
      callback: () => this.subset.refresh()
    });

  }

  removeItem(item) {

    if ( !item )
      return;

    let itemRow = this._findItem( this.subset, item );

    if ( !itemRow ) {
      alerts.error( 'Something went wrong during the remove operation.' );
      return;
    }

    this._executeRequest({
      url: this.urls.remove,
      type: 'DELETE',
      data: { member_id: itemRow.data().member_id },
      callback: () => this.subset.refresh()
     });

  }

  removeAllItems() {

    this._executeRequest({
      url: this.urls.removeAll,
      type: 'DELETE',
      callback: () => {
        this.source.deselectWithoutCallback();
        this.subset.clear();
      }
    });

  }

  moveItemAfter() {

  }


  /*** Private ***/


  _executeRequest({ url, type, data, callback }) {

    this._loading( true );

    let dataObj = {}
    dataObj[ this.param ] = data;

    $ajax({
      url, type,
      data: dataObj,
      done: d => callback( d ),
      always: () => this._loading( false )
    });

  }

  /**
   * Set event listeners & handlers
   */
  _setListeners() {

    this.subset.table.on('row-reordered', (e, details, changes) => {

      if ( !details.length )
        return;

      let row = changes.triggerRow;
    });

    // Align table columns on tab switch (handling responsivness)
    $( this.selector ).on( 'tab-switch', (e, tab) =>
            tab === 'tab-source' ?
                    this.source.table.columns.adjust() :
                    this.subset.table.columns.adjust()
    );

  }

  /**
   * Initialize the Table Panel instance with parameters
   */
  _initialize() {

    this.source = new SelectablePanel( this._sourcePanelOpts );

    this.subset = new TablePanel( this._subsetPanelOpts );

    // Custom behavior for deselecting all rows
    this.source._deselectAll = () => this.removeAllItems();

    // Disable interactivity on Source panel
    tableInteraction.disable( this.source.selector );

    this._setListeners();

  }


  /*** Events ***/


  _onSubsetsLoaded() {

    // Wait and retry if Source panel has not finished loading data
    if ( this.source.isProcessing ) {
      setTimeout( () => this._onSubsetsLoaded(), 200 );
      return;
    }

    // Enable interactivity on Source panel
    tableInteraction.enable( this.source.selector );

    // Mark rows present in Subset panel as selected initially in the Source panel
    for ( let itemData of this.subset.rowDataToArray ) {

      let otherRow = this._findItem(this.source, itemData);

      if ( otherRow )
        this.source.selectWithoutCallback( otherRow );

    }

  }


  /*** Events ***/


  _loading(enable) {

    this.source._loading( enable );
    this.subset._loading( enable );

  }

  _findItem(target, data) {

    let matchRow = target._getRowFromData( 'id', data.id )

    if ( matchRow.length )
      return matchRow;

    return null;

  }

  get _subsetPanelOpts() {

    return {
      selector: `${this.selector} #subset-table`,
      url: this.urls.subsetData,
      param: 'subset',
      order: [[ 0,'asc' ]],
      extraColumns: [
        { data: 'ordinal', orderable: false },
        ...dtChildrenColumns({ orderable: false })
      ],
      count: 1000,
      tableOptions: {
        rowReorder: {
          dataSrc: 'ordinal',
          selector: 'tr',
          snapX: true
        },
        scrollX: true,
        autoWidth: true
      },
      loadCallback: () => this._onSubsetsLoaded()
    }

  }

  get _sourcePanelOpts() {

    return {
      tablePanelOptions: {
        selector: `${this.selector} #source-table`,
        url: this.urls.sourceData,
        param: 'managed_concept',
        extraColumns: [...dtChildrenColumns(), dtIndicatorsColumn()],
        count: 1000,
        tableOptions: {
          scrollX: true,
          autoWidth: true
        }
      },
      multiple: true,
      allowAll: true,
      onSelect: r => this.addItems( r.data().toArray() ),
      onDeselect: r => this.removeItem( r.data().toArray()[0] )
    }

  }

}
