import ModalView from 'shared/base/modal_view'

import SelectionView from 'shared/ui/items_picker/selection_view'
import TabsLayout from 'shared/ui/tabs_layout'
import UnmanagedItemSelector from 'shared/ui/items_picker/unmanaged_item_selector'
import ManagedItemSelector from 'shared/ui/items_picker/managed_item_selector'

import { rdfTypesMap } from 'shared/helpers/rdf_types'

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
   * @param {string} params.submitText custom Submit button text to be rendered in the Items Picker, optional
   * @param {boolean} params.multiple value representing whether multiple selection is enabled or disabled [defaul=false]
   * @param {array} params.buttons Extra buttons to be added to the footer (defined by objects with properties: id, css, text onClick)
   * @param {boolean} params.emptyEnabled value representing whether submission where no items are selected is allowed, [default=false]
   * @param {boolean} params.hideOnSubmit value representing whether the modal will be hidden on submit [default=true]
   * @param {function} params.onShow callback executed when Items Picker modal is shown
   * @param {function} params.onSubmit callback to when user submits their selection, passes getSelection object as the argument, @see SelectionView.getSelection
   * @param {function} params.onHide callback executed when Items Picker modal is hidden. Executes also after onSubmit
   */
  constructor({
    id,
    types = [],
    description,
    submitText,
    buttons = [],
    multiple = false,
    emptyEnabled = false,
    hideOnSubmit = true,
    onShow = () => { },
    onSubmit = () => { },
    onHide = () => { }
  }) {

    super( { selector: `#items-picker-${id}` } );

    Object.assign(this, {
      multiple, description, submitText, emptyEnabled,
      types: [...new Set(types)], buttons,
      onShow, onSubmit, onHide, hideOnSubmit
    });

    // Initialization
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
   * Set a custom text for the Items Picker Submit button and reneder
   * @param {string} subtmiText the new Submit text, cannot be a falsey value
   */
  setSubmitText(submitText) {

    if (submitText)
      this.modal.find('#items-picker-submit').html(submitText);

  }

  /**
   * Set a custom text for the Items Picker Submit button and reneder
   * @param {string} subtmiText the new Submit text, cannot be a falsey value
   */
  setSubmitText(submitText) {

    if (submitText)
      this.modal.find('#items-picker-submit').html(submitText);

  }

  /**
   * Disable a set of (already allowed) types tabs
   * @param {array} types Types to become disabled (must be a subset of allowed types )
   * @return {ItemsPicker} this instance (for method chaining)
   */
  disableTypes(types) {

    if ( !types )
      return;

    this.toggleAllTabs( true );

    for ( let type of types ) {

      if ( !this.types.includes( type ) )
        continue;

      let tabId = $( this._typeToTabSelector( type ) ).attr( 'data-tab' );
      $(`#${ tabId }`).addClass( 'disabled' );

    }

    return this;

  }

  /**
   * Disable all (already allowed) types tabs except the given ones
   * @param {array} types Types to remain enabled (must be a subset of allowed types)
   * @return {ItemsPicker} this instance (for method chaining)
   */
  disableTypesExcept(types) {

    if ( !types )
      return;

    this.toggleAllTabs( false );

    for ( let type of types ) {

      if ( !this.types.includes( type ) )
        continue;

      let tabId = $( this._typeToTabSelector( type ) ).attr( 'data-tab' );
      $(`#${ tabId }`).removeClass( 'disabled' );

    }

    return this;

  }

  /**
   * Enable all (already disabled) types tabs
   */
  toggleAllTabs(enable) {

    $(this.selector).find( '.tab-option.disabled' )
                    .toggleClass( 'disabled', !enable );

  }

  /**
   * Set and render additional buttons to the Items Picker footer
   */
  setButtons(buttons) {

    if ( !buttons || !buttons.length )
      return;

    this.buttons = buttons;
    this._renderButtons();

  }

  /**
   * Get currently active selector instance
   * @return {ManagedItemSelector | UnmanagedItemSelector} active selector instance
   */
  get activeSelector() {

    const activeTabId = $(this.selector).find('.tab-option.active').prop('id')
    return this.selectors[ this._tabSelectorToType( activeTabId ) ]

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

    // Set custom description and submit button text if specified
    this.setDescription(this.description)
    this.setSubmitText(this.submitText);

    // Enable Submit button if emptyEnabled setting set to true
    if ( this.emptyEnabled )
      this.modal.find('#items-picker-submit').removeClass('disabled');

    if ( this.buttons.length )
      this._renderButtons();

  }

  /**
   * Execute user-specified onSubmit callback and pass selectionView's getSelection object as the argument and hide the Items Picker
   */
  _submitSelection() {

    // Do not submit an empty selection
    if ( !this.emptyEnabled && this.selectionView.selectionEmpty )
      return;

    if ( this.onSubmit )
      this.onSubmit( this.selectionView.getSelection() );

    if ( this.hideOnSubmit )
      this.hide();

  }

  /**
   * Called on modal show, open the first available Tab, render selectionView
   */
  _onShow() {

    this.isOpen = true;

    // Execute onShow callback
    if ( this.onShow )
      this.onShow();

    this.selectionView._render();

    $(`${this.selector} #items-picker-tabs .tab-option:not(.disabled)`)[0].click();

  }

  /**
   * Called on modal hide, reset Items Picker to initial state, call onHide callback
   */
  _onHide() {

    // Execute onHide callback
    if ( this.onHide )
      this.onHide();

    this.reset();

    this.isOpen = false;

  }

  /**
   * Called on show animation completed, adjust currently displayed table columns
   */
  _onShowComplete() {
    this.activeSelector.adjustAllColumns();
  }

  /**
   * Set event listeners and handlers
   */
  _setListeners() {

    // Load the tab contents on tab-switch
    TabsLayout.onTabSwitch( `${this.selector} #items-picker-tabs`, optionId => {

      // Get item type from the tab id
      const type = this._tabSelectorToType( optionId );

      if ( this.selectors[type] )
        this.selectors[type].load();

    });

    // Selection change event, toggle Submit button's disabled state
    this.selectionView.div.on( 'selection-change', (e, type) => {

      if ( !this.emptyEnabled )
        this.modal.find( '#items-picker-submit' )
                  .toggleClass( 'disabled', this.selectionView.selectionEmpty );

    });

    // Items Picker submit button click event, call _submitSelection
    this.modal.find( '#items-picker-submit' )
              .on('click', () => this._submitSelection() );

  }

  /**
   * Initialize selector instances based on the user-defined allowed types, remove the unused ones from DOM
   */
  _initSelectors() {

    let selectors = {}

    for ( const type of Object.keys(this.itemTypes) ) {

      // Initialize selector
      if ( this.types.includes( type ) )
        selectors[type] = this._newSelectorInstance( type )

      // Remove selector from DOM
      else
        this._removeSelector( type )

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
          param: type
        });
        break;

      default:
        return new ManagedItemSelector({
          selector: this._typeToTabSelector(type),
          multiple: this.multiple,
          selectionView: this.selectionView,
          urls: _globalIHUrls,
          param: type
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

    this.modal.find(`#tab-${type}`).detach();
    this.modal.find(`#selector-${type}`).detach();

  }

  /**
   * Render additional buttons defined in the instance (properties: id, css, text, onClick)
   */
  _renderButtons() {

    // Clear
    this.modal.find( '.extra-btn' )
              .remove();

    // Render
    for ( let button of this.buttons ) {

      let $b = $('<button>').addClass( `btn medium extra-btn ${ button.css }` )
                            .prop( 'id', button.id )
                            .text( button.text )
                            .on( 'click', button.onClick );

      this.modal.find('#items-picker-close')
                .after( $b );

    }

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
   * Enable or disable the loading state of the Items Picker
   * @param {boolean} enable Specifies the target loading state of the IP
   */
  _loading(enable) {

    // Enable / Disable all panels
    Object.values( this.selectors )
          .forEach( tab => tab._toggleInteractivity( !enable ) );

    // Enable / Disable buttons and tabs
    this.modal.find( '.btn, .tab-option' )
              .toggleClass( 'disabled', enable )

              // Add loading state animation to the Submit button
              .filter( '#items-picker-submit' )
              .toggleClass( 'el-loading', enable );

  }

  /**
   * Map of item types (param names) and their rdf type map references supported available in Items Picker
   * Add more when needed
   * @return {Object} item types (param names) - rdf types map
   */
  get itemTypes() {

    return {
      thesauri: rdfTypesMap.TH,
      managed_concept: rdfTypesMap.TH_CL,
      unmanaged_concept: rdfTypesMap.TH_CLI,
      biomedical_concept_instance: rdfTypesMap.BC,
      biomedical_concept_template: rdfTypesMap.BCT,
      form: rdfTypesMap.FORM,
      sdtm_ig_domain: rdfTypesMap.SDTM_DOMAIN,
      sdtm_class: rdfTypesMap.SDTM_CLASS,
      sdtm_sponsor_domain: rdfTypesMap.SDTM_SD,
      protocol: rdfTypesMap.PROTOCOL,
      protocol_template: rdfTypesMap.PROTOCOL_TEMPLATE
    }

  }

}
