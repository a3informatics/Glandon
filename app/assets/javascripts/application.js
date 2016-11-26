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

// Managed Item Types
var C_FORM = "http://www.assero.co.uk/BusinessForm#Form";
var C_USERDOMAIN = "http://www.assero.co.uk/BusinessDomain#UserDomain";
var C_IGDOMAIN = "http://www.assero.co.uk/BusinessDomain#IgDomain";
var C_CLASSDOMAIN = "http://www.assero.co.uk/BusinessDomain#ClassDomain";
var C_MODEL = "http://www.assero.co.uk/BusinessDomain#Model";
var C_BC = "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance";
var C_BCT = "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptTemplate";
var C_TH = "http://www.assero.co.uk/ISO25964#Thesaurus";

var C_SI = "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier";
var C_RS = "http://www.assero.co.uk/ISO11179Registration#RegistrationState";

// References
var C_TC_REF = "http://www.assero.co.uk/BusinessOperational#TcReference";
var C_P_REF = "http://www.assero.co.uk/BusinessOperational#PReference";
var C_BC_REF = "http://www.assero.co.uk/BusinessOperational#BcReference";
var C_BCT_REF = "http://www.assero.co.uk/BusinessOperational#BctReference";
var C_T_REF = "http://www.assero.co.uk/BusinessOperational#TReference";
var C_C_REF = "http://www.assero.co.uk/BusinessOperational#CReference";

// Thesaurus Concept Types
var C_THC = "http://www.assero.co.uk/ISO25964#ThesaurusConcept";

// Form Types
var C_NORMAL_GROUP ="http://www.assero.co.uk/BusinessForm#NormalGroup";
var C_COMMON_GROUP = "http://www.assero.co.uk/BusinessForm#CommonGroup";
var C_PLACEHOLDER = "http://www.assero.co.uk/BusinessForm#Placeholder";
var C_TEXTLABEL = "http://www.assero.co.uk/BusinessForm#TextLabel";
var C_BC_QUESTION = "http://www.assero.co.uk/BusinessForm#BcProperty";
var C_QUESTION = "http://www.assero.co.uk/BusinessForm#Question";
var C_Q_CL = C_TC_REF;
var C_BC_CL = C_TC_REF;

// BC Types
var C_BC_DATATYPE ="http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype";
var C_BC_ITEM ="http://www.assero.co.uk/CDISCBiomedicalConcept#Item";
var C_BC_PROP ="http://www.assero.co.uk/CDISCBiomedicalConcept#Property";
var C_BC_PROP_VALUE ="http://www.assero.co.uk/CDISCBiomedicalConcept#PropertyValue";

// SDTM
var C_USERVARIABLE = "http://www.assero.co.uk/BusinessDomain#UserVariable";
var C_IGVARIABLE = "http://www.assero.co.uk/BusinessDomain#IgVariable";
var C_CLASSVARIABLE = "http://www.assero.co.uk/BusinessDomain#ClassVariable";
var C_MODELVARIABLE = "http://www.assero.co.uk/BusinessDomain#ModelVariable";
var C_SDTM_IG = "http://www.assero.co.uk/BusinessDomain#ImplementationGuide";
      
var C_SDTM_CLASSIFICATION = "http://www.assero.co.uk/BusinessDomain#VariableClassification"
var C_SDTM_TYPE = "http://www.assero.co.uk/BusinessDomain#VariableType"
var C_SDTM_COMPLIANCE = "http://www.assero.co.uk/BusinessDomain#VariableCompliance"

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

/**
* Error functions
*/
function highlight(element) {
  $(element).closest('.form-group').addClass('has-error');
}

function unhighlight(element) {
  $(element).closest('.form-group').removeClass('has-error');
}

function addErrorText(error, element) {
  error.insertAfter(element);
}

function removeErrorText(element) {
  element.next("span").remove();
}


/*
* Non Jquery validation
*/
function validateIdentifier(value) {
  var result = /^[A-Za-z0-9 ]+$/.test( value );
  return result
}

