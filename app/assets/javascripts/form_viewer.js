$(document).ready(function() {
  
  var C_FORM = "Form";
  var C_GROUP ="Group";
  var C_COMMON_GROUP = "CommonGroup";
  var C_PLACEHOLDER = "Placeholder";
  var C_BC_GROUP = "BCGroup";
  var C_BC_ITEM = "BCItem";
  var C_QUESTION = "Question";
  var C_CL = "CL";

  var sourceJson ;
  var d3Div = document.getElementById("d3");
  var html  = $("#jsonData").html();
  var normal = true;
  var currentNode = null;
  var currentThis = null;
  var namespace;

  // Get the JSON structure. Set the namespace of the thesauri.
  sourceJson = $.parseJSON(html);
  namespace = sourceJson.namespace;

  // Draw the initial tree;
  redraw();
  selectNone();

  /**
   *  Function to handle click on the D3 tree.
   */
  $('#toggleButton').click(function() {
    if (normal) {
      normal = false;
    } else {
      normal = true;
    }
    redraw();
  });

  /**
   * Function to handle click on the D3 tree.
   * Show the node info. Highlight the node.
   */
  function click(node) {
    if (currentNode != null) {
      clearNode(currentNode, currentThis);
    }
    markNode(node, this);
    currentNode = node;
    currentThis = this;
    if (currentNode.type == C_FORM) {
      selectForm();
      displayForm(currentNode);
    } else if (currentNode.type == C_GROUP) {
      selectGroup();
      displayGroup(currentNode);
    } else if (currentNode.type == C_BC_GROUP) {
      selectBc();
      displayBc(currentNode);
    } else if (currentNode.type == C_BC_ITEM) {
      selectBcItem();
      displayBcItem(currentNode);
    } else if (currentNode.type == C_QUESTION) {
      selectQuestion();
      displayQuestion(currentNode);
    } else if (currentNode.type == C_CL) {
      selectCl();
      displayCl(currentNode);
    }
  }  

  /**
   * Function to handle double click on the D3 tree.
   * Expand/delete the node clicked.
   */
  function dblClick(node) {
    var index;
    if (node.hasOwnProperty('children')) {
      node.children = [];
    } else {
      node.children = node.save;  
    }  
    redraw();
  } 

  /**
   *  Function to draw the tree
   */
  function redraw () {
    if (normal) {
      treeNormal(d3Div, sourceJson, click, dblClick);
    } else {
      treeCircular(d3Div, sourceJson, click, dblClick);
    }
    currentNode = null;
    currentThis = null;
  }

  function selectNone() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }

  function selectForm() {
    $("#formTable").removeClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }

  function selectGroup() {
    $("#formTable").addClass('hidden');
    $("#groupTable").removeClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function selectBc() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#bcTable").removeClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function selectBcItem() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").removeClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function selectQuestion() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").removeClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function selectCl() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#clTable").removeClass('hidden');
  }
  
  function displayForm(node) {
    document.getElementById("formIdentifier").innerHTML = node.identifier;
    document.getElementById("formLabel").innerHTML = node.label;
  }

  function displayGroup(node) {
    document.getElementById("groupLabel").innerHTML = node.label;
  }

  function displayBc(node) {
    document.getElementById("bcLabel").innerHTML = node.name;
  }

  function displayBcItem(node) {
    document.getElementById("bcItemLabel").innerHTML = node.name;
    document.getElementById("bcItemQText").innerHTML = node.qText;
    document.getElementById("bcItemDatatype").innerHTML = node.datatype;
    document.getElementById("bcItemFormat").innerHTML = node.format;
  }

  function displayQuestion(node) {
    document.getElementById("questionLabel").innerHTML = node.name;
    document.getElementById("questionQText").innerHTML = node.qText;
    document.getElementById("questionMapping").innerHTML = node.mapping;
    document.getElementById("questionDatatype").innerHTML = node.datatype;
    document.getElementById("questionFormat").innerHTML = node.format;
  }

  function displayCl(node) {
    document.getElementById("clIdentifier").innerHTML = node.identifier;
    document.getElementById("clSubmission").innerHTML = node.name;
  }
  
});