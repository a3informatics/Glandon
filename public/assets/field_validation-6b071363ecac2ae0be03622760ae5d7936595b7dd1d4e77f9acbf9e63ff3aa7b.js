C_FV_START = "^["
C_FV_END_EMPTY = "]*$"
C_FV_END_1_OR_MORE = "]+$"
C_FV_ALPHA_NUMERICS = "a-zA-Z0-9"
C_FV_ALPHA_NUMERICS_SPACE = C_FV_ALPHA_NUMERICS + " "
C_FV_FREE_TEXT = C_FV_ALPHA_NUMERICS + " .!?,'\"_\\-\\/\\\\()\\[\\]~#*+@=:;&|<>"
C_FV_TC_IDENTIFIER = C_FV_START + C_FV_ALPHA_NUMERICS + C_FV_END_1_OR_MORE
C_FV_IDENTIFIER = C_FV_START + C_FV_ALPHA_NUMERICS_SPACE + C_FV_END_1_OR_MORE
C_FV_MARKDOWN = C_FV_START + C_FV_FREE_TEXT + "\r\n" + C_FV_END_EMPTY
C_FV_LONG_NAME = C_FV_START + C_FV_FREE_TEXT + C_FV_END_1_OR_MORE
C_FV_TERM_PROPERTY = C_FV_START + C_FV_FREE_TEXT + C_FV_END_EMPTY
C_FV_QUESTION = C_FV_START + C_FV_FREE_TEXT + C_FV_END_EMPTY
C_FV_MAPPING = C_FV_START + C_FV_FREE_TEXT + C_FV_END_EMPTY
C_FV_LABEL = C_FV_START + C_FV_FREE_TEXT + C_FV_END_1_OR_MORE
C_FV_SDTM_LABEL = C_FV_START + C_FV_FREE_TEXT + "]{1,40}$"

C_FV_MESSAGE = ".!?,'\"_-/\\()[]~#*+@=:;&|<>";

var fvTcIdentifierRegEx = new RegExp(C_FV_TC_IDENTIFIER)
var fvIdentifierRegEx = new RegExp(C_FV_IDENTIFIER)
var fvMarkdownRegEx = new RegExp(C_FV_MARKDOWN)
var fvLongNameRegEx = new RegExp(C_FV_LONG_NAME)
var fvTermPropertyRegEx = new RegExp(C_FV_TERM_PROPERTY)
var fvQuestionRegEx = new RegExp(C_FV_QUESTION)
var fvLabelRegEx = new RegExp(C_FV_LABEL)
var fvSdtmVarNameRegEx = new RegExp(/^[A-Z][A-Z0-9]{1,7}$/)
var fvSdtmVarLabelRegEx = new RegExp(C_FV_SDTM_LABEL)
var fvDomainPrefixRegEx = new RegExp(/^[A-Z]{2}$/)
var fvFormatRegEx = new RegExp(/^\d+(\.\d+)?$/)
var fvSdtmMappingRegEx = new RegExp(C_FV_MAPPING)

/*
* Validator plugin standard regex functions
*/
jQuery.validator.addMethod("identifier", function(value, element) {
  return fvIdentifierRegEx.test(value);
}, "Please enter a valid identifier. Upper and lower case alphanumeric and space characters only.");

jQuery.validator.addMethod("tcIdentifier", function(value, element) {
  return fvTcIdentifierRegEx.test(value);
}, "Please enter a valid identifier. Upper and lower case alphanumeric characters only.");

jQuery.validator.addMethod("label", function(value, element) {
  return fvLabelRegEx.test(value);
}, "Please enter a valid label. Upper and lower case case alphanumerics, space and " + C_FV_MESSAGE + " special characters only.");

jQuery.validator.addMethod("question", function(value, element) {
  return fvQuestionRegEx.test(value);
}, "Please enter valid question text. Upper and lower case case alphanumerics, space and " + C_FV_MESSAGE + " special characters only.");

jQuery.validator.addMethod("markdown", function(value, element) {
  return fvMarkdownRegEx.test(value);
}, "Please enter valid markdown. Upper and lowercase alphanumeric, space, " + C_FV_MESSAGE + " special characters and return only.");

jQuery.validator.addMethod("variableName", function(value, element) {
  return fvSdtmVarNameRegEx.test(value);
}, "Please enter a valid variable name. Upper case alpha characters, 1 to 8 characters long.");

jQuery.validator.addMethod("variableLabel", function(value, element) {
  return fvSdtmVarLabelRegEx.test(value);
}, "Please enter a valid variable name. Upper and lower case alphanumeric, space, .!?,'\"_-()#*:;& special characters, 1 to 40 characters long.");

jQuery.validator.addMethod("domainPrefix", function(value, element) {
  return fvDomainPrefixRegEx.test(value);
}, "Please enter a valid domain prefix. Upper case alpha characters, 2 characters long.");

jQuery.validator.addMethod("format", function(value, element) {
  return fvFormatRegEx.test(value);
}, "Please enter a valid format. Digits with optional decimal point.");

jQuery.validator.addMethod("mapping", function(value, element) {
  return fvSdtmMappingRegEx.test(value);
}, "Please enter valid question text. Upper and lower case case alphanumerics, space and " + C_FV_MESSAGE + " special characters only.");

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
;
