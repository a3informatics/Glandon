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
   * Create a Managed Item Selector
   * @param {Object} params Instance parameters
   * @param {string} params.selector Unique jQuery selector of the selection element
   * @param {boolean} params.multiple Enable / disable dislpaying multiple items [default = false]
   */
  constructor({
    selector,
    multiple = false
  }) {
    Object.assign(this, { selector, multiple } )

    this._initialize();
  }

  /**
   * Clear selection
   */
  clear() {
    this._resetSelection();
    this._render();
  }

  /**
   * Add data item to a subselection type
   * @param {string} type subselection type, @see _itemTypes
   * @param {Object} data item data object to add to the subselection
   */
  add(type, data) {
    // Check type exists
    if ( !this.selection[type] )
      throw new Error(`Selection type ${type} does not exist`)

    // Clear selection first if multiple selection disabled
    if (!this.multiple)
      this._resetSelection();

    // Add data to selection
    this.selection[type].push(data);

    this._render();
  }

  /**
   * Remove item(s) from selection
   * @param {(Array | string)} ids a single id / collection of item ids to remove from selection
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
   * Check if selection is empty
   * @return {boolean} value represeting selection being empty
   */
  get isSelectionEmpty() {
    return this._selectionLength === 0;
  }


  /** Private **/

  /**
   * Initialize UI, selection, listeners and initial render
   */
  _initialize() {
    // Hide view selection button when multiple item selection disabled
    if (!this.multiple)
      $(`${this.selector} #view-selection`).hide();

    this._resetSelection();
    this._render();
    this._setListeners();
  }

  /**
   * Set event listeners and handlers
   */
  _setListeners() {
    // View selection click handler
    $(`${this.selector} #view-selection`).on('click', () => this._showSelectionDialog());

    // Clear selection click handler
    $(`${this.selector} #clear-selection`).on('click', () => this.clear());
  }

  /**
   * Iterator over each item type, @see _itemTypes
   * @param {function} action called for each item type, passes the type as argument
   */
  _eachType(action) {
    for ( const type of Object.keys(this._itemTypes) ) {
      action(type);
    }
  }


  /** Selection **/


  /**
   * Remove item from selection
   * @param {Object} item Item to remove, must contain the type and index fields
   */
  _removeFromSelection(item) {
    if (!item)
      return;

    this.selection[item.type].splice(item.index, 1);
  }

  /**
   * Find item in selection by its id
   * @param {string} id item id to find
   * @return {(Object | null)} Object containing item data, index and type, or null if such id is not in selection
   */
  _findById(id) {
    let item = null;

    this._eachType( (type) => {

      this.selection[type].forEach( (data, index) => {
        if (data.id === id)
          item = { data, index, type }
      });

    });

    return item;
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


  /** Selection Dialog **/


  /**
   * Initialize and show the selection dialog
   */
  _showSelectionDialog() {
    if (this.selectionDialog)
      this.selectionDialog.show();
    else
      this.selectionDialog = this._initSelectionDialog().show();
  }

  /**
   * Set event listeners and handlers within the selection dialog
   */
  _setDialogListeners() {
    $(this.selectionDialog.id).on('click', '.removable', (e) => {
      // Get clicked item id
      const itemId = $(e.target).attr('data-id');

      // Remove item and re-render dialog
      this.removeById(itemId);
      this.selectionDialog.setText(this._renderSelectionDialog());
    });
  }

  /**
   * Initializes a new selection dialog instance
   * @return {InformationDialog} initialized instance
   */
  _initSelectionDialog() {
    return new InformationDialog({
      title: "Current selection",
      subtitle: this._renderSelectionDialog(),
      wide: true,
      onShow: () => this._setDialogListeners()
    });
  }


  /** Renderers **/

  /**
   * Render Selection View
   */
  _render() {
    this._renderSelectionInfo();
  }

  /**
   * Render the selection info
   */
  _renderSelectionInfo() {
    $(`${this.selector} #selected-info`).html(this._selectionInfoText);
  }

  /**
   * Render the selection dialog
   */
  _renderSelectionDialog() {

    // Return if selection empty
    if ( this.isSelectionEmpty )
      return 'Selection is empty'

    let output = `<i>Click on an item to remove it from the selection.</i><br/>`

    this._eachType( (type) => {

      // Skip empty types
      if ( this.selection[type].length ) {

        // Render Type title
        output += `<span class='label-styled label-w-margin'> ${this._itemTypes[type]} </span> <br>`;

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
   * Get the length of the selection
   * @return {int} length of entire selection
   */
  get _selectionLength() {
    return Object.values(this.selection)
                 .reduce( (total, subSelection) => total + subSelection.length, 0 )
  }

  /**
   * Get the standard text of a reference to an item
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
   * Generate text for the selection info
   * @return {(int | string)} selection info text, represented in selection length or item reference
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

    // Find selected item data and type
    this._eachType( (type) => {
      if ( this.selection[type][0] )
        item = { data: this.selection[type][0], type: type }
    });

    // No item is currently selected
    return item;
  }

  /**
   * Map of all item types and their standard names, add more here
   * @return {Object} all item types - names map 
   */
  get _itemTypes() {
    return {
      thesauri: "Terminologies",
      managed_concept: "Code Lists",
      unmanaged_concept: "Code List Items",
      biomedical_concept_instance: "Biomedical Concepts",
      biomedical_concept_template: "Biomedical Concept Templates",
      form: "Forms"
    }
  }

}
