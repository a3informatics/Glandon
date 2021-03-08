import IndexPanel from 'shared/custom/iso_managed/index_panel'
import CreateItemView from 'shared/base/create_item_view'
import { expandColumn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "managed_collection",
  })

  // Expand column width to fit contents better
  expandColumn("Identifier", "#index")

  let newMCView = new CreateItemView({
    selector: '#new-mc-modal',
    createItemUrl: createMCUrl,
    param: 'managed_collection'
  })

});
