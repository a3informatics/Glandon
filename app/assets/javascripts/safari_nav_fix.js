window.onpageshow = function(event) {
    if (event.persisted && isSafari() && $(".spinner-wrap").length) {
      $(".spinner-wrap").remove();
      clearTimeout(pdfLoadingTimeout);
    }
};
