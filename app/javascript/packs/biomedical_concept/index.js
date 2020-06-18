import IndexPanel from "shared/iso_managed/index_panel";
import { thSearchUrlFromMIS } from "shared/helpers/urls";

$(document).ready( () => {

  let ip = new IndexPanel({
    url: indexDataUrl,
    param: "biomedical_concept",
  });

  let mis = new ManagedItemsSelect((s) => location.href = thSearchUrlFromMIS(s));
});
