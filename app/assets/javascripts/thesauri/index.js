$(document).ready(function(){

  // Thesauri selected callback
  var callback = function(value) {
    var data = {thesauri: {}};
    data.thesauri[(value instanceof Array ? "id_set" : "filter")] = value;

    if (value instanceof Array && value.length == 1)
      location.href = searchUrl.replace("thId", value[0]);
    else
      location.href = searchMultiUrl + "?" + $.param(data);
  }

  var mis = new ManagedItemsSelect(callback);
});