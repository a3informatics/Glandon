var rootNode;
var mi;

$(document).ready(function() {
  initData();
  selectForm();
  displayForm(rootNode);
});

function initData () { 
  var html = $("#jsonData").html();
  var json = $.parseJSON(html);
  mi = json.managed_item;
  d3eInit(empty, displayNode, empty);
  rootNode = d3eRoot(mi.label, "", mi)
  if (mi.hasOwnProperty('children')) {
    for (i=0; i<mi.children.length; i++) {
      child = mi.children[i];
      setD3(child, rootNode);
    }
  }
  d3eDisplayTree(rootNode.key);
}

/*
* Set the D3 Structures
*
* @param sourceNode [Object] The data node
* @param d3ParentNode [Object] The parent D3 node
* @return [Null]
*/
function setD3(sourceNode, d3ParentNode) {
  var use;
  var newNode;
  var i;
  var child;
  newNode = d3eAddNode(d3ParentNode, sourceNode.label, sourceNode.type, true, sourceNode, true);
  getReference(newNode);
  if (sourceNode.hasOwnProperty('children')) {
    for (i=0; i<sourceNode.children.length; i++) {
      child = sourceNode.children[i];
      setD3(child, newNode);
    }
  }
}

/*
* Empty Callback Function
*
* @param node [Object] The D3 node
* @return [Null]
*/

function empty(node) {
}

/*
* Display The Current Node
*
* @return [Null]
*/
function displayNode() {
  if (currentNode.type == C_FORM) {
    selectForm();
    displayForm(currentNode);
  } else if (currentNode.type == C_NORMAL_GROUP) {
    selectGroup();
    displayGroup(currentNode);
  } else if (currentNode.type == C_BC_QUESTION) {
    selectBcItem();
    displayBcItem(currentNode);
  } else if (currentNode.type == C_QUESTION) {
    selectQuestion();
    displayQuestion(currentNode);
  } else if (currentNode.type == C_PLACEHOLDER) {
    selectPlaceholder();
    displayPlaceholder(currentNode);
  } else if (currentNode.type == C_TEXTLABEL) {
    selectLabelText();
    displayLabelText(currentNode);
  } else if (currentNode.type == C_TC_REF) {
    selectCl();
    displayCl(currentNode);
  } else if (currentNode.type == C_COMMON_GROUP) {
    selectCommon();
    displayCommon(currentNode);
  } else if (currentNode.type == C_COMMON_ITEM) {
    selectBcItem();
    displayBcItem(currentNode);
  }
}

/*
* Display Panels Functions.
*/
function selectNone() {
  $("#formTable").addClass('hidden');
  $("#groupTable").addClass('hidden');
  $("#commonTable").addClass('hidden');
  $("#bcTable").addClass('hidden');
  $("#bcItemTable").addClass('hidden');
  $("#questionTable").addClass('hidden');
  $("#placeholderTable").addClass('hidden');
  $("#labelTextTable").addClass('hidden');
  $("#clTable").addClass('hidden');
}

function selectForm() {
  selectNone();
  $("#formTable").removeClass('hidden');
  }

function selectGroup() {
  selectNone();
  $("#groupTable").removeClass('hidden');
}

function selectBcItem() {
  selectNone();
  $("#bcItemTable").removeClass('hidden');
}

function selectQuestion() {
  selectNone();
  $("#questionTable").removeClass('hidden');
}

function selectPlaceholder() {
  selectNone();
  $("#placeholderTable").removeClass('hidden');
}

function selectLabelText() {
  selectNone();
  $("#labelTextTable").removeClass('hidden');
}

function selectCl() {
  selectNone();
  $("#clTable").removeClass('hidden');
}

function selectCommon() {
  selectNone();
  $("#commonTable").removeClass('hidden');
}

/*
* Display Data in Panels Functions.
*/
function displayForm(node) {
  document.getElementById("formIdentifier").innerHTML = node.data.scoped_identifier.identifier;
  document.getElementById("formLabel").innerHTML = node.data.label;
  getMarkdown(document.getElementById("formCompletion"), node.data.completion, markdownCallback);
  getMarkdown(document.getElementById("formNote"), node.data.note, markdownCallback);
}

