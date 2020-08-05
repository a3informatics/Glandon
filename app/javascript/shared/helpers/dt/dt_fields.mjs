import { icons } from 'shared/ui/icons'
import { termReferences } from 'shared/ui/collections'

/**
 * Map referencing field-types to their definitions (add more as needed)
 * These fields must be first initialized with the dtFieldsInit before use
 */
const fieldsMap = {
  'truefalse': dtTrueFalseField,
  'picker': dtPickerField
}

/**
 * Initializes and adds custom field types to the DataTables Editor
 * @param {array} fields array of field names that reference field definitions as keys in @see fieldsMap
 */
function dtFieldsInit(fields = []) {
  const DataTable = $.fn.dataTable;

  if ( !DataTable.ext.editorFields )
    DataTable.ext.editorFields = {}

  for (const fieldName of fields) {
    DataTable.ext.editorFields[fieldName] = fieldsMap[fieldName]();
  }
}

/**
 * Custom Editable Field for True/False value selection
 * @return {Object} object containing defined field methods for create, set, and get
 */
function dtTrueFalseField() {
  let iconTrue = '.icon-sel-filled',
      iconFalse = '.icon-times-circle',
      icon = 'span.clickable',
      iconSelected = 'span.selected';

  return {
    create(conf) {
      conf._enabled = true;

      // Render the true / false icons
      conf._input = $(
        `<div>` +
          icons.checkMarkIcon(true, 'text-light clickable in-line', true) +
          icons.checkMarkIcon(false, 'text-light clickable in-line', true) +
        `</div>`)

      // Set new value when icon gains focus
      $(icon, conf._input).on('focus', (e) => {
        if (conf._enabled) {
          let value = $(e.target).hasClass( iconTrue.replace('.','') )
          this.set( conf.name, value );
        }
      })

      // Change value on left / right key press, submit on enter press
      $(icon, conf._input).on('keydown', (e) => {
        switch (e.which) {
          case 37:
          case 39:
            $(e.currentTarget).siblings().get(0).focus()
            break;
          case 13:
            this.submit();
            break;
        }
      });

      // Gain focus when editor opens
      $(this).on('open', () => {
        if (conf._enabled)
          $(iconSelected, conf._input).get(0).focus();
      })

      return conf._input;
    },
    get(conf) {
      return $(iconSelected, conf._input).hasClass( iconTrue.replace('.','') )
    },
    set(conf, value) {
      // Clear styles from selected icon
      $(iconSelected, conf._input).removeClass('selected text-link text-accent-2');

      // Set styles based on value
      if (value === true || value === 'true')
        $(iconTrue, conf._input).addClass('selected text-link')
      else
        $(iconFalse, conf._input).addClass('selected text-accent-2')
    }
  }
};


/**
 * Custom Editable Field for an Items Picker selection
 * @return {Object} object containing defined field methods for create, set, and get
 */
function dtPickerField() {

  // Helpers

  function _mapSelectionToColumn(sel) {
    // Map the selection object from the Picker to a references data object for the table
    return sel.asObjectsArray()
              .map((d) => Object.assign({}, {
                reference: d,
                context: d.context,
                show_path: d.show_path
              }));
  }

  // Map the references data object from the table to a references selection array for the Picker
  function _mapColumnToSelection(data) {
    return data.map( (d) => Object.assign({}, d.reference, { context: d.context }));
  }

  return {
    create(conf) {
      conf._safeId = $.fn.dataTable.Editor.safeId( conf.id );

      // Render parent div for the item references
      conf._input = $(`<div id='${conf._safeId}'></div>`);

      // Editor Opened event
      $(this).on('open', () => {
        let currentField = this.field(this.displayed()[0])

        // Check field is correct and picker instantiated
        if ( currentField.s.opts.pickerName === conf.pickerName && this.pickers[conf.pickerName] ) {
          // Add the Picker's modal to the conf for reusability across rows
          if (!conf._modal)
            conf._modal = this.pickers[conf.pickerName].modal.detach();

          // Attach the Picker's modal to the current field HTML
          $(currentField.node()).closest('td').prepend(conf._modal);

          // Set the Picker's onSubmit to pass the selection to this field's set()
          this.pickers[conf.pickerName].onSubmit = (s) => {
            this.set(conf.name, _mapSelectionToColumn(s));
            this.submit();
          }

          // Close editor on Picker close
          this.pickers[conf.pickerName].onClose = () => this.close();

          this.pickers[conf.pickerName].show();
        }
      });

      return conf._input;
    },
    get(conf) {
      // Check Picker instance exists, return empty if not
      if ( !this.pickers[conf.pickerName] )
        return []

      let selection = this.pickers[conf.pickerName].selectionView.getSelection();
      return _mapSelectionToColumn(selection);
    },
    set(conf, data) {
      // Render references in HTML
      $(conf._input).html(termReferences(data, 'display'));

      // Check Picker instance exists
      if ( !this.pickers[conf.pickerName] )
        return;

      // Clear Picker
      this.pickers[conf.pickerName].reset();
      // Append initial selection
      this.pickers[conf.pickerName].selectionView.add(_mapColumnToSelection(data));
    }
  }
};


export {
  dtFieldsInit
}
