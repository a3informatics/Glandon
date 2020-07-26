import EditablePanel from 'shared/base/editable_panel'

import { $post, $delete } from 'shared/helpers/ajax'
import { $confirm } from 'shared/helpers/confirmable'

import { dtCLEditColumns } from 'shared/helpers/dt/dt_column_collections'
import { dtCLEditFields } from 'shared/helpers/dt/dt_fields'

/**
 * Code List Editor
 * @description DataTable-based Editor of a Code List (CRUD actions)
 * @extends EditablePanel class from shared/base/editable_panel
 * @author Samuel Banas <sab@s-cubed.dk>
 */
export default class CLEditor extends EditablePanel {

  /**
   * Create a Panel
   * @param {Object} params Instance parameters
   * @param {string} params.id ID of the currently edited item
   * @param {object} params.urls Must contain urls for 'data', 'update', 'newChild' and 'addChildren'
   * @param {string} params.selector JQuery selector of the target table
   * @param {function} params.extendTimer Callback for Timer extend called on any Edit action
   */
  constructor({
    id,
    urls,
    selector = "#editor-panel table#editor",
    extendTimer
  }) {
    super({ selector, dataUrl: urls.data, updateUrl: urls.update, param: "managed_concept", columns: dtCLEditColumns(), fields: dtCLEditFields() });

    Object.assign(this, { id, newChildUrl: urls.newChild, addChildrenUrl: urls.addChildren, extendTimer });
    this._initSelector();
  }

  /**
   * Server request to create a new Code List Item, add to table
   */
  newChild() {
    this._loading(true);

    $post({
      url: this.newChildUrl,
      data: { "managed_concept": { identifier: "SERVERIDENTIFIER" } },
      done: (data) => this.refresh(),
      always: () => this._loading(false)
    });
  }

  /**
   * Server request to add one or more existing Code List Items to this Code List
   */
  addChildren(childrenIds) {
    this._loading(true);

    $post({
      url: this.addChildrenUrl,
      data: { "managed_concept": { set_ids: childrenIds } },
      done: (data) => {
        this.refresh();
        this._onEdited(); // Item edited callback
      },
      always: () => {}
    });
  }

  /**
   * Server request to remove item (row) from the Code List
   * @param {DataTable Row} tr Reference to the DT Row instance to be removed
   */
  removeChild(tr) {
    // Require user confirmation
    $confirm({
      subtitle: "This action will remove the Code List Item reference from this Code List. If it is its only parent, the item will be removed from the system.",
      dangerous: true,
      callback: () => {
        this._loading(true);

        // Make DELETE request
        $delete({
          url: tr.data().delete_path,
          done: (r) => this.removeItems(tr),
          always: () => this._loading(false)
        });
      }
    });
  }

  /** Private **/

  /**
   * Check if item editable - must have referenced data property set to true
   * @override super's _editable
   * @param {object} modifier Contains the reference to the cell being edited
   * @returns {boolean} true/false ~~ enable/disable editing for the cell
   */
  _editable(modifier) {
    return !this.table.row(modifier.row).data().referenced;
  }

  /**
   * Extends the Token Timer on any edit action
   * @override super's _onEdited
   */
  _onEdited(e, json) {
    this.extendTimer();
  }

  /**
   * Sets event listeners, handlers
   */
  _setListeners() {
    // Call super's _setListeners first
    super._setListeners();

    // Format the updated data before sending to the server
    this.editor.on('preSubmit', (e, d, type) => {
      if (type === 'edit')
        this._formatUpdateData(d);
    });

    // Edit tags
    $(this.selector).on('click', 'tbody td.editable.edit-tags', (e) => {
      const editTagsUrl = this._getRowDataFrom$(e.target).edit_tags_path;
      if (editTagsUrl)
        window.open(editTagsUrl, '_blank').focus();
    })

    // Add New Child
    $('#new-item-button').on('click', () => this.newChild());
    // Add Existing Child
    $('#add-existing-button').on('click', () => this.itemSelector.show());
    // Refresh
    $('#refresh-button').on('click', () => this.refresh());
    // Remove item
    $(this.selector).on('click', 'tbody .remove', (e) => this.removeChild(this._getRowFrom$(e.target)));
    // Help dialog
    $('#editor-help').on('click', () => new InformationDialog({div: $("#information-dialog-cl-edit")}).show() )
  }

  /**
   * Formats the update data to be compatible with server
   * @param {object} d DataTables Editor data object
   */
  _formatUpdateData(d) {
    const itemId = Object.keys(d.data)[0];
    d.edit = d.data[itemId];
    d.edit.parent_id = this.id;
    delete d.data;
  }

  /**
   * Initialize Items Selector for adding Code List Items to the Code List
   */
  _initSelector() {
    this.itemSelector = new ItemsSelector({
      id: "add-children",
      types: { clitems: true },
      description: "Select one or more Code List Items to add to the Code List.",
      multiple: true,
      callback: (s) => {
        // Format selection into an array of ids
        const childIds = s.clitems.map((item) => item.id);
        this.addChildren(childIds);
      }
    });
  }

  /**
   * Extend default Editable Panel options
   * @return {Object} DataTable options object
   */
  get _tableOpts() {
    let options = super._tableOpts;

    // CSS Styling for editable rows
    options.createdRow = (row, data, idx) => {
      let rowClass = (!data.referenced ? 'row-sponsor' : data.uri.includes('cdisc') ? 'row-cdisc' : 'row-disabled');
      $(row).addClass(rowClass);
    }

    return options;
  }

}
