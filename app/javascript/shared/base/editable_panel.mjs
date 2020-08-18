import TablePanel from 'shared/base/table_panel'

/**
 * Base Editable Panel
 * @description Extensible Editable DataTable panel
 * @extends TablePanel class from shared/base/table_panel
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class EditablePanel extends TablePanel {

  /**
   * Create an Editable Panel instance
   * @param {Object} params Instance parameters
   * @param {string} params.selector JQuery selector of the target table
   * @param {string} params.dataUrl Url of source data
   * @param {string} params.updateUrl Url for POSTing data updates
   * @param {string} params.param Strict parameter name required for the controller params
   * @param {int} params.count Count of items fetched in one request
   * @param {Array} params.columns Column definitions
   * @param {Array} params.fields Editor fields definitions
   * @param {string} params.idSrc Data ID source for the editor, default = "id"
   * @param {boolean} params.deferLoading Set to true if data load should be deferred. Load data has to be called manually in this case
   * @param {Array} params.order DataTables deafult ordering specification, optional. Defaults to first column, descending
   * @param {boolean} params.cache Specify if the panel data should be cached. Optional
   * @param {function} params.loadCallback Callback to data fully loaded, receives table instance as argument, optional
   */
  constructor({
    selector,
    dataUrl,
    updateUrl,
    param,
    count = 500,
    columns = [],
    fields = [],
    idSrc = "id",
    deferLoading = false,
    order = [[0, "desc"]],
    cache = true,
    loadCallback = () => {}
  }) {
    super({ selector, url: dataUrl, param, count, extraColumns: columns, deferLoading, cache, loadCallback, order },
          { updateUrl, fields, idSrc });
  }

  /**
   * Add items (rows) to a table.
   * @param {?} data Item data object. Can be an array of multiple
   */
  addItems(data) {
    if ( Array.isArray(data) ) {
      for(const item in data) {
        this.table.row.add(item);
      }
    }
    else
      this.table.row.add(data);

    this.table.draw();
    // Item edited callback
    this._onEdited();
  }

  /**
   * Remove items (rows) from the table
   * @param {?} data Reference to the row to be removed. Can be an array of multiple
   */
  removeItems(data) {
    if ( Array.isArray(data) ) {
      for(const item in data) {
        this.table.row(item).remove();
      }
    }
    else
      this.table.row(data).remove();

    this.table.draw();
    // Item edited callback
    this._onEdited();
  }

  /**
   * Set a new data url to the instance
   * @param {string} newUrl new data url
   */
  setDataUrl(newUrl) {
    this.url = newUrl;
  }

  /**
   * Set a new update url to the instance, updates editor's ajax config
   * @param {string} newUrl new update data url
   */
  setUpdateUrl(newUrl) {
    this.updateUrl = newUrl;

    let newOpts = this._editorAjaxOpts;
    newOpts.url = this.updateUrl;

    this.editor.ajax(newOpts);
  }


  /** Private **/


  /**
   * Sets event listeners, handlers
   */
  _setListeners() {
    // Before editing - check _editable condition first
    this.editor.on('preOpen', () => {
      if (this._editable(this.editor.modifier()))
        this.editor.enable();
      else
        this.editor.disable();
    });
    // Editing started - update UI
    this.editor.on('open', () => this._updateUI('open') );
    // Editing finished/closed - update UI
    this.editor.on('preClose', (e) => this._updateUI('close') );
    // Loading animation
    this.editor.on('processing', (ev, enable) => this._inlineProcessing(enable));
    // Data submit server error
    this.editor.on('submitError', (x, s, e) => handleAjaxError(x, s, e));
    // Data submitted - Item Edited callback
    this.editor.on('submitSuccess submitUnsuccessful', (e, json) => {
      // Handle any errors thrown by the server
      if (json.errors)
        displayAlerts(alertError(json.errors.join(' & ')));

      this._onEdited();
    });

    // Update UI on keypress in TA. Handle Submit.
    $(this.selector).on('keydown', 'textarea', (e, dt, c) => {
      this._updateUI('input');

      // Submit on Enter key press
      if(e.which == 13 && !e.shiftKey) {
        this.editor.submit();
        e.preventDefault();
      }
    });
  }

  /**
   * Override this to check for any condiditions that should not allow editing of the specific row
   * Return true for enabling editing, false for disabling
   * @param {object} modifier Contains the reference to the cell being edited
   * @returns {boolean} true/false ~~ enable/disable editing for the cell
   */
  _editable(modifier) {
    return true;
  }

  /**
   * Invoked on any edit action. Override if you need to do anything onEdit, e.g. extend the Token Timer.
   */
  _onEdited() {
    // Empty by default
  }

  /**
   * Updates the UI on Editing start/input/end
   * Override/edit this if you need to do any extra UI updates
   * @param {string} type Event type - open/close/input
   */
  _updateUI(type) {
    switch (type) {
      case 'open':
      case 'input':
        this._resizeTA();
        break;
      case 'close':
        this._resetTA();
        break;
    }
  }

  /**
   * Resets textarea to its original size
   */
  _resetTA() {
    $(`${this.selector} td.editable textarea`).css('height', '');
  }

  /**
   * Resizes textarea to to fit its contents
   */
  _resizeTA() {
    if ( $(`${this.selector} td.editable textarea`).length ) {
      let newHeight = $(`${this.selector} td.editable textarea`)[0].scrollHeight + 4;
      $(`${this.selector} td.editable textarea`).css('height', newHeight);
    }
  }

  /**
   * Initialize a new DataTable Editor
   */
  _initEditor() {
    this.editor = new $.fn.dataTable.Editor({
      ajax: this._editorAjaxOpts,
      table: this.selector,
      fields: this.fields,
      idSrc: this.idSrc
    });
  }

  /**
   * Initializes Items Pickers to use in an Editable Panel (if any)
   * Override to add custom pickers
   */
  _initPickers() {
    this.editor.pickers = { }
  }

  /**
   * Change processing state of a focused cell
   * @param {boolean} enable True/false ~~ enable/disable processing state
   */
  _inlineProcessing(enable) {
    $(this.selector).find("td.inline.focus").toggleClass("processing", enable);
  }

  /**
   * Initialize Editor and DataTable
   */
  _initTable() {
    // Initialize Editor first
    this._initEditor();
    // Initialize DataTable after
    this.table = $(this.selector).DataTable(this._tableOpts);
    // Initialize Pickers last
    this._initPickers();
  }

  /**
   * Extend default DataTable init options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {
    const options = super._tableOpts;

    options.columns = [...this.extraColumns];
    // Excel-like Keys navigation functionality
    options.keys = {
      columns: '.editable.inline',
      editor: this.editor
    }

    return options;
  }

  /**
   * Default Editor AJAX options
   * @return {Object} DataTable Editor AJAX options object
   */
  get _editorAjaxOpts() {
    return {
      edit: {
        type: 'PUT',
        url: this.updateUrl,
        contentType: 'application/json',
        data: (d) => JSON.stringify(d)
      }
    }
  }

}
