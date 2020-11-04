import TablePanel from 'shared/base/table_panel'
import SelectablePanel from 'shared/base/selectable_panel'

import { $ajax } from 'shared/helpers/ajax'
import { dtChildrenColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtIndicatorsColumn } from 'shared/helpers/dt/dt_columns'
import { tableInteraction } from 'shared/helpers/utils'
import { alerts } from 'shared/ui/alerts'

/**
 * Subset Editor module
 * @description Allows to edit Subset; add, remove and reorder children
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SubsetEditor {

  /**
   * Create a Subsets Manager instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the editor parent
   * @param {string} params.param Name of the strong controller parameter
   * @param {object} params.urls Urls for data and updates
   * @param {function} params.onEdit Callback executed after every edit operation
   */
   constructor({
     selector = '#subset-editor',
     param = 'subset',
     urls,
     onEdit = () => {}
   }) {

    Object.assign(this, {
      selector, param, urls, onEdit
    });

    this._initialize();
    this._setListeners();

  }

  /**
   * Add one or more Code List Items to Subset
   * @param {array} items List of item data objects to add to the Subset
   */
  addItems(items) {

    if ( !items.length )
      return;

    this._executeRequest({
      url: this.urls.add,
      type: 'POST',
      data: {
        cli_ids: items.map( i => i.id )
      },
      callback: () => this.subset.refresh()
    });

  }

  /**
   * Add one Code List Item from Subset
   * @param {object} item Item data object to be removed from Subset
   */
  removeItem(item) {

    if ( !item )
      return;

    // Find item in the Subset panel to retrieve its member_id for removal
    let subsetRow = this.subset._getRowFromData( 'id', item.id );

    if ( !subsetRow.length ) {
      alerts.error( 'Something went wrong during the remove operation.' );
      return;
    }

    this._executeRequest({
      url: this.urls.remove,
      type: 'DELETE',
      data: {
        member_id: subsetRow.data().member_id
      },
      callback: () => this.subset.refresh()
     });

  }

  /**
   * Clear the Subset of all Code List Items
   */
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

  /**
   * Move item after another in a Subset
   * @param {object} targetItem Item that has been moved
   * @param {object | null} previousItem Item before the moved item, null if none
   */
  moveAfter(targetItem, previousItem) {

    let memberId = targetItem.member_id,
        moveAfterId = previousItem ? previousItem.member_id : null,
        data = { member_id: memberId };

    // Add after_id parameter if previous item exists
    if ( moveAfterId )
      data.after_id = moveAfterId;

    this._executeRequest({
      url: this.urls.moveAfter,
      type: 'PUT',
      data,
      callback: () => this.subset.refresh()
    });

  }


  /*** Private ***/


  /**
   * Perform a server request based on given parameters
   * @param {string} url Url of the request
   * @param {string} type Type of the request
   * @param {objet} data Request data object (without strong parameter), optional
   * @param {function} callback Function to execute on request success
   */
  _executeRequest({ url, type, data, callback }) {

    this._loading( true );

    let dataObj = {}
    dataObj[ this.param ] = data;

    $ajax({
      url, type,
      data: dataObj,
      done: d => {
        callback( d );
        this.onEdit();
      },
      always: () => this._loading( false )
    });

  }

  /**
   * Set event listeners & handlers
   */
  _setListeners() {

    // On Subset row reordered event handler
    this.subset.table.on('row-reordered', (e, d, c) =>
            this._onSubsetReordered( d, c.triggerRow ));

    // Align table columns on tab switch (handling responsivness)
    $( this.selector ).on( 'tab-switch', (e, tab) =>
            tab === 'tab-source' ?
                    this.source.table.columns.adjust() :
                    this.subset.table.columns.adjust()
    );

  }

  /**
   * Initialize the Source and Subset panels with parameters, init UI
   */
  _initialize() {

    this.source = new SelectablePanel( this._sourcePanelOpts );

    this.subset = new TablePanel( this._subsetPanelOpts );

    // Override behavior for deselecting all rows
    this.source._deselectAll = () => this.removeAllItems();

    // Disable interactivity on Source panel initially
    tableInteraction.disable( this.source.selector );

  }


  /*** Events ***/

  /**
   * On Subset panel row reordered, find target & previous table row data, pass to moveAfter
   * @param {array} affected Array of affected rows (from DT API)
   * @param {DT Row} target DataTable Row instance representing the row that was reordered
   */
  _onSubsetReordered(affected, target) {

    if ( !affected.length || !target )
      return;

    let targetData = target.data(),
        previousRow = this.subset._getRowFromData( 'ordinal', targetData.ordinal - 1 );

    this.moveAfter( targetData, previousRow.data() );

  }

  /**
   * On Subset panel loaded callback, mark rows in Source panel as selected
   */
  _onSubsetsLoaded() {

    // Wait and retry if Source panel has not finished loading data
    if ( this.source.isProcessing ) {
      setTimeout( () => this._onSubsetsLoaded(), 200 );
      return;
    }

    // Mark rows present in Subset panel as selected initially in the Source panel
    for ( let itemData of this.subset.rowDataToArray ) {

      let otherRow = this.source._getRowFromData( 'id', itemData.id );

      if ( otherRow.length )
        this.source.selectWithoutCallback( otherRow );

    }

    // Enable interactivity on Source panel
    tableInteraction.enable( this.source.selector );

  }


  /*** Events ***/


  /**
   * Toggle loading state of the Editor
   * @param {boolean} enable Specifies target loading state
   */
  _loading(enable) {

    this.source._loading( enable );
    this.subset._loading( enable );

  }

  /**
   * Options specification for the Subset panel
   */
  get _subsetPanelOpts() {

    return {
      selector: `${this.selector} #subset-table`,
      url: this.urls.subsetData,
      param: 'subset',
      count: 1000,
      order: [[ 0,'asc' ]],
      extraColumns: [
        { data: 'ordinal', orderable: false },
        ...dtChildrenColumns({ orderable: false })
      ],
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

  /**
   * Options specification for the Source panel
   */
  get _sourcePanelOpts() {

    return {
      tablePanelOptions: {
        selector: `${this.selector} #source-table`,
        url: this.urls.sourceData,
        param: 'managed_concept',
        count: 1000,
        extraColumns: [ ...dtChildrenColumns(), dtIndicatorsColumn() ],
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
