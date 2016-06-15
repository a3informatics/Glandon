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
  var managedItem = null;
  var nextKeyId;
  var rootNode;

  // Get the JSON structure. 
  sourceJson = $.parseJSON(html);
  managedItem = sourceJson.managed_item;
  
  // Create root node
  rootNode = d3Root(managedItem);
  nextKeyId = rootNode.key + 1;
  for (i=0; i<rootNode.children.length; i++) {
    child = rootNode.children[i];
    d3Node(child, rootNode);
  }

  // Draw the initial tree;
  displayTree(1);
  selectForm();
    
  // D3 functions
  function d3Root(node) {
    node.key = 1
    node.save = node.children;
    node.enabled = true;
    node.name = node.label;
    return node;
  }  

  function d3Node(node, parent) {
    var i;
    var child;

    node.key = nextKeyId;
    node.enabled = true;
    node.save = node.children;
    node.parent = parent;
    node.name = node.label;
    if (node.hasOwnProperty('children')) {
      for (i=0; i<node.children.length; i++) {
        child = node.children[i];
        d3Node(child, node);
      }
    } 
  }

  /**
   * Function to handle click on the D3 tree.
   * Show the node info. Highlight the node.
   */
  function click(node) {
    if (currentNode != null) {
      clearNode(currentNode, currentThis);
    }
    markNode1(this);
    currentNode = node;
    currentThis = this;
    displayNode();
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
    displayTree(node.key);
    displayNode();
  } 

  /**
   *  Function to draw the tree
   */
  function displayTree(nodeKey) {
    treeNormal(d3Div, rootNode, click, dblClick);
    var gRef = findNode(nodeKey);
    currentThis = gRef;
    currentNode = gRef.__data__;
    markNode1(currentThis);
    displayForm(currentNode);
  }

  /*
  * Info functions
  */
  function displayNode() {
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
    } else if (currentNode.type == C_PLACEHOLDER) {
      selectPlaceholder();
      displayPlaceholder(currentNode);
    } else if (currentNode.type == C_CL) {
      selectCl();
      displayCl(currentNode);
    } else if (currentNode.type == C_COMMON_GROUP) {
      selectCommon();
      displayCommon(currentNode);
    }
  }

  function selectNone() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#commonTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#placeholderTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }

  function selectForm() {
    $("#formTable").removeClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#commonTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#placeholderTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }

  function selectGroup() {
    $("#formTable").addClass('hidden');
    $("#groupTable").removeClass('hidden');
    $("#commonTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#placeholderTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function selectBc() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#commonTable").addClass('hidden');
    $("#bcTable").removeClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#placeholderTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function selectBcItem() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#commonTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").removeClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#placeholderTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function selectQuestion() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#commonTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").removeClass('hidden');
    $("#placeholderTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function selectPlaceholder() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#commonTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#placeholderTable").removeClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function selectCl() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#commonTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#placeholderTable").addClass('hidden');
    $("#clTable").removeClass('hidden');
  }

  function selectCommon() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#commonTable").removeClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#bcItemTable").addClass('hidden');
    $("#questionTable").addClass('hidden');
    $("#placeholderTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function displayForm(node) {
    document.getElementById("formIdentifier").innerHTML = node.identifier;
    document.getElementById("formLabel").innerHTML = node.label;
    getMarkdown(document.getElementById("formCompletion"), node.formCompletion);
    getMarkdown(document.getElementById("formNote"), node.formNote);
  }

  function displayGroup(node) {
    document.getElementById("groupLabel").innerHTML = node.label;
    document.getElementById("groupRepeating").innerHTML = node.repeating;
    document.getElementById("groupOptional").innerHTML = node.optional;
    getMarkdown(document.getElementById("groupCompletion"), node.completion);
    getMarkdown(document.getElementById("groupNote"), node.note);
  }

  function displayBc(node) {
    document.getElementById("bcLabel").innerHTML = node.name;
    document.getElementById("bcRepeating").innerHTML = node.repeating;
    document.getElementById("bcOptional").innerHTML = node.optional;
    getMarkdown(document.getElementById("bcCompletion"), node.completion);
    getMarkdown(document.getElementById("bcNote"), node.note);
  }

  function displayBcItem(node) {
    document.getElementById("bcItemLabel").innerHTML = node.name;
    document.getElementById("bcItemEnabled").innerHTML = node.property_reference.reference.enabled;
    document.getElementById("bcItemOptional").innerHTML = node.property_reference.reference.optional;
    document.getElementById("bcItemQText").innerHTML = node.qText;
    document.getElementById("bcItemDatatype").innerHTML = node.datatype;
    document.getElementById("bcItemFormat").innerHTML = node.format;
    getMarkdown(document.getElementById("bcItemCompletion"), node.completion);
    getMarkdown(document.getElementById("bcItemNote"), node.note);
  }

  function displayQuestion(node) {
    document.getElementById("questionLabel").innerHTML = node.name;
    document.getElementById("questionOptional").innerHTML = node.optional;
    document.getElementById("questionQText").innerHTML = node.qText;
    document.getElementById("questionMapping").innerHTML = node.mapping;
    document.getElementById("questionDatatype").innerHTML = node.datatype;
    document.getElementById("questionFormat").innerHTML = node.format;
    getMarkdown(document.getElementById("questionCompletion"), node.completion);
    getMarkdown(document.getElementById("questionNote"), node.note);
  }

  function displayPlaceholder(node) {
    document.getElementById("placeholderLabel").innerHTML = node.name;
    document.getElementById("placeholderOptional").innerHTML = node.optional;
    //document.getElementById("placeholderFreeText").innerHTML = node.free_text;
    getMarkdown(document.getElementById("placeholderFreeText"), node.free_text)
    getMarkdown(document.getElementById("placeholderCompletion"), node.completion);
    getMarkdown(document.getElementById("placeholderNote"), node.note);
  }

  function displayCl(node) {
    document.getElementById("clIdentifier").innerHTML = node.identifier;
    document.getElementById("clPreferredTerm").innerHTML = node.preferred_term;
    document.getElementById("clSubmission").innerHTML = node.notation;
    document.getElementById("clEnabled").innerHTML = node.reference.enabled;
    document.getElementById("clOptional").innerHTML = node.reference.optional;
  }

  function displayCommon(node) {
    document.getElementById("commonLabel").innerHTML = node.label;
    //getMarkdown(document.getElementById("commonCompletion"), node.completion);
    //getMarkdown(document.getElementById("commonNote"), node.note);
  }
  
});