function displayGroup(node) {
  document.getElementById("groupLabel").innerHTML = node.data.label;
  document.getElementById("groupRepeating").innerHTML = node.data.repeating;
  document.getElementById("groupOptional").innerHTML = node.data.optional;
  getMarkdown(document.getElementById("groupCompletion"), node.data.completion, markdownCallback);
  getMarkdown(document.getElementById("groupNote"), node.data.note, markdownCallback);
}

function displayBcItem(node) {
  document.getElementById("bcItemLabel").innerHTML = node.data.label;
  document.getElementById("bcItemEnabled").innerHTML = node.data.property_ref.enabled;
  document.getElementById("bcItemOptional").innerHTML = node.data.property_ref.optional;
  document.getElementById("bcItemQText").innerHTML = node.data.property_ref.subject_data.question_text;
  document.getElementById("bcItemDatatype").innerHTML = node.data.property_ref.subject_data.datatype;
  document.getElementById("bcItemFormat").innerHTML = node.data.property_ref.subject_data.format;
  getMarkdown(document.getElementById("bcItemCompletion"), node.data.completion, markdownCallback);
  getMarkdown(document.getElementById("bcItemNote"), node.data.note, markdownCallback);
}

function displayQuestion(node) {
  document.getElementById("questionLabel").innerHTML = node.data.label;
  document.getElementById("questionOptional").innerHTML = node.data.optional;
  document.getElementById("questionQText").innerHTML = node.data.question_text;
  document.getElementById("questionMapping").innerHTML = node.data.mapping;
  document.getElementById("questionDatatype").innerHTML = node.data.datatype;
  document.getElementById("questionFormat").innerHTML = node.data.format;
  getMarkdown(document.getElementById("questionCompletion"), node.data.completion, markdownCallback);
  getMarkdown(document.getElementById("questionNote"), node.data.note, markdownCallback);
}

function displayPlaceholder(node) {
  document.getElementById("placeholderLabel").innerHTML = node.data.label;
  document.getElementById("placeholderOptional").innerHTML = node.data.optional;
  getMarkdown(document.getElementById("placeholderFreeText"), node.data.free_text, markdownCallback)
  getMarkdown(document.getElementById("placeholderCompletion"), node.data.completion, markdownCallback);
  getMarkdown(document.getElementById("placeholderNote"), node.data.note, markdownCallback);
}

function displayLabelText(node) {
  document.getElementById("labelTextLabel").innerHTML = node.data.label;
  document.getElementById("labelTextOptional").innerHTML = node.data.optional;
  getMarkdown(document.getElementById("labelTextLabelText"), node.data.label_text, markdownCallback)
  getMarkdown(document.getElementById("labelTextCompletion"), node.data.completion, markdownCallback);
  getMarkdown(document.getElementById("labelTextNote"), node.data.note, markdownCallback);
}

function displayCl(node) {
  document.getElementById("clIdentifier").innerHTML = node.data.subject_data.identifier;
  document.getElementById("clLabel").innerHTML = node.data.subject_data.label;
  document.getElementById("clDefaultLabel").innerHTML = node.data.local_label;
  document.getElementById("clSubmission").innerHTML = node.data.subject_data.notation;
  document.getElementById("clEnabled").innerHTML = node.data.enabled;
  document.getElementById("clOptional").innerHTML = node.data.optional;
}

function displayCommon(node) {
  document.getElementById("commonLabel").innerHTML = node.data.label;
}

function markdownCallback(element, text) {
  element.innerHTML = text;
}

/*
* Get Reference
*
* @param node [Object] The D3 node
* @return [Null]
*/
function getReference(d3Node) {
  if (d3Node.type == C_TC_REF) {
    getThesaurusConcept(d3Node, tcResult)
  } else if (d3Node.type == C_BC_QUESTION) {
    getBcProperty(d3Node, bcPropertyResult)
  } 
}

/*
* Thesaurus Ref AJAX Result Callback
*
* @param node [Object] The D3 node
* @param result [Object] Result received from server
* @return [Null]
*/
function tcResult(d3Node, result) {
  d3Node.data.subject_data = result;
  d3Node.name = result.label;
  d3eDisplayTree(1);
}

/*
* BC Property Ref AJAX Result Callback
*
* @param node [Object] The D3 node
* @param result [Object] Result received from server
* @return [Null]
*/
function bcPropertyResult(d3Node, result) {
  d3Node.data.property_ref.subject_data = result;
  d3eDisplayTree(1);
}