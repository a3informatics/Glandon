window.onpageshow = function(event) {
    if (event.persisted && isSafari()) {
        window.location.reload()
    }
};
