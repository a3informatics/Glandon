import IndexPanel from 'shared/iso_managed/index_panel'
import { $post } from 'shared/helpers/ajax'

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "managed_concept",
  });

  // Create a new Code List
  $("#tnb_new_button").on('click', () => {
    $post({
      url: createCLUrl,
      done: (data) => location.href = data.history_path
    })
  });

});
