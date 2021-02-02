import ManagedItemsPanel from 'shared/custom/iso_managed/managed_items_panel'
import { csvExportBtn, excelExportBtn } from 'shared/helpers/dt/utils'

$(document).ready( () => {

  let mip = new ManagedItemsPanel({
    param: 'managed_collection',
    buttons: [ 
      csvExportBtn(), 
      excelExportBtn() 
    ]
  });

});
