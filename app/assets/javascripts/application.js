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
//= require dataTables.buttons
//= require buttons.bootstrap
//= require dataTables.select
//= require dataTables.keyTable.min
//= require dataTables.editor.min
//= require dataTables.rowReorder.min
//= require editor.bootstrap.min
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require app-js-erb-extension

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
var C_MAPPING = "http://www.assero.co.uk/BusinessForm#Mapping";
var C_COMMON_ITEM = "http://www.assero.co.uk/BusinessForm#CommonItem";
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

// Concept system
var C_SYSTEM = "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem";
var C_TAG = "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode";

var typeToString = {};
typeToString[C_FORM] = "Form";
typeToString[C_USERDOMAIN] = "Custom Domain";
typeToString[C_IGDOMAIN] = "SDTM IG Domain";
typeToString[C_CLASSDOMAIN] = "SDTM Class Domain";
typeToString[C_MODEL] = "SDTM Model";
typeToString[C_BC] = "Biomedical Concept";
typeToString[C_BCT] = "Biomedical Concept Template";
typeToString[C_TH] = "Terminology";
typeToString[C_SI] = "Scoped Identifier";
typeToString[C_RS] = "Registration State";
typeToString[C_TC_REF] = "Terminology Reference";
typeToString[C_P_REF] = "Property Reference";
typeToString[C_BC_REF] = "Biomedical Concept Reference";
typeToString[C_BCT_REF] = "Biomedical Concept Template Reference";
typeToString[C_T_REF] = "Tabulation Reference";
typeToString[C_C_REF] = "Class Reference";
typeToString[C_THC] = "Code List Item";
typeToString[C_NORMAL_GROUP] = "Normal Group";
typeToString[C_COMMON_GROUP] = "Common Group";
typeToString[C_PLACEHOLDER] = "Placeholder";
typeToString[C_TEXTLABEL] = "Text Label";
typeToString[C_BC_QUESTION] = "Biomedical Concept Property";
typeToString[C_QUESTION] = "Question";
typeToString[C_MAPPING] = "Mapping";
typeToString[C_COMMON_ITEM] = "Common Item";
typeToString[C_Q_CL] = "Terminology Reference";
typeToString[C_BC_CL] = "Terminology Reference";
typeToString[C_BC_DATATYPE] = "Datatype";
typeToString[C_BC_ITEM] = "Item";
typeToString[C_BC_PROP] = "Property";
typeToString[C_BC_PROP_VALUE] = "Property Value";
typeToString[C_USERVARIABLE] = "Custom Variable";
typeToString[C_IGVARIABLE] = "SDTM IG Variable";
typeToString[C_CLASSVARIABLE] = "SDTM Class Variable";
typeToString[C_MODELVARIABLE] = "SDTM Model Variable";
typeToString[C_SDTM_IG] = "SDTM Implementation Guide";
typeToString[C_SDTM_CLASSIFICATION] = "SDTM Variable Classification";
typeToString[C_SDTM_TYPE] = "SDTM Variable Type";
typeToString[C_SDTM_COMPLIANCE] = "SDTM Variable Compliance";
typeToString[C_SYSTEM] = "Concept System";
typeToString[C_TAG] = "Concept System Tag";

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

function displayWarning(text) {
  var html = alertWarning(text);
  displayAlerts(html);
}

function displayError(text) {
  var html = alertError(text);
  displayAlerts(html);
}

function displaySuccess(text) {
  var html = alertSuccess(text);
  displayAlerts(html);
}

