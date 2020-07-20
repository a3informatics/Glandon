import IndexPanel from 'shared/iso_managed/index_panel'
import { dtIndicatorsColumn } from 'shared/helpers/dt/dt_columns'
import { $post } from 'shared/helpers/ajax'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "managed_concept",
    extraColumns: [ { data: "notation" }, dtIndicatorsColumn()]
  });

  // Create a new Code List
  $("#tnb_new_button").on('click', () => {
    $post({
      url: createCLUrl,
      done: (data) => location.href = data.history_path
    })
  });

});
