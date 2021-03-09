import SelectablePanel from 'shared/base/selectable_panel'

import ItemsPicker from 'shared/ui/items_picker/v2/items_picker'

import { dtManagedItemsColumns } from 'shared/helpers/dt/dt_column_collections'
import { hasColumn, selectAllBtn, deselectAllBtn } from 'shared/helpers/dt/utils'
import { $confirm } from 'shared/helpers/confirmable'
import { $ajax } from 'shared/helpers/ajax'
import { rdfTypesMap as types } from 'shared/helpers/rdf_types' 

/**
 * Edit Managed Collection Panel
 * @description Editable version-based collection of Managed Items (adding, removing)
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class EditMCPanel {

  /**
   * Create an Edit Managed Collection Panel instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique selector of the Managed Collection element
   * @param {Object} params.urls Urls object containing the data, add, remove and removeAll action urls
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {string} params.idsParam Parameter name for adding a set of IDs into a collection [default='ids']
   * @param {Array} params.types Custom collection of Item types allowed to be added into the Managed Collection, optional
   * @param {Array} params.order Custom table ordering setting, optional  
   * @param {function} params.onEdited Function to execute after any data update 
   */
  constructor({
    selector = "#managed-collection",
    urls,
    param = 'managed_collection',
    idsParam = 'id_set',
    types = this._defaultTypes,
    order = [[1, 'asc']], 
    onEdited = () => {}
  }) {
    
    Object.assign( this, {
      urls: urls || managedCollectionsUrls,
      selector, param, types,
      idsParam, order, onEdited 
    })

    // Prevent urls from being changed
    Object.freeze( this.urls ) 

    this.sp = this._initSelectablePanel()
    this.picker = this._initPicker()

    this._setListeners()

  }


  /*** Public Actions ***/


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


  /*** Actions ***/


  /**
   * Build and execute server request to add given item ids to collection
   * @param {Array} ids Array of Managed Items' ids to add
   */
  _add(ids) {

    if ( !ids || ids.length < 1 )
      return; 

    this._execRequest({
      url: this.urls.add, 
      type: 'POST',
      data: { [ this.idsParam ]: ids },
      success: newData => this.sp._render( newData )
    })

  }

  /**
   * Build and execute server request to remove given item ids from collection
   * @param {Array} ids Array of Managed Items' ids to remove 
   */
  _removeSelected() {

    const selectedIds = this.sp.selectedData.toArray().map( d => d.id )

    this._execRequest({
      url: this.urls.remove, 
      type: 'PUT',
      data: { [ this.idsParam ]: selectedIds },
      success: () => 
        this.sp.selected.remove().draw()
    })

  }

  /**
   * Build and execute server request to remove all items from collection
   */
  _removeAll() {

    this._execRequest({
      url: this.urls.removeAll, 
      type: 'PUT',
      success: () => this.sp.clear()
    })

  }


  /*** UI ***/


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

  
  /*** Support ***/


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
      data: { [ this.param ]: data },
      done: data => {

        success( data )
        this.onEdited()
      
      },
      always: () => this._loading( false )
    })

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
        paginated: false,
        autoHeight: true,
        order: this.order,
        buttons: [ selectAllBtn(), deselectAllBtn() ],
        loadCallback: () => this._updateBtnsUI()
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
      multiple: true, 
      types: this.types,
      description: 'Select one or more items to add to the collection',
      onSubmit: selection => this._add( selection.asIDs() )
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
  
  /**
   * Get list of Item types that can be added to the Managed Collection panel
   * @return {Array} Array of Item RDF Type definitions
   */
  get _defaultTypes() {
    return [
      types.TH_CL,
      types.BC, 
      types.FORM, 
      types.SDTM_SD 
    ]
  }

}
