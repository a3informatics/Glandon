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
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require datatables.min
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require sidebar_handler
//= require spinner_helpers
//= require jquery-dateformat.min
//= require underscore-min
//= require shared/icons_tags_helpers
//= require shared/confirmation_dialog
//= require shared/information_dialog

// Managed Item Types
var C_FORM = "http://www.assero.co.uk/BusinessForm#Form";
var C_USERDOMAIN = "http://www.assero.co.uk/BusinessDomain#UserDomain";
var C_IGDOMAIN = "http://www.assero.co.uk/BusinessDomain#IgDomain";
var C_CLASSDOMAIN = "http://www.assero.co.uk/BusinessDomain#ClassDomain";
var C_MODEL = "http://www.assero.co.uk/BusinessDomain#Model";
var C_BC = "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance";
var C_BCT = "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptTemplate";
var C_TH = "http://www.assero.co.uk/ISO25964#Thesaurus";

var C_TH_NEW = "http://www.assero.co.uk/Thesaurus#Thesaurus";
var C_TH_CL = "http://www.assero.co.uk/Thesaurus#ManagedConcept";
var C_TH_SUBSET = "http://www.assero.co.uk/Thesaurus#ManagedConcept#Subset";
var C_TH_EXT = "http://www.assero.co.uk/Thesaurus#ManagedConcept#Extension";
var C_TH_CLI = "http://www.assero.co.uk/Thesaurus#UnmanagedConcept";

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
typeToString[C_TH_NEW] = "Terminology";
typeToString[C_TH_CL] = "Code List";
typeToString[C_TH_SUBSET] = "Subset";
typeToString[C_TH_EXT] = "Extension";
typeToString[C_TH_CLI] = "Code List Item";
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
    var alerts = document.getElementById("alerts");
  	alerts.innerHTML = html;
    window.setTimeout(function()
      {
          dismissAlerts();
      },
      5000);
}

function displayAlertsInElement(html, el) {
  	el.html(html);
    window.setTimeout(function(){ el.html(""); }, 5000);
}

function dismissAlerts(){
  var alerts = document.getElementById("alerts");
  alerts.innerHTML = "";
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

function handleAjaxError (xhr, status, error, target) {
  if (xhr.status == 401){
    location.reload(true);
    return;
  }

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
    if(target == null)
      displayAlerts(html);
    else
      displayAlertsInElement(html, target);
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

/*
* Utility functions
*/
function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
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
* Generic Print function
*/
$(document).ready(function() {
  $('#print_button').click(function() {
    window.print();
    return false;
  });
});

/*
* Positions the context menu corrently for any width display
*/
$(window).on('load',function(){
 $("table tbody").on("focus", ".icon-context-menu", function(){
   $(this).find(".context-menu").css("left", $(this).position().left);
 });
});

/*
* Prevent users from tabbing into a disabled button and pressing enter
*/
$(document).on("keydown", "a.disabled, button.disabled", function(e){
  if((e.keyCode || e.which) == 13)
    e.preventDefault();
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

// Returns true if browser is IE
function isIE() {
  ua = navigator.userAgent;
  /* MSIE used to detect old browsers and Trident used to newer ones*/
  var is_ie = ua.indexOf("MSIE ") > -1 || ua.indexOf("Trident/") > -1 || ua.indexOf("Edge") > -1;

  return is_ie;
}

// Returns initials of the passed string
function getStringInitials(str) {
  var initials = "";
  var words = str.split(' ');
  $.each(words, function(){
    initials += this.substring(0,1).toUpperCase();
  });
  return initials;
}

/**
 * Generates styled HTML for datetime
 * @param date [Date] Javascript date
 *
 * @return [String] formatted html
 */
function dateTimeHTML(date) {
  return '<span class="icon-date text-link"></span> ' +
          $.format.date(date, 'yyyy-MM-dd') +
          '<br/>' +
          '<span class="icon-time text-link"></span> ' +
          '<span class="text-small">' + $.format.date(date, 'HH:mm') + '</span>';
}

// Disable / enable any table controls for the user
function toggleTableActive(tableId, enable) {
  if(enable)
    $(tableId).removeClass("table-disabled");
  else
    $(tableId).addClass("table-disabled");
}

// Returns current date as e.g. Mon, January 1st, 2000
function currentDateString(){
  var date = new Date().getTime();
  return $.format.date(date, "ddd, MMMM D, yyyy")
}

// Returns a Date object set to dateString values (format must be YYYY-MM-DD)
function parseDateString(dateString){
  var parts = dateString.split('-');
  return new Date(parts[0], parts[1] - 1, parts[2]);
}

// Include on pages which should force reload when navigated to with the back button. Call before $(document).ready
function refreshOnBackPressed(){
  if (performance.navigation.type == 2)
    location.reload();
}
