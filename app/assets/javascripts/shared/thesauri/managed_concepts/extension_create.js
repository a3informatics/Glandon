function ExtensionCreate(isExtended, isExtending) {
  this.isExtended = isExtended;
  this.isExtending = isExtending;

  this.initUI();
}

ExtensionCreate.prototype.initUI = function() {
  if (this.isExtending) {
       $("#extend").hide();
       $("#extension").hide();
       $("#extending").show();
   } else if (this.isExtended) {
       $("#extend").hide();
       $("#extending").hide();
   } else {
        $("#extend").show();
       $("#extension").hide();
       $("#extending").hide();
   }
}

ExtensionCreate.prototype.createExtensionCallback = function(data) {
  if(data == null)
    this.createExtension();
  else
    this.createExtensionThesaurus(data);
}

ExtensionCreate.prototype.createExtension = function() {
  $.ajax({
    url: createExtensionUrl,
    type: "POST",
    dataType: 'json',
    contentType: 'application/json',
    error: function (xhr, status, error) {
      displayError("An error has occurred.");
    },
    success: function(result) {
      $("#extension").attr("href", result.edit_path);
      $('#extend').addClass('disabled').attr("disabled","disabled");
      $("#extension").show();
      location.href = result.edit_path;
    }
  });
}

ExtensionCreate.prototype.createExtensionThesaurus = function(data) {
  $.ajax({
    url: createExtensionInThUrl,
    type: "POST",
    data: JSON.stringify({thesauri: data}),
    dataType: 'json',
    contentType: 'application/json',
    error: function (xhr, status, error) {
      displayError("An error has occurred.");
    },
    success: function(result) {
      $("#extension").attr("href", result.edit_path);
      $('#extend').addClass('disabled').attr("disabled","disabled");
      $("#extension").show();
      location.href = result.edit_path;
    }
  });
}