function identifierErrorText() {
  return "<span class=\"help-block\">Please enter a valid identifier. Upper and lower case alphanumeric and space characters only.</span>"
}
  
function validateLabel(value) {
  var result = /^[A-Za-z0-9 .!?,_\-\/\\()]*$/.test( value );
  return result
}
  
function labelErrorText() {
  return "<span class=\"help-block\">Please enter a valid label. Upper and lower case case alphanumerics, space and .!?,_-/\\() special characters only.</span>"
}
  
function validateQuestion (value) {
  var result = /^[A-Za-z0-9 .?,\-:;]+$/.test( value );
  return result
}

function questionErrorText() {
  return "<span class=\"help-block\">Please enter valid question text. Upper and lower case case alphanumerics, space and .?: special characters only.</span>"
}
 
function validateFormat(value) {
  var result = /^[0-9].[0-9]$/.test( value );
  return result
}

function formatErrorText() {
  return "<span class=\"help-block\">Please enter valid format N.N.</span>"
}

/*
* Validator plugin standard regex functions
*/
jQuery.validator.addMethod("identifier", function(value, element) {
  var result = /^[A-Za-z0-9 ]+$/.test( value ); 
  return result;
}, "Please enter a valid identifier. Upper and lower case alphanumeric and space characters only.");

jQuery.validator.addMethod("label", function(value, element) {
  var result = /^[A-Za-z0-9 .!?,_\-\/\\()]+$/.test( value );
  return result
}, "Please enter a valid label. Upper and lower case case alphanumerics, space and .!?,_-/\\() special characters only.");

jQuery.validator.addMethod("question", function(value, element) {
  var result = /^[A-Za-z0-9 .?,\-:;]+$/.test( value );
  return result
}, "Please enter a valid question text. Upper and lower case case alphanumerics, space and .?,-:; special characters only.");

jQuery.validator.addMethod("freeText", function(value, element) {
  var result = /^[A-Za-z0-9 .!?,_\-\/\\()\r\n]+$/.test( value );
  return result
}, "Please enter a valid free text. Upper and lower case case alphanumerics, space, .!?,_-/\\() special characters and return only.");

jQuery.validator.addMethod("markdown", function(value, element) {
  var result = /^[A-Za-z0-9 .!?,'"_\-\/\\()[\]~#*=:;&|\r\n]*$/.test( value );
  return result;
}, "Please enter valid markdown. Upper and lowercase alphanumeric, space, .!?,'\"_-/\\()[]~#*=:;&| special characters and return only.");

jQuery.validator.addMethod("variableName", function(value, element) {
  var result = /^[A-Z][A-Z0-9]{1,7}$/.test( value );
  return result;
}, "Please enter a valid variable name. Upper case alpha characters, 1 to 8 characters long.");

jQuery.validator.addMethod("variableLabel", function(value, element) {
  var result = /^[A-Za-z0-9 .!?,'"_\-()#*:;&]{1,40}$/.test( value );
  return result;
}, "Please enter a valid variable name. Upper and lower case alphanumeric, space, .!?,'\"_-()#*:;& special characters, 1 to 40 characters long.");

jQuery.validator.addMethod("domainPrefix", function(value, element) {
  var result = /^[A-Z]{2}$/.test( value );
  return result;
}, "Please enter a valid domain prefix. Upper case alpha characters, 2 characters long.");

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
  if (rdfType == C_FORM) {
    return "/forms/";    
  } else if (rdfType == C_BC) {
    return "/biomedical_concepts/";
  } else if (rdfType == C_USERDOMAIN) {
    return "/sdtm_user_domains/"
  } else if (rdfType == C_TH) {
    return "/thesauri/"
  } else {
    return ""
  }
}

/*
* Link to
*/
function linkTo(path, namespace, id) {
  window.location.href = path + "?id=" + id + "&namespace=" + namespace
}

/*
* Get All Thesaurus Concept References for entire JSON tree
*/
/*function allTcReference(node) {
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
}*/

