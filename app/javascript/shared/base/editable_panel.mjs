import TablePanel from 'shared/base/table_panel'

import { $handleError } from 'shared/helpers/ajax'
import { alerts } from 'shared/ui/alerts'

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
   * @param {Object} params.tableOptions Custom DT options object, will be merged with this instance's _tableOpts, optional
   * @param {function} params.loadCallback Callback to data fully loaded, receives table instance as argument, optional
   * @param {boolean} params.autoHeight Specifies whether the height of the table should match the window size, and add a horizontal scroll, optional
   * @param {boolean} params.requiresMetadata Specifies whether the Editor requires additional metadata load, optional
   * @param {Object} args Optional additional arguments for extending classes
   */
  constructor({
    selector,
    dataUrl,
    updateUrl,
    param,
    count = 1000,
    columns = [],
    fields = [],
    idSrc = "id",
    deferLoading = false,
    order = [[0, "desc"]],
    cache = true,
    tableOptions = {},
    loadCallback = () => {},
    autoHeight = false,
    requiresMetadata = false
  }, args = {}) {

    super({
      url: dataUrl, 
      extraColumns: columns,
      selector, param, count, cache, tableOptions, loadCallback,
      order, autoHeight, deferLoading
    }, {
      updateUrl, fields, idSrc, requiresMetadata,
      ...args
    });

  }

  /**
   * Add items (rows) to a table.
   * @param {array | object} data Item data object. Can be an array of multiple
   */
  addItems(data) {

    if ( !Array.isArray( data ) ) 
      this.table.row.add( data );

    else
      data.forEach( dataItem => 
        this.table.row.add( dataItem )
      );

    // Redraw and callback to onEdited 
    this.table.draw();
    this._onEdited();

  }

  /**
   * Remove items (rows) from the table
   * @param {?} data Reference to the row to be removed. Can be an array of multiple
   */
  removeItems(data) {

    if ( !Array.isArray( data ) ) 
      this.table.row( data ).remove();

    else
      data.forEach( dataItem => 
        this.table.row( dataItem ).remove()
      );

    // Redraw and callback to onEdited 
    this.table.draw();
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

    const newOpts = this._editorAjaxOpts;
    newOpts.url = this.updateUrl;

    this.editor.ajax( newOpts );

  }

  /**
   * Destroy the DataTable instance in the Panel
   */
  destroy() {

    super.destroy();
    this.editor.destroy();

  }

  /**
   * Get the currently edited field name
   * @return {string} name of the field, undefined if none
   */
  get currentField() {
    return this.editor.displayed()[0];
  }

  /**
   * Get the field name from column index
   * @param {integer} column Column index
   * @returns {string} Name of the editField of the given column
   */
  fieldFromColumn(column) {
    return this.table.settings()[0].aoColumns[column].editField;
  }

  /**
   * Enable the Editor Key & Click interaction
   */
  keysEnable() {
    this.table.keys?.enable();
  }

  /**
   * Disable the Editor Key & Click interaction
   */
  keysDisable() {
    this.table.keys?.disable();
  }


  /** Private **/


  /**
   * Sets event listeners, handlers
   * Used for table related listeners only
   */
  _setTableListeners() {
    // Before editing - check _editable condition first
    this.editor.on( 'preOpen', () => {

      if ( this._editable( this.editor.modifier() ) )
        this.editor.enable();
      else
        this.editor.disable();

    });

    // Editing started - update UI
    this.editor.on( 'open', () => 
      this._updateUI('open') 
    );

    // Editing finished/closed - update UI
    this.editor.on( 'preClose', () => 
      this._updateUI( 'close' ) 
    );

    // Loading animation
    this.editor.on( 'processing', (ev, enable) => 
      this._inlineProcessing( ev, enable )
    );

    // Pre-data-submit, change data format
    this.editor.on( 'preSubmit', (e, d, type) => {

      type === 'edit' && this._preformatUpdateData( d );

    });

    // Post-data-submit, change data format before adding to Editor
    this.editor.on( 'postSubmit', (e, json, data) => {

      json && json.data && this._postformatUpdatedData( data, json.data );

    });

    // Data submit server error
    this.editor.on( 'submitError', (x, s, e) => 
      $handleError(x, s, e)
    );

    // Data submitted - Item Edited callback
    this.editor.on( 'submitSuccess submitUnsuccessful', (e, json) => 
      this._onSubmitted( json )
    );

    // Update UI on keypress in TA. Handle Submit.
    $(`${ this.selector } tbody`).on( 'keydown', 'textarea', e => {

      this._updateUI('input');

      // Submit on Enter key press
      if( e.which == 13 && !e.shiftKey ) {
        this.editor.submit();
        e.preventDefault();
      }

    });

    // Custom inline editing with no onBlur action event for Pickable fields, bugfix
    this.table.on( 'click', 'td.editable.inline.pickable', e => {

      e.detail === 2 && this.editor.inline( e.currentTarget, { onBlur: 'none' });

    });

    this.table.on( 'key', ( e, dt, key, cell ) => {

      if ( $( cell.node() ).hasClass( 'editable inline pickable' ) )
        this.editor.close()
                   .inline( cell.node(), { onBlur: 'none' } );

    });

  }

  /**
   * Formats the update data to be compatible with server, maps to a simple array
   * To change data format, alter the d object
   * @override for custom behavior
   * @param {object} d DataTables Editor data object to be altered
   * @return {Array} Simple formatted data
   */
  _preformatUpdateData(d) {

    let fData = Object.keys( d.data ).map( id =>
      Object.assign( {}, d.data[ id ], { id } )
    );

    return fData;

  }

  /**
   * Formats the updated data returned from the server before being added to Editor
   * @override for custom behavior
   * @param {object} oldData Data object sent to the server
   * @param {object} newData Data returned from the server
   */
  _postformatUpdatedData(oldData, newData) { }

  /**
   * Called after Editor initialized, use to load additional metadata (e.g. fetch options for Editor select field)
   * @override for custom behavior
   */
  _loadMetadata() { }

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
  _onEdited() { }

  /**
   * Invoked on Editor submitSuccessful & submitUnsuccessful events
   * @param {object} json JSON data returned from the server
   */
  _onSubmitted(json) {

    // Handle any errors thrown by the server
    json && json.errors && alerts.error( json.errors.join(' & ') );

    this._onEdited();

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
    $( `${ this.selector } td.editable textarea` ).css( 'height', '' );
  }

  /**
   * Resizes textarea to to fit its contents
   */
  _resizeTA() {

    const $textArea = $( `${ this.selector } td.editable textarea` );

    if ( $textArea.length ) {

      const { scrollHeight } = $textArea[0];
      $textArea.css( 'height', scrollHeight + 4 );

    }

  }

  /**
   * Initialize a new DataTable Editor
   */
  _initEditor() {

    this.editor = new $.fn.dataTable.Editor( this._editorOpts );

    if ( this.requiresMetadata )
      this._loadMetadata();

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
   * @param {Event} e Original DT Event
   * @param {boolean} enable True/false ~~ enable/disable processing state
   */
  _inlineProcessing(e, enable) {

    let modifier = e.currentTarget.s.modifier,
        targetNode = this.table.cell(modifier).node();

    $( this.selector ).find( targetNode )
                      .toggleClass( 'processing', enable );

  }

  /**
   * Initialize Editor and DataTable
   */
  _initTable() {

    // Initialize Editor first
    this._initEditor();
    // Initialize DataTable after
    super._initTable();
    // Initialize Pickers last
    this._initPickers();

  }

  /**
   * Extend default DataTable init options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {

    const options = super._tableOpts;

    // Excel-like Keys navigation functionality
    options.keys = {
      columns: '.editable.inline',
      editor: this.editor
    }

    return options;

  }

  /**
   * Default Editor init options
   * @return {Object} DataTable Editor init object
   */
  get _editorOpts() {

    return {
      ajax: this._editorAjaxOpts,
      table: this.selector,
      fields: this.fields,
      idSrc: this.idSrc,
      formOptions:{
        inline: {
          drawType: 'page'
        }
      }
    }

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
        data: d => JSON.stringify( d )
      }
    }

  }

}
