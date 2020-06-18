/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import HistoryPanel from "shared/iso_managed/history_panel";
import IndexPanel from "shared/iso_managed/index_panel";
import { dtIndicatorsColumn } from "shared/helpers/dt_columns";

$(document).ready( () => {

  let hp = new HistoryPanel({
    url: historyDataUrl,
    param: "thesauri"
  });

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "managed_concept",
    extraColumns: [dtIndicatorsColumn()]
  });

});