function handleAjaxError (xhr, status, error) {
    var json;
    var errors;
    var html;
    try {
      // Populate errorText with the comment errors
      json = $.parseJSON(xhr.responseText);
      if (json.hasOwnProperty('errors')) {
      	errors = json['errors'];
      } else if (json.hasOwnProperty('error')) {
	      errors[0] = json['error'];
      } else {
	      errors[0] = "Error communicating with the server.";
      }
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
* URI functions
*/
function getNamespace(uri) {
  if (uri === null) {
    return "";
  } else if (uri === "") {
    return "";
  } else {
    var parts = uri.split("#");
    if (parts.length === 2) {
      return parts[0];
    } else {
      return "";
    }
  }
}

function getId(uri) {
  if (uri === null) {
    return "";
  } else if (uri === "") {
    return "";
  } else {
    var parts = uri.split("#");
    if (parts.length == 2) {
      return parts[1];
    } else {
      return "";
    }
  }
}

function toUri(namespace, id) {
  return namespace + "#" + id;
}

/**
* Replaces the model instance id in a path with the actual id.
*/
function pathInsertId(path, id) {
  return path.replace(":id", id);
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
  } else if (rdfType == C_BCT) {
    return "/biomedical_concept_templates/";
  } else if (rdfType == C_USERDOMAIN) {
    return "/sdtm_user_domains/"
  } else if (rdfType == C_TH) {
    return "/thesauri/"
  } else {
    return ""
  }
}

/*
* Improved Path function for Strong parameters
*/
function getPathStrong(rdfType, id, namespace) {
  if (rdfType == C_FORM) {
    return "/forms/" + id + '?namespace=' + namespace;
  } else if (rdfType == C_BC) {
    return "/biomedical_concepts/" + id + '?biomedical_concept[namespace]=' + namespace;
  } else if (rdfType == C_BCT) {
    return "/biomedical_concept_templates/" + id + '?biomedical_concept_template[namespace]=' + namespace;
  } else if (rdfType == C_USERDOMAIN) {
    return "/sdtm_user_domains/" + id + '?sdtm_user_domain[namespace]=' + namespace;
  } else if (rdfType == C_TH) {
    return "/thesauri/" + id + '?namespace=' + namespace;
  } else {
    return ""
  }
}

/*
* Improved Path function for Strong parameters
*/
function getPathStrongV2(rdfType, id, namespace) {
  if (rdfType == C_FORM) {
    return "/forms/" + id;
  } else if (rdfType == C_BC) {
    return "/biomedical_concepts/" + id;
  } else if (rdfType == C_BCT) {
    return "/biomedical_concept_templates/" + id;
  } else if (rdfType == C_USERDOMAIN) {
    return "/sdtm_user_domains/" + id;
  } else if (rdfType == C_TH) {
    return "/thesauri/" + id;
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
* Expands / collapses the sidebar
* Handles main_area's responsiveness
*/
function sidebarHandler(arrow){
  $(arrow).toggleClass('arrow-rotate');
  $('#sidebar').toggleClass('sidebar-collapsed');

  // Animate main_area width
  $('#main_area').toggleClass('col-sm-10');
  $('#main_area').toggleClass('col-sm-11');
  $('#sidebar').toggleClass('col-sm-2');
  $('#sidebar').toggleClass('col-sm-1');

  $('#main_area').toggleClass('ma-sb-col');
  $('#main_area').toggleClass('ma-sb-exp');
}

/*
* Expands / collapses a menu category
*/
function sidebarCategoryHandler(item){
  if ($('#sidebar').hasClass('sidebar-collapsed'))
    $('#sidebar').removeClass('sidebar-collapsed');

  $(item).find('.arrow').toggleClass('arrow-rotate');
  $(item).parent().toggleClass('collapsed');
}

function sidebarVerticalScreenHandler(arrow){
  $(arrow).toggleClass('arrow-rotate');
  $("#sidebar").toggleClass('collapsed-vertical');
}

/*
* Generic Print function
*/
$(document).ready(function() {
  $('#print_button').click(function() {
    window.print();
    return false;
  });
});

/*
* Datatables generic processing function
* See: https://datatables.net/plug-ins/api/processing()
*/
jQuery.fn.dataTable.Api.register( 'processing()', function ( show ) {
  return this.iterator( 'table', function ( ctx ) {
    ctx.oApi._fnProcessingDisplay( ctx, show );
  });
});

/*
* Toggles a string in an element with another without disturbing any other html
* @param el [Object] jquery object - target
* @param oTxt [String] original text
* @param rTxt [String] replacement text
*/
function toggleText(el, oTxt, rTxt){
  el.html(~el.html().indexOf(oTxt) ? el.html().replace(oTxt, rTxt) :  el.html().replace(rTxt, oTxt));
}


function isIE() {
  ua = navigator.userAgent;
  /* MSIE used to detect old browsers and Trident used to newer ones*/
  var is_ie = ua.indexOf("MSIE ") > -1 || ua.indexOf("Trident/") > -1 || ua.indexOf("Edge") > -1;

  return is_ie;
}

function isSafari(){
  return /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
}
