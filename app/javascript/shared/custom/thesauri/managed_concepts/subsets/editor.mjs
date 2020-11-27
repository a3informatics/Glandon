import SubsetPanel from 'shared/custom/thesauri/managed_concepts/subsets/subset_panel'
import SourcePanel from 'shared/custom/thesauri/managed_concepts/subsets/source_panel'

import { $ajax } from 'shared/helpers/ajax'
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
   * Initialize the Source and Subset panels with parameters, init UI
   */
  _initialize() {

    // Initialize Panels
    Object.assign( this, {

      source: new SourcePanel( this._sourcePanelOpts ),
      subset: new SubsetPanel( this._subsetPanelOpts )

    })

    // Disable interactivity on Source panel initially
    tableInteraction.disable( this.source.selector );

  }

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

    // Align table columns on tab switch (handling responsivness)
    $( this.selector ).on( 'tab-switch', (e, tab) =>
            tab === 'tab-source' ?
                    this.source.table.columns.adjust() :
                    this.subset.table.columns.adjust()
    );

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
  _onDataLoaded() {

    // Wait and retry if source panel is fetching data
    if ( this.source.isProcessing )
      return setTimeout( () => this._onDataLoaded(), 200 );

    // Mark rows present in Subset panel as selected initially in the Source panel
    for ( let itemData of this.subset.rowDataToArray ) {

      let otherRow = this.source._getRowFromData( 'id', itemData.id );

      if ( otherRow.length )
        this.source.selectWithoutCallback( otherRow );

    }

    // Enable interactivity on Source panel
    tableInteraction.enable( this.source.selector );

  }


  /*** Support ***/


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
        urls: this.urls,
        loadCallback: () =>
          this._onDataLoaded(),
        onReorder: ( a, t ) =>
          this._onSubsetReordered( a, t )
      }

  }

  /**
   * Options specification for the Source panel
   */
  get _sourcePanelOpts() {

    return {
      selector: `${this.selector} #source-table`,
      url: this.urls.sourceData,
      onSelect: r =>
        this.addItems( r.data().toArray() ),
      onDeselect: r =>
        this.removeItem( r.data().toArray()[0] ),
      onDeselectAll: () =>
        this.removeAllItems()
    }

  }

}
