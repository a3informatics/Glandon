// The IDs of sidebar links included in the lockedItems array will be disabled for all users.
$(document).ready(function(){
  var lockedItems = [
    "main_nav_e",
    "main_nav_aig", "main_nav_sd", "main_nav_sig", "main_nav_sm", "main_nav_bct"
  ];

  $.each(lockedItems, function(i, e){
    $("#"+e).addClass("locked");
    $("#"+e).attr("href", "");
  });
});
