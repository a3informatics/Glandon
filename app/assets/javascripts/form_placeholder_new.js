$(document).ready(function () {

  validatorDefaults ();
  $('#placeholder_form').validate({
    rules: {
        "form[identifier]": { required: true, identifier: true },
        "form[label]": { required: true, label: true },
        "form[freeText]": { required: true, freeText: true }
    }
  });

});