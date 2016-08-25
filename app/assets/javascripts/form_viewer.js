$(document).ready(function() {
  
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
  
  // get the TC references. 
  getReferences(rootNode);
  //displayTree(1);

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
    } else if (currentNode.type == C_Q_CL) {
      selectCl();
      displayCl(currentNode);
    } else if (currentNode.type == C_BC_CL) {
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
    document.getElementById("formIdentifier").innerHTML = node.scoped_identifier.identifier;
    document.getElementById("formLabel").innerHTML = node.label;
    getMarkdown(document.getElementById("formCompletion"), node.completion);
    getMarkdown(document.getElementById("formNote"), node.note);
  }

  function displayGroup(node) {
    document.getElementById("groupLabel").innerHTML = node.label;
    document.getElementById("groupRepeating").innerHTML = node.repeating;
    document.getElementById("groupOptional").innerHTML = node.optional;
    getMarkdown(document.getElementById("groupCompletion"), node.completion);
    getMarkdown(document.getElementById("groupNote"), node.note);
  }

  function displayBcItem(node) {
    document.getElementById("bcItemLabel").innerHTML = node.name;
    document.getElementById("bcItemEnabled").innerHTML = node.enabled;
    document.getElementById("bcItemOptional").innerHTML = node.optional;
    document.getElementById("bcItemQText").innerHTML = node.subject_data.qText;
    document.getElementById("bcItemDatatype").innerHTML = node.subject_data.datatype;
    document.getElementById("bcItemFormat").innerHTML = node.subject_data.format;
    getMarkdown(document.getElementById("bcItemCompletion"), node.completion);
    getMarkdown(document.getElementById("bcItemNote"), node.note);
  }

  function displayQuestion(node) {
    document.getElementById("questionLabel").innerHTML = node.name;
    document.getElementById("questionOptional").innerHTML = node.optional;
    document.getElementById("questionQText").innerHTML = node.question_text;
    document.getElementById("questionMapping").innerHTML = node.mapping;
    document.getElementById("questionDatatype").innerHTML = node.datatype;
    document.getElementById("questionFormat").innerHTML = node.format;
    getMarkdown(document.getElementById("questionCompletion"), node.completion);
    getMarkdown(document.getElementById("questionNote"), node.note);
  }

  function displayPlaceholder(node) {
    document.getElementById("placeholderLabel").innerHTML = node.name;
    document.getElementById("placeholderOptional").innerHTML = node.optional;
    getMarkdown(document.getElementById("placeholderFreeText"), node.free_text)
    getMarkdown(document.getElementById("placeholderCompletion"), node.completion);
    getMarkdown(document.getElementById("placeholderNote"), node.note);
  }

  function displayCl(node) {
    document.getElementById("clIdentifier").innerHTML = node.subject_data.identifier;
    document.getElementById("clLabel").innerHTML = node.subject_data.label;
    document.getElementById("clDefaultLabel").innerHTML = node.local_label;
    document.getElementById("clSubmission").innerHTML = node.subject_data.notation;
    document.getElementById("clEnabled").innerHTML = node.enabled;
    document.getElementById("clOptional").innerHTML = node.optional;
  }

  function displayCommon(node) {
    document.getElementById("commonLabel").innerHTML = node.label;
  }

  // Fill out the TC references.
  function getReferences(node) {
    var i;
    var child;
    if (node.type == C_Q_CL || node.type == C_BC_CL) {
      $.ajax({
        url: "/thesaurus_concepts/" + node.subject_ref.id,
        type: "GET",
        data: { "namespace": node.subject_ref.namespace },
        dataType: 'json',
        error: function (xhr, status, error) {
          var html = alertError("An error has occurred loading a Terminology reference.");
          displayAlerts(html);
        },
        success: function(result){
          node.subject_data = result;
          node.name = result.label;
          displayTree(1);
        }
      });
    } else if (node.type == C_BC_QUESTION) {
      $.ajax({
        url: "/biomedical_concepts/properties/" + node.property_ref.subject_ref.id,
        type: "GET",
        data: { "namespace": node.property_ref.subject_ref.namespace },
        dataType: 'json',
        error: function (xhr, status, error) {
          var html = alertError("An error has occurred loading a Biomedical Concept reference.");
          displayAlerts(html);
        },
        success: function(result){
          node.subject_data = result;
          displayTree(1);
        }
      });
    }
    if (node.hasOwnProperty('children')) {
      for (i=0; i<node.children.length; i++) {
        child = node.children[i];
        getReferences(child);
      }
    } 
  }
  
});