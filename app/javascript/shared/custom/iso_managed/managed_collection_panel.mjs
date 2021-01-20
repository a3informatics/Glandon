import SelectablePanel from 'shared/base/selectable_panel'

import ItemsPicker from 'shared/ui/items_picker/items_picker'

import { dtManagedItemsColumns } from 'shared/helpers/dt/dt_column_collections'
import { hasColumn, selectAllBtn, deselectAllBtn } from 'shared/helpers/dt/utils'
import { $confirm } from 'shared/helpers/confirmable'
import { $ajax } from 'shared/helpers/ajax'

import testData from './testdata'

/**
 * Managed Collection Panel
 * @description Editable collection of version-based collection of Managed Items (adding, removing)
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ManagedCollectionPanel {

  /**
   * Create a Managed Collection Panel instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique selector of the Managed Collection element
   * @param {Object} params.urls Urls object containing the data, add, remove and removeAll action urls
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {Array} params.allowedTypes Array of strings - param names of allowed item types that can be added to the Collection @see ItemsPicker module
   */
  constructor({
    selector = "#managed-collection",
    urls,
    param,
    allowedTypes = [],
    onEdited = () => {}
  }) {

    Object.assign( this, {
      selector, urls, param, allowedTypes, onEdited 
    })

    this.sp = this._initSelectablePanel()
    this.picker = this._initPicker()

    this._setListeners()
    this._loadData()

  }

  /**
   * Show the picker for adding items to the collection
   */
  add() {

    if ( this.picker )
      this.picker.show()

  }

  /**
   * Remove the currently selected items from the collection
   * @require user confirmation
   */
  removeSelected() {

    const selectedCount = this.sp.selected.count()

    if ( selectedCount < 1 )
      return

    $confirm({
      subtitle: `${ selectedCount } item(s) will be removed from the collection.`,
      dangerous: true,
      callback: () => this._removeSelected()
    })

  }

  /**
   * Remove all items from the collection
   * @require user confirmation
   */
  removeAll() {

    const itemsCount = this.sp.table.rows().count()

    if ( itemsCount < 1 )
      return 

    $confirm({
      subtitle: `All items will be removed from the collection.`,
      dangerous: true,
      callback: () => this._removeAll()
    })

  }


  _loadData() {

    this.sp._render( testData )
    this.sp._onDataLoaded( this.sp.table )
    this._loading( false );

  }
  

  /** Private **/


  /**
   * Sets event listeners, handlers
   * Used for non-table related listeners only!
   */
  _setListeners() {

    const $panel = $( this.selector )

    $panel.find( '#add-items' ).on( 'click', () => 
      this.add()
    )

    $panel.find( '#remove-selected' ).on( 'click', () => 
      this.removeSelected()
    )

    $panel.find( '#remove-all' ).on( 'click', () => 
      this.removeAll() 
    )

  }

  _add(ids) {

    // Make request and update UI

  }

  _removeSelected() {

    const selectedRows = this.sp.selected

    // Make request and update UI  

  }

  _removeAll() {

    // Make request and update UI  

  }

  /**
   * Execute server request (helper)
   * @param {string} url Request URL
   * @param {string} type Request type
   * @param {any} data Data to pass in request
   * @param {function} success Success callback, returned data passed are passed as first arg
   */
  _execRequest({
    url,
    type,
    data,
    success = () => {}
  }) {

    this._loading( true )
    
    $ajax({
      url, type,
      data: {
        [ this.param ]: data 
      },
      done: data => {

        success( data )
        this.onEdited()
      
      },
      always: () => this._loading( false )
    })

  }

  /**
   * Change panel's loading state
   * @param {boolean} enable Value specifying to the desired loading state
   */
  _loading(enable) {

    this.sp._loading( enable )

    // Disable buttons while loading 
    $( this.selector ).find( '#collection-actions btn' )
                      .toggleClass( 'disabled', enable )

    // Set buttons to correct states when loading finishes 
    if ( !enable )
      this._updateBtnsUI()

  }

  /**
   * Updates the enabled/disabled states of the action buttons in the panel
   */
  _updateBtnsUI() {

    const selectedCount = this.sp.selected.count(),
          rowCount = this.sp.table.rows().count(),
          $panel = $( this.selector )

    // Disable 'Remove selected' button when no rows selected
    $panel.find( '#remove-selected' )
          .toggleClass( 'disabled', selectedCount < 1 )
    
    // Disable 'Remove all' button when no rows
    $panel.find( '#remove-all' )
          .toggleClass( 'disabled', rowCount < 1 )

  }

  /**
   * Initialize a new instance of SelectablePanel containing the collection items 
   * @return {SelectablePanel} New SP instance
   */
  _initSelectablePanel() {

    return new SelectablePanel({
      tablePanelOptions: {
        selector: `${ this.selector } #managed-items`,
        url: this.urls.data,
        param: this.param,
        extraColumns: this._panelColumns,
        buttons: [ selectAllBtn(), deselectAllBtn() ],
        order: [[1, "asc"]],
        paginated: false,
        deferLoading: true,
      },
      multiple: true,
      onSelect: () => this._updateBtnsUI(),
      onDeselect: () => this._updateBtnsUI()
    })

  }

  /**
   * Initialize a new instance of ItemsPicker for adding items to the collection
   * @return {ItemsPicker} New Picker instance
   */
  _initPicker() {

    return new ItemsPicker({
      id: 'add-items',
      types: this.allowedTypes,
      multiple: true, 
      onSubmit: selection => this._add( selection.asIdsArray() )
    })

  }

  /**
   * Get column definitions for Managed Collection table
   * @return {Array} Array of DataTable column definitions
   */
  get _panelColumns() {

    const withType = hasColumn( this.selector, 'Type' ),
          withOwner = hasColumn( this.selector, 'Owner' )

    return dtManagedItemsColumns( {}, withType, withOwner )

  }

}
