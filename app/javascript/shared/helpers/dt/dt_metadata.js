import { $get } from 'shared/helpers/ajax'

/**
 * Get options for editable select field and add to Datatables Editor instance
 * @param {string} url Specifies url to fetch select options from
 * @param {DT Editor} editor Datatables Editor instance to add options to
 * @param {function} always Execute upon request completed
 */
function getEditorSelectOptions({
  url,
  editor,
  always = () => {}
}) {

  $get({
    url, 
    done: data => Object.entries( data ).forEach( selectField => {

        const [ name, options ] = selectField
        editor.field( name ).update( options );

    }),
    always: () => always()
  })

}

export {
  getEditorSelectOptions
}