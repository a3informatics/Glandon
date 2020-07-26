import InformationDialog from 'shared/ui/dialogs/information_dialog'

import { unmanagedConceptRef, managedConceptRef } from 'shared/ui/strings'

/**
 * Selection View
 * @description Allows for a selection of Items be displayed and managed
 * @requires selection_view partial (views/shared/items_picker/_selection_view.html.erb)
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class SelectionView {

  /**
   * Create a Selection View instnace
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique jQuery selector of the selection view element
   * @param {boolean} params.multiple Enable / disable dislpaying multiple items [default = false]
   * @param {Object} params.itemTypes Map of all supported item types and their standard names @see ItemsPicker.itemTypes
   */
  constructor({
    selector,
    multiple = false,
    itemTypes
  }) {
    Object.assign(this, { selector, multiple, itemTypes } )

    this._initialize();
  }

  /**
   * Clear the selection into its initial state and render
   */
  clear() {
    this._resetSelection();
    this._render();

    // Notify selection data changed
    this._selectionChanged('removed');
  }

  /**
   * Add data item to a subselection type and render selection view
   * @param {string} type item type, @see ItemsPicker.itemTypes
   * @param {Object} data item data object to add to the selection
   */
  add(type, data) {
    // Check type exists
    if ( !this.selection[type] )
      throw new Error(`Selection type ${type} does not exist`)

    // Check for item count when multiple selection disabled
    if (!this.multiple && Array.isArray(data) && data.length > 1)
      throw new Error(`Cannot add multiple items while multiple selection disabled.`)

    // Clear selection first if multiple selection disabled
    if (!this.multiple)
      this._resetSelection();

    // Add data to selection
    this._addToSelection(type, data)

    this._render();
  }

  /**
   * Remove item(s) from selection and render selection view
   * @param {(Array | string)} ids a single id / collection of item ids to remove from the selection
   */
  removeById(ids) {
    // Find and remove array of item ids
    if ( Array.isArray(ids) ) {
      for (const id of ids) {
        this._removeFromSelection( this._findById(id) );
      }
    }
    // Find and remove one item id
    else
      this._removeFromSelection( this._findById(ids) );

    this._render();
  }

  /**
   * Check if selection contains item with specific id
   * @param {string} id a single item id to check presence in selection
   * @return {boolean} value repesenting item being present in selection
   */
  selectionContains(id) {
    return this._findById(id) !== null;
  }

  /**
   * Check if selection is empty
   * @return {boolean} value represeting selection being empty
   */
  get selectionEmpty() {
    return this._selectionLength === 0;
  }

  /**
   * Get selection div to allow listening for the 'selection-change' event on
   * @return {JQuery Element} unique selection div that can be listened for change events
   */
  get div() {
    return $(this.selector).find('#selection-view');
  }

  /**
   * Get object that with functions that return the selection in different formats
   * @return {Object} contains functions that return selection in following formats: asTypesObject, asObjectsArray, asIDsArray
   */
  getSelection() {
    return {
      asTypesObject: () => {
        return this.selection;
      },
      asObjectsArray: () => {
        return Object.values(this.selection).flat(1);
      },
      asIDsArray: () => {
        return this.getSelection().asObjectsArray().map((d) => d.id);
      }
    }
  }


  /** Private **/


  /**
   * Initialize UI, selection, listeners and initial render
   */
  _initialize() {
    // Hide view selection button when multiple item selection disabled
    if (!this.multiple)
      this.div.find('#view-selection').hide();

    this._resetSelection();
    this._render();
    this._setListeners();
  }

  /**
   * Set event listeners and handlers
   */
  _setListeners() {
    // View selection click handler
    this.div.find('#view-selection').on('click', () => this._showSelectionDialog());

    // Clear selection click handler
    this.div.find('#clear-selection').on('click', () => this.clear());
  }


  /** Selection **/


  /**
   * Find item data in the selection by an id
   * @param {string} id item id to find
   * @return {(Object | null)} Object containing item data, index and type, or null if such id is not in selection
   */
  _findById(id) {
    let item = null;

    this._eachType( (type) => {
      this.selection[type].forEach( (data, index) => {
        if (data.id == id) {
          item = { data, index, type }
        }
      });

    });

    return item;
  }

  /**
   * Private add to selection function, adds data to selection type, prevents duplicates
   * @param {string} type data's item type, @see ItemsPicker.itemTypes
   * @param {object} data item's data object
   */
  _addToSelection(type, data) {
    // Add array of item data object
    if ( Array.isArray(data) ) {
      for (const d of data) {
        this._addToSelection(type, d);
      }
    }

    // Add single item data object if already not present
    else if ( !this.selectionContains(data.id) ) {
      this.selection[type].push(data);

      // Notify selection data changed
      this._selectionChanged('added');
    }
  }


  /**
   * Private remove from selection function, removes item from selection
   * @param {Object} item Item to remove, must contain the type and index fields
   */
  _removeFromSelection(item) {
    if (!item)
      return;

    this.selection[item.type].splice(item.index, 1);

    // Notify selection data changed
    this._selectionChanged('removed');
  }

  /**
   * Reset selection object to its initial state
   */
  _resetSelection() {
    // Clear selection
    this.selection = {}

    // Init selection item types with empty arrays
    this._eachType( (type) => this.selection[type] = [] );
  }

  /**
   * Call with every update to selection data
   * @param {string} type change type: 'added' | 'removed'
   */
  _selectionChanged(type) {
    this.div.trigger('selection-change', [type]);
  }


  /** Selection Dialog **/


  /**
   * Initialize and show the selection dialog
   */
  _showSelectionDialog() {
    let dialogInstance = new InformationDialog({
      title: "Current selection",
      subtitle: this._renderSelectionDialog(),
      wide: true
    }).show();

    this._setDialogListeners(dialogInstance);
  }

  /**
   * Set event handlers within the selection dialog
   * @param {InformationDialog} dialogInstance information dialog instance to set the event listeners for
   */
  _setDialogListeners(dialogInstance) {
    // Remove item from selection within selection dialog
    $(dialogInstance.id).on('click', '.removable', (e) => {
      // Get clicked item id
      const itemId = $(e.currentTarget).attr('data-id');

      // Remove item and re-render dialog to reflect changes
      this.removeById(itemId);
      dialogInstance.setText(this._renderSelectionDialog());
    });
  }


  /** Renderers **/


  /**
   * Render Selection View
   */
  _render() {
    // Render selection info label
    this.div.find('#selected-info').html(this._selectionInfoText);
  }

  /**
   * Render the selection dialog contents
   * @return {string} formatted HTML for selection dialog
   */
  _renderSelectionDialog() {
    // Return if selection empty
    if ( this.selectionEmpty )
      return 'Selection is empty'

    let output = `<i>Click on an item to remove it from the selection.</i><br/>`

    this._eachType( (type) => {
      // Skip empty types
      if ( this.selection[type].length ) {
        // Render Type title
        output += `<span class='label-styled label-w-margin'> ${this.itemTypes[type]} </span> <br>`;

        this.selection[type].forEach( (item) => {
          // Render Item label
          output += `<span class='bg-label label-w-margin removable' data-id='${item.id}'>` +
                      this._getItemReference(type, item) +
                    `</span>`
        });

        output += `<br>`
      }
    });

    return output;
  }


  /** Getters **/


  /**
   * Get the standard text of a reference to a managed/unmanaged item
   * @param {string} type Item type
   * @param {Object} item Data of the managed/unamnaged item
   * @return {string} standard managed / unmanaged item reference text
   */
  _getItemReference(type, item) { 
    return type === 'unmanaged_concept' ?
              unmanagedConceptRef(item, item.parent) :
              managedConceptRef(item);
  }

  /**
   * Get the length of the selection
   * @return {int} length of entire selection
   */
  get _selectionLength() {
    return Object.values(this.selection)
                 .reduce( (total, subSelection) => total + subSelection.length, 0 )
  }

  /**
   * Get text for the selection info
   * @return {(int | string)} selection info text, represented in selection length or item reference string
   */
  get _selectionInfoText() {
    // Return count of all selected item if multiple enabled
    if (this.multiple)
      return this._selectionLength

    // Return managed/unamanged item reference string otherwise
    else {
      const item = this._selectedItem;

      // Generate string if item selected
      if (item)
        return this._getItemReference(item.type, item.data)

      // No item selected
      return 'None'
    }
  }

  /**
   * Get currently selected item (for single-selection only)
   * @return {(Object | null)} object containing data and type of the selected item or null if no item is selected
   */
  get _selectedItem() {
    // Only allowed for single item selection
    if (this.multiple)
      return;

    let item = null;

    // Find selected item data object and type 
    this._eachType( (type) => {
      if ( this.selection[type][0] )
        item = { data: this.selection[type][0], type: type }
    });

    return item;
  }

  /**
   * Helper function, iterator over each item type, @see ItemsPicker.itemTypes
   * @param {function} action called for each item type, passes the type as argument
   */
  _eachType(action) {
    for ( const type of Object.keys(this.itemTypes) ) {
      action(type);
    }
  }

}
