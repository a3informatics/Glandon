// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require d3 
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require morris.min
//= require raphael
//= require jquery.validate
//= require jquery.validate.additional-methods

// Small attempt to collapse nav. Ignore for the moment
//$(document).ready(function() {
//  $('#page_nav_menu_hide').click(function() {
//    $('#page_nav_menu').hide();
//  });
//});

/*
* General Alert handling functions
*/
function alertError(text) {
    html = '<div class="alert alert-danger alert-dismissible" role="alert">' + 
            '<button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>' + 
            text + 
            '</div>'
    return html
}

function alertSuccess(text) {
    html = '<div class="alert alert-success alert-dismissible" role="alert">' + 
            '<button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>' + 
            text + 
            '</div>'
    return html
}

function alertWarning(text) {
    html = '<div class="alert alert-warning alert-dismissible" role="alert">' + 
            '<button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>' + 
            text + 
            '</div>'
    return html
}

function alertInfo(text) {
    html = '<div class="alert alert-info alert-dismissible" role="alert">' + 
            '<button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>' + 
            text + 
            '</div>'
    return html
}

function displayAlerts(html) {
    var alertsId = document.getElementById("alerts")
  	alertsId.innerHTML = html;
    window.setTimeout(function() 
      {
        alertsId.innerHTML = "";
      }, 
      5000);
}

function notImplementedYet() {
  var html = alertWarning("Function not implemented yet.");
  displayAlerts(html);
}

function handleAjaxError (xhr, status, error) {
    var json;
    var errors;
    var html;
    try {
      // Populate errorText with the comment errors
      json = $.parseJSON(xhr.responseText);
      errors = json['errors'];
    } catch(err) {
      // If the responseText is not valid JSON (like if a 500 exception was thrown), populate errors with a generic error message.
      errors = [];
      errors[0] = "Error communicating with the server.";
    }
    var html = ""
    for (var i=0; i<errors.length; i++) {
        html = html + alertError(errors[i]);
    }
    displayAlerts(html);
}

/*
* Validator plugin standard regex functions
*/
jQuery.validator.addMethod("identifier", function(value, element) {
  var result = /^[A-Za-z0-9 ]+$/.test( value ); 
  return result;
}, "Please enter a valid identifier. Upper case alphanumeric and space characters only.");

jQuery.validator.addMethod("label", function(value, element) {
  var result = /^[A-Za-z0-9 .!?,_\-\/\\()]+$/.test( value );
  return result
}, "Please enter a valid label. Upper and lower case case alphanumerics, space and .!?,_-/\\() special characters only.");

jQuery.validator.addMethod("question", function(value, element) {
  var result = /^[A-Za-z0-9 .?:]+$/.test( value );
  return result
}, "Please enter valid question text. Upper and lower case case alphanumerics, space and .?: special characters only.");

jQuery.validator.addMethod("freeText", function(value, element) {
  var result = /^[A-Za-z0-9 .!?,_\-\/\\()\r\n]+$/.test( value );
  return result
}, "Please enter valid free text. Upper and lower case case alphanumerics, space, .!?,_-/\\() special characters and return only.");

jQuery.validator.addMethod("markdown", function(value, element) {
  var result = /^[A-Za-z0-9 .!?,'"_\-\/\\()[\]~#*=:;&|\r\n]*$/.test( value );
  return result;
}, "Please enter valid markdown. Upper and lowercase alphanumeric, space, .!?,'\"_-/\\()[]~#*=:;&| special characters and return only.");

// Set validator plugin defaults.
// TODO: Think about the span bit, not sure it is needed.
function validatorDefaults () {
  jQuery.validator.setDefaults({
    highlight: function(element) {
      $(element).closest('.form-group').addClass('has-error');
    },
    unhighlight: function(element) {
      $(element).closest('.form-group').removeClass('has-error');
    },
    //ignore: [],
    errorElement: 'span',
    errorClass: 'help-block',
    errorPlacement: function(error, element) {
      if(element.parent('.input-group').length) {
          error.insertAfter(element.parent());
      } else {
          error.insertAfter(element);
      }
    }
  });
}

/*
* Get Markdown 
*/
function getMarkdown(element, text) {
  if (text != "") {
    $.ajax({
      url: "/markdown_engines",
      type: "POST",
      data: { "markdown_engine": { "markdown": text }},
      dataType: 'json',
      error: function (xhr, status, error) {
        var html = alertError("An error has occurred loading the markdown.");
        displayAlerts(html);
      },
      success: function(result){
        var html_text = $.parseJSON(JSON.stringify(result));
        element.innerHTML = html_text.result;
      }
    });
  } else {
    element.innerHTML = "";    
  }
}

/*
* URI functions
*/ 
function getNamespace(uri) {
  var parts = uri.split("#");
  if (parts.length == 2) {
    return parts[0];
  } else {
    return "";
  }
}

function getId(uri) {
  var parts = uri.split("#");
  if (parts.length == 2) {
    return parts[1];
  } else {
    return "";
  }
}

function toUri(namespace, id) {
  return namespace + "#" + id;
}

/*
* Utility functions
*/
function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

/*
* Path function
*/
function getPath(rdfType) {
  if (rdfType == "http://www.assero.co.uk/BusinessForm#Form") {
    return "/forms/view/";    
  } else if (rdfType == "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance") {
    return "/biomedical_concepts/";
  } else if (rdfType == "http://www.assero.co.uk/BusinessDomain#SdtmUserDomain") {
    return "/sdtm_user_domains/"
  } else {
    return ""
  }
}

/*
* Get All Thesaurus Concept References for entire JSON tree
*/
function allTcReference(node) {
  var i;
  var child;
  if (node.type == C_CL) {
    $.ajax({
      url: "/thesaurus_concepts/" + node.data.subject_ref.id,
      type: "GET",
      data: { "namespace": node.data.subject_ref.namespace },
      dataType: 'json',
      error: function (xhr, status, error) {
        var html = alertError("An error has occurred loading a terminology reference.");
        displayAlerts(html);
      },
      success: function(result){
        node.subject_data = result;
        node.name = result.label;
        displayTree(1);
      }
    });
  }
  if (node.hasOwnProperty('children')) {
    for (i=0; i<node.children.length; i++) {
      child = node.children[i];
      tcReference(child);
    }
  } 
}

