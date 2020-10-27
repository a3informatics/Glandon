import IndexPanel from 'shared/iso_managed/index_panel'
import CreateItemView from 'shared/base/create_item_view'
import { expandColumn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "form",
  });

  // Expand column width to fit contents better
  expandColumn("Identifier", "#index");

  let newFormView = new CreateItemView({
    selector: '#new-form-modal',
    createItemUrl: createFormUrl,
    param: 'form'
  })

});
