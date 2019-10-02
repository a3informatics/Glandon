window.onpageshow = function(event) {
    if (event.persisted && $(".spinner-wrap").length) {
      $(".spinner-wrap").remove();
      if(pdfLoadingTimeout != null){
        clearTimeout(pdfLoadingTimeout);
        pdfLoadingTimeout = null;
      }
    }
};
