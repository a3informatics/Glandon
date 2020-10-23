import Cacheable from 'shared/base/cacheable'

import TokenTimer from 'shared/custom/tokens/token_timer'
import CreateBCView from 'shared/custom/biomedical_concept_instances/bc_create'
import BCEditor from 'shared/custom/biomedical_concept_instances/edit/bc_editor'
import ItemsPicker from 'shared/ui/items_picker/items_picker'
import InformationDialog from 'shared/ui/dialogs/information_dialog'

import { $get, $post } from 'shared/helpers/ajax'
import { renderSpinnerIn$, removeSpinnerFrom$ } from 'shared/ui/spinners'
import { tableInteraction } from 'shared/helpers/utils'
import { alerts } from 'shared/ui/alerts'
import { iconBtn, tokenTimeoutBtn } from 'shared/ui/buttons'

/**
 * Biomedical Concept Edit Manager
 * @description Manages the editing and locking of one or more Biomedical Concept Instances
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class BCManager extends Cacheable {

  /**
   * Create a BCManager
   * @param {Object} params Instance parameters
   * @param {string} params.baseBCId the id of the Biomedical Concept whose edit page is the manager contained in
   * @param {object} params.urls Must contain urls with placeholders for 'data', 'update', 'edit'
   * @param {int} params.tokenWarningTime Time in seconds when to start showing a token expiry warning, user-defined setting
   * @param {string} params.selector Unique selector of the Manager parent div
   */
  constructor({
    baseBCId,
    urls,
    tokenWarningTime,
    selector = "#bc-manager-panel",
  }) {

    super();

    Object.assign(this, { baseBCId, urls, tokenWarningTime, selector });

    // Initialization
    this._setListeners();
    this._initialize();

    // Fetch data for base BC
    this.editBC(this.baseBCId, true);

  }

  /**
   * Execute request to lock a BC for editing and add it to the BC Manager
   * @param {string} id unique id of the BC to be added to the edit manager
   * @param {boolean} isBase value representing whether the BC is the base BC instance, optional, [default = false]
   */
  editBC(id, isBase = false) {

    // Check if BC instance already added
    if ( this.activeBCs[id] ) {
      alerts.error('This BC has already been added.');
      return;
    }

    this._loading(true);

    // Edit BC request
    $get({
      url: this._buildUrl('edit', id),
      done: (r) => {
        this._loading(false)
        this._addBCToManager(r.data, r.token_id, isBase)
      },
      always: () => this._loading(false),
      rawResult: true
    });

  }


  /** Private **/


  /**
   * Initialize the Biomedical Concept Manager
   */
  _initialize() {

    // Create the active BCs object
    this.activeBCs = {}

    // Initialize the BC Editor
    this.bcEditor = new BCEditor({
     urls: this.urls,
     loadCallback: (t) => this._cacheEditorData(),
     loadingCallback: (e) => this._loading(e),
     onEdited: () => {
       this._cacheEditorData();
       this.bcEditor.bcInstance.token.extend();
     }
    });

    // Initialize the Create BC View
    this.createBCView = new CreateBCView({
      onCreated: (data) => {
        alerts.success('BC created successfully.');
        this.editBC(data.id);
      },
      onShow: () => this.bcEditor.kDisable(),
      onHide: () => this.bcEditor.kEnable()
    });

    // Initialize an Items Picker instance for BCs to add to the Editor with
    this.editBCPicker = new ItemsPicker({
      id: 'add-bc-edit',
      types: ['biomedical_concept_instance'],
      submitText: 'Add to Editor',
      onSubmit: (s) => this.editBC( s.asIDsArray()[0] ),
      onShow: () => this.bcEditor.kDisable(),
      onHide: () => this.bcEditor.kEnable()
    });

  }

  /**
   * Set Event listeners and handlers
   */
  _setListeners() {

    // BC card Edit click event
    this._bcListView.on( 'click', '.biomedical-concept', (e) => {
      this._onBCSelected( $(e.currentTarget).closest('.card.mini') )
    });

    // BC Card Remove click event
    this._bcListView.on('click', '.remove-bc', (e) => {
      this._removeBCFromManager( $(e.currentTarget).closest('.biomedical-concept') )
      e.stopPropagation();
    });

    // Add a BC to Edit button click event
    this._view.find('#add-bc-edit-button').on('click', () =>
      this.editBCPicker.show()
    )

    // BC Edit help button click event, show InformationDialog
    this._view.find('#editor-help').on('click', () => new InformationDialog({
      div: '#information-dialog-bc-edit'
    }).show())

    // Release all edit locks on window unload
    window.onbeforeunload = () => {
      let tokenIds = Object.values( this.activeBCs ).map( (bc) => bc.token.tokenId );
      TokenTimer.releaseMultiple(tokenIds);
    }

  }

  /**
   * Add a BC to the Manager and handle UI updates
   * @param {Object} bcData Data object of the BC instance
   * @param {string} tokenId Id of the token associated with the BC instance
   * @param {boolean} isBase value representing whether the BC is the base BC instance, optional, [default = false]
   */
  _addBCToManager(bcData, tokenId, isBase = false) {

      // Render BC card in the scrollView
      this._renderBCCard(bcData, isBase);

      // Add BC to collection with parameters and a TokenTimer instance
      this.activeBCs[bcData.id] = {
        id: bcData.id,
        token: new TokenTimer({ 
          tokenId,
          warningTime: this.tokenWarningTime,
          parentEl: `.biomedical-concept[data-id='${bcData.id}']`,
          timerEl: '.token-timeout',
          reqInterval: 20000,
          handleUnload: false
        }),
        dataUrl: this._buildUrl('data', bcData.id),
        updateUrl: this._buildUrl('update', bcData.id),
        isBase
      }

      // Select and open default BC if isBase
      if (isBase) {
        this.baseBCId = bcData.id;
        this._selectFirstBC()
      }

  }

  /**
   * Remove a BC instance from the BC Manager, release its token
   * @param {JQuery Element} bcCard Element representing the card element of the BC instance
   */
  _removeBCFromManager(bcCard) {

    let bc = this._getBCByElement(bcCard);

    // Disallow removing base BC from Manager
    if ( this.loadingActive || bc.isBase )
      return;

    // Release token
    this.activeBCs[bc.id].token.release();

    // Remove locally
    delete this.activeBCs[bc.id];
    bcCard.remove();

    // Select default BC card
    this._selectFirstBC()

  }

  /**
   * Handle BC Edit selected callback, update cards UI and load BC data into editor
   * @param {JQuery Element} bcCard Element representing the card element of the BC instance
   */
  _onBCSelected(bcCard) {

    // Disallow selection when card disabled
    if ( this.loadingActive )
      return;

    let bcInstance = this._getBCByElement(bcCard);

    // Handle UI update
    this._updateCardsUI(bcCard);

    // Set Editor's new bcInstance
    this.bcEditor.setBCInstance(bcInstance);

    // Load bcInstance Editor data from cache / server
    if ( this._hasCacheEntry( bcInstance.id ) )
      this.bcEditor._render( this._getFromCache(bcInstance.id), true );
    else {
      this._loading(true);
      this.bcEditor.loadData();
    }

  }

  /**
   * Save the current data in the BC Editor to the local cache
   */
  _cacheEditorData() {

    let cacheKey = this.bcEditor.bcInstance.id,
        cacheData = this.bcEditor.table.rows({ order: 'index' }).data().toArray();

    this._saveToCache( cacheKey, cacheData, true );

  }

  /**
   * Get the active BC instance object from the manager from a JQUery element
   * @param {(string | JQuery element)} element selector / element referencing an item within a BC card
   * @return {Object} Manager's BC instance object referring to the given id, null if not found
   */
  _getBCByElement(e) {

    let id = $(e).closest('.biomedical-concept').attr('data-id');

    return this.activeBCs[id]

  }

  /**
   * Toggle loading state of the BC Manager
   * @param {boolean} enable value representing the desired loading state enabled / disabled
   */
  _loading(enable) {

    this.loadingActive = enable;

    // Enable / disable BC Manager buttons
    this._view.find('.clickable, .btns-wrap .btn, .biomedical-concept')
              .toggleClass('disabled', enable);

    // Enable / disable spinner animation in the BCs view and interactivity of the Editor
    if (enable) {
      renderSpinnerIn$(this._bcListView, 'tiny');
      tableInteraction.disable(this.bcEditor.selector);
    }
    else {
      removeSpinnerFrom$(this._bcListView);
      tableInteraction.enable(this.bcEditor.selector);
    }

  }

  /**
   * Simulates edit button click on the first BC card in the scrollView
   */
  _selectFirstBC() {
    this._bcListView.find('.biomedical-concept')
                    .get(0)
                    .click();
  }

  /**
   * Build a url representing an action referencing a BC instance
   * @param {string} type url type ('data'/'edit')
   * @param {string} id Id of the BC instance
   * @return {string} url of correct type pointing to the correct BC instance
   */
  _buildUrl(action, id) {
    return this.urls[action].replace('bcID', id)
  }

  /**
   * Get the BC Manager view element
   * @return {JQuery Element} BC Manager element from instance selector
   */
  get _view() {
    return $(this.selector);
  }

  /**
   * Get the BC Manager's BCs list view element
   * @return {JQuery Element} BC Manager's BCs list element from instance selector
   */
  get _bcListView() {
    return this._view.find('#bc-list');
  }

  /**
   * Clear and add selected BC card styling
   * @param {JQuery element} bcCard .card element of the newly selected BC
   */
  _updateCardsUI(bcCard) {

    // Unselect card
    this._bcListView.find('.biomedical-concept.selected')
                    .removeClass('selected');

    // Select clicked card
    bcCard.closest('.biomedical-concept')
          .addClass('selected');

  }

  /**
   * Build and Render a BC instance card in the BCs list view
   * @param {Object} data BC item data object
   * @param {boolean} isBase value representing whether the BC is the base BC instance
   */
  _renderBCCard(data, isBase) {

    let bcCardHTML = `<div class="card mini clickable no-border biomedical-concept" data-id="${data.id}">
                        <div class="card-content">
                          <div class="icon-biocon text-prim-light text-xlarge" style="margin-right: 15px"></div>
                          <div class="section primary">
                            <div>
                              <span class="font-regular">${data.has_identifier.identifier}</span>  v${data.has_identifier.semantic_version}
                            </div>
                            <div>${data.label}</div>
                            <div>${data.has_state.by_authority.ra_namespace.short_name}</div>
                          </div>
                          <div class="section secondary">
                            ${ tokenTimeoutBtn() }
                            ${ iconBtn({ icon: 'times', color: 'red remove-bc', disabled: isBase }) }
                          </div>
                        </div>
                      </div>`;

    this._bcListView.append(bcCardHTML);

  }

}
