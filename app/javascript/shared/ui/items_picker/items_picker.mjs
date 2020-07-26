import ModalView from 'shared/base/modal_view'

import SelectionView from 'shared/ui/items_picker/selection_view'
import TabsLayout from 'shared/ui/tabs_layout'
import UnmanagedItemSelector from 'shared/ui/items_picker/unmanaged_item_selector'
import ManagedItemSelector from 'shared/ui/items_picker/managed_item_selector'

/**
 * Items Picker
 * @description System-wide, Item Picker for version-based managed/unmanaged item types
 * @extends ModalView class from 'shared/base/modal_view'
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class ItemsPicker extends ModalView {

  /**
   * Create Items Picker instance
   * @param {Object} params Instance parameters
   * @param {string} params.id unique element id of the Items Picker modal
   * @param {array} params.types array of param names of allowed types, @see itemTypes map for supported types
   * @param {string} params.description custom text to be rendered in the Items Picker description, optional
   * @param {boolean} params.multiple value representing whether multiple selection is enabled or disabled [defaul=false]
   * @param {function} params.onSubmit callback to when user submits their selection, passes getSelection object as the argument, @see SelectionView.getSelection
   */
  constructor({
    id,
    types = [],
    description,
    multiple = false,
    onSubmit = () => { }
  }) {
    super( { selector: `#items-picker-${id}` } );

    Object.assign(this, { multiple, description, types: [...new Set(types)], onSubmit });

    this._initialize();
    this._setListeners();
  }

  /**
   * Reset Items Picker to its initial state
   */
  reset() {
    // Iterate item selector instances and clear each
    for ( const selector of Object.values(this.selectors) ) {
      selector.clear();
    }

    // Clear selection view
    this.selectionView.clear();
  }

  /**
   * Set a custom text for the Items Picker description and reneder
   * @param {string} description the new description text, cannot be a falsey value
   */
  setDescription(description) {
    if (description)
      this.modal.find('#items-picker-description').html(description);
  }

  /**
   * Set a custom submit callback for when user submits their selection
   * @param {function} params.onSubmit callback to when user submits their selection, passes getSelection object as the argument, @see SelectionView.getSelection
   */
  setOnSubmit(onSubmit) {
    this.onSubmit = callback;
  }


  /** Private **/

  /**
   * Initialize the Tabs layout, Selection view and specified selector instances
   */
  _initialize() {
    // Initialize Tabs layout in Items Picker
    TabsLayout.initialize(`${this.selector} #items-picker-tabs`);

    // Initialize Selection View
    this.selectionView = new SelectionView({
      selector: this.selector,
      multiple: this.multiple,
      itemTypes: this.itemTypes
    });

    // Initialize Selectors
    this.selectors = this._initSelectors();

    // Set custom description if specified
    this.setDescription(this.description)
  }

  /**
   * Called when on modal show, open the first available Tab
   */
  _onShow() {
    $(`${this.selector} #items-picker-tabs .tab-option`)[0].click();
  }

  /**
   * Called when on modal hide, reset Items Picker to initial state
   */
  _onHide() {
    this.reset();
  }

  /**
   * Set event listeners and handlers
   */
  _setListeners() {
    // Load the tab contents on tab-switch
    TabsLayout.onTabSwitch(`${this.selector} #items-picker-tabs`, (optionId) => {
      // Get item type from the tab id
      const type = this._tabSelectorToType(optionId);

      if (this.selectors[type])
        this.selectors[type].load();
    });

    // Selection change event, toggle Submit button's disabled state
    this.selectionView.div.on('selection-change', (e, type) => {
      this.modal.find('#items-picker-submit').toggleClass('disabled', this.selectionView.selectionEmpty);
    });

    // Items Picker submit button click event, call _submitSelection
    this.modal.find('#items-picker-submit').on('click', () => this._submitSelection() );
  }

  /**
   * Execute user-specified onSubmit callback and pass selectionView's getSelection object as the argument and hide the Items Picker
   */
  _submitSelection() {
    // Do not submit an empty selection
    if (this.selectionView.selectionEmpty)
      return;

    this.onSubmit(this.selectionView.getSelection());
    this.hide();
  }

  /**
   * Initialize selector instances based on the user-defined allowed types, remove the unused ones from DOM
   */
  _initSelectors() {
    let selectors = { }

    for ( const type of Object.keys(this.itemTypes) ) {
      // Initialize selector
      if ( this.types.includes(type) )
        selectors[type] = this._newSelectorInstance(type)
      // Remove selector from DOM
      else
        this._removeSelector(type)
    }

    return selectors;
  }

  /**
   * Creates a new parameterized managed_item or unmanaged_item selector instance based on argument
   * @param {string} type selector param type to be instantiated
   */
  _newSelectorInstance(type) {
    switch (type) {
      case 'unmanaged_concept':
        return new UnmanagedItemSelector({
          selector: this._typeToTabSelector(type),
          multiple: this.multiple,
          selectionView: this.selectionView,
          urls: _globalIHUrls,
          param: type,
          errorDiv: this._errorDiv
        });
        break;
      default:
        return new ManagedItemSelector({
          selector: this._typeToTabSelector(type),
          multiple: this.multiple,
          selectionView: this.selectionView,
          urls: _globalIHUrls,
          param: type,
          errorDiv: this._errorDiv
        });
        break;
    }
  }

  /**
   * Removes unused selector, table and the tab from the DOM
   * @param {string} type selector param type to be removed
   */
  _removeSelector(type) {
    type = type.replace(/_/g, '-');

    $(`#tab-${type}`).detach();
    $(`#selector-${type}`).detach();
  }

  /**
   * Helper for converting tab selector id to item type
   * @param {string} tabName tab selector element id
   * @return {string} equivalent item type
   */
  _tabSelectorToType(tabName) {
    return tabName.replace('selector-', '').replace('tab-', '').replace(/-/g, '_');
  }

  /**
   * Helper for converting item type to tab selector id
   * @param {string} param item type param
   * @return {string} equivalent tab selector
   */
  _typeToTabSelector(param) {
    return `${this.selector} #selector-${param.replace(/_/g, '-')}`;
  }

  /**
   * Map of all item types and their standard names, add more here
   * @return {Object} all item types - names map
   */
  get itemTypes() {
    return {
      thesauri: "Terminologies",
      managed_concept: "Code Lists",
      unmanaged_concept: "Code List Items",
      biomedical_concept_instance: "Biomedical Concepts",
      biomedical_concept_template: "Biomedical Concept Templates",
      form: "Forms"
    }
  }

  /**
   * Get the error div of the Items Picker modal
   * @return {JQuery Element} Items Picker's unique error div 
   */
  get _errorDiv() {
    return $(`${this.selector} #items-picker-error`)
  }

}
