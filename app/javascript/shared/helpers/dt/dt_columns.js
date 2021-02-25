import { historyBtn, showBtn } from 'shared/ui/buttons'
import { icons, iconTypes, renderIcon, iconsInline } from 'shared/ui/icons'
import { renderIndicators } from 'shared/ui/indicators'
import { renderTagsInline } from 'shared/ui/tags'
import { getRdfNameByType } from 'shared/helpers/rdf_types'
import { itemReferences } from 'shared/ui/collections'

/**
 * Returns column definition for the history column
 * @param {string} name name of the button (options: history, show)
 * @return {object} DataTables history column definition
 */
function dtButtonColumn(name) {
  return {
    orderable: false,
    className: 'text-right button-column',
    render: (data, type, r, m) => {
      switch (name) {
        case 'show':
          return showBtn(r.show_path);
          break;
        case 'history':
          return historyBtn(r.history_path);
          break;
      }
    }
  }
}

/**
 * Returns column definition for the last change date column
 * @return {object} DataTables last change date column definition
 */
function dtDateTimeColumn(name) {
  return {
    data: name,
    render(data, type, r, m) {
      const date = new Date( data );
      return type === "display" ? dateTimeHTML(date) : date.getTime()
    }
  }
}

/**
 * Returns column definition for item version / semantic version column
 * @return {object} DataTables item version column definition
 */
function dtVersionColumn() {
  return {
    render: (data, type, r, m) => type === "display" ? r.has_identifier.semantic_version : r.has_identifier.version
  }
}

/**
 * Returns column definition for the tags column
 * @param {object} opts Additional column options
 * @return {object} DataTables indicators column definition
 */
function dtTagsColumn(opts = {}) {
  return {
    data: 'tags',
    defaultContent: 'None',
    ...opts,
    render: (data, type, r, m) => type === 'display' ? renderTagsInline(data) : data
  }
}

/**
 * Returns column definition for the indicators column
 * @param {object} filter Filters to be applied to indicator data, optional
 * @return {object} DataTables indicators column definition
 */
function dtIndicatorsColumn(filter) {
  return {
    data: "indicators",
    // width: "90px",
    render: (data, type, r, m) => renderIndicators(data, type, filter)
  }
}

/**
 * Returns column definition for an extensible / not-extensible CL icon column
 * @return {object} DataTables extensible / not-extensible icon column definition
 */
function dtCLExtensibleColumn() {
  return {
    className: "text-center",
    data: 'extensible',
    render: (data, type, row, meta) => {

      if ( type === 'display' )
        return renderIcon({
          iconName: data ? 'extend' : 'extend-disabled',
          cssClasses: data ? 'text-secondary-clr' : 'text-accent-2'
        });
      else
        return data ? 'is-extensible' : 'not-extensible';

    }
  }
}

/**
 * Returns column definition for the context menu column
 * @param {function} renderer function, that will render the HTML for the context menu from row data
 * @return {object} DataTables context menu column definition
 */
function dtContextMenuColumn(renderer) {
  return {
    className: "text-right",
    render: (data, type, r, m) => type === "display" ? renderer(r, m.row) : ""
  }
}

/**
 * Returns column definition for a true/false icon column
 * @param {string} name data property name
 * @return {object} DataTables true/false icon column definition
 */
function dtBooleanColumn(name, opts = {}) {
  return {
    className: "text-center",
    data: name,
    ...opts,
    render: (data, type, r, m) => type === "display" ? icons.checkMarkIcon(data) : data
  }
}

/**
 * Returns column definition for a true/false editable column
 * @param {string} name data property name
 * @param {object} opts additional column opts
 * @return {object} DataTables true/false editable column definition
 */
function dtBooleanEditColumn(name, opts = {}) {
  return {
    className: "editable inline text-center",
    data: name,
    editField: (opts.editField || name),
    render: dtBooleanColumn().render,
    ...opts
  }
}

/**
 * Returns column definition for a generic inline editable column
 * @param {string} name data property name
 * @param {object} opts additional column opts
 * @return {object} DataTables inline editable column definition
 */
function dtInlineEditColumn(name, opts = {}) {
  return {
    className: "editable inline",
    data: name,
    editField: (opts.editField || name),
    ...opts
  }
}

/**
 * Returns column definition for an externally editable column
 * @param {string} name data property name
 * @param {object} opts additional column opts
 * @return {object} DataTables externally editable column definition
 */
function dtExternalEditColumn(name, opts = {}) {
  return {
    className: "editable external",
    data: name,
    editField: (opts.editField || name),
    ...opts
  }
}

/**
 * Returns column definition for a Picker-based editable column
 * @param {string} name data property name
 * @param {string} pickerName Unique name of the Picker instance assigned to Editable Panel Pickers def. object 
 * @param {boolean} newTab Specifies whether the references' links should open in a new tab [default=false] 
 * @param {object} opts additional column opts
 * @return {object} DataTables pickable editable column definition
 */
function dtPickerEditColumn(name, {
  pickerName,
  newTab = false,
  opts = {} 
} = {}) {

  return {
    className: `editable pickable ${ pickerName }`,
    data: name,
    editField: name,
    render: (data, type, r, m) => itemReferences(data, type, newTab),
    ...opts 
  }

}

/**
 * Returns column definition for an Item type column 
 * @param {object} opts Additional column options
 * @return {object} DataTables Item type column definition
 */
function dtItemTypeColumn(opts = {}) {
  return {
    data: 'rdf_type',
    ...opts,
    render: (data, type, r, m) => { 
        
      const itemType = getRdfNameByType( data );

      return type === 'display' ? 
        iconTypes.renderIcon(data, { owner: (r.owner || r.uri), ttip: true }) : 
        itemType

    }
  }
}

/**
 * Returns column definition for a select editable column
 * Requires the data attribute to be an object which contains 'label' and 'id' props
 * @param {string} name data property name
 * @param {string} valueProp Name of the data value property (what is edited) [default='id']
 * @param {string} labelProp Name of the data label property (what is displayed) [default='label']
 * @param {object} opts additional column opts
 * @return {object} DataTables inline editable column definition
 */
function dtSelectEditColumn(name, { 
  valueProp = 'id', 
  labelProp = 'label',
  opts = {} 
} = {}) {
  return { 
    className: "editable inline",
    data: `${ name }.${ valueProp }`,
    render: (data, type, row) => row[name][labelProp],
    editField: (opts.editField || name),
  }
}

/**
 * Renders a clickable Remove icon in a cell 
 * @param {string} text Text on the icon's tooltip, optional
 * @param {function} isDisabledFn Function that will determine whether remove button is disabled, optional
 * @return {object} DataTables row remove column definition
 */
function dtRowRemoveColumn({ 
  text = 'Remove', 
  isDisabledFn = () => {} 
} = {}) {

  return {
    className: 'fit',
    render: (data, type, r, m) => type === 'display' ?
        iconsInline.removeIcon({
          ttip: true,
          ttipText: text,
          disabled: isDisabledFn( r )
        }) : ''
  }
  
}

export {
  dtButtonColumn,
  dtIndicatorsColumn,
  dtTagsColumn,
  dtCLExtensibleColumn,
  dtDateTimeColumn,
  dtVersionColumn,
  dtContextMenuColumn,
  dtBooleanColumn,
  dtItemTypeColumn,
  // Editable columns
  dtBooleanEditColumn,
  dtInlineEditColumn,
  dtExternalEditColumn,
  dtPickerEditColumn,
  dtSelectEditColumn,
  dtRowRemoveColumn
}