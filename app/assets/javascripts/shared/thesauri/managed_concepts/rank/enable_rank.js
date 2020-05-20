$(document).ready(function() {

  $("#enable-rank-button").on("click", enableRank);

  function enableRank() {
    var self = this;
    elementLoadingInline(self, true)

    $.ajax({
      url: enableRankPath,
      type: "POST",
      success: function(result) { location.reload() },
      error: function(x, s, e) {
        handleAjaxError(x, s, e);
        elementLoadingInline(self, false)
      }
    });
  }
})
