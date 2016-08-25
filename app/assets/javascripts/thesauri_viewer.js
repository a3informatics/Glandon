$(document).ready(function() {
  
  var sourceJson;
  var managedItem;
  var d3Div = document.getElementById("d3");
  var html  = $("#jsonData").html();
  var normal = true;
  var currentNode = null;
  var currentThis = null;
  var nextKeyId;
  var rootNode;

  var conceptLabelElement = document.getElementById("conceptLabel");
  var conceptIdElement = document.getElementById("conceptId");
  var conceptNotationElement = document.getElementById("conceptNotation");
  var conceptDefinitionElement = document.getElementById("conceptDefinition");
  var conceptPreferredTermElement = document.getElementById("conceptPreferredTerm");
  var conceptSynonymElement = document.getElementById("conceptSynonym");
  
  // Get the JSON structure. Set the namespace of the thesauri.
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
  displayTree(rootNode.key);

  /**
   *  Function to handle click on the toggle button. 
   */
  $('#toggleButton').click(function() {
    if (normal) {
      normal = false;
    } else {
      normal = true;
    }
    displayTree();
  });

  /**
   * Function to handle click on the D3 tree.
   * Show the node info. Highlight the node.
   */
  function click(node) {
    if (currentNode != null) {
      d3ClearNode(currentNode, currentThis);
    }
    d3MarkNode(this);
    currentNode = node;
    currentThis = this;
    if (!node.expand) {
      conceptLabelElement.innerHTML = node.label;
      conceptIdElement.innerHTML = node.identifier;
      conceptNotationElement.innerHTML = node.notation;
      conceptDefinitionElement.innerHTML = node.definition;
      conceptPreferredTermElement.innerHTML = node.preferredTerm;
      conceptSynonymElement.innerHTML = node.synonym; 
    }
  }  

  /**
   * Function to handle double click on the D3 tree.
   * Expand/delete the node clicked.
   */
  function dblClick(node) {
    if (!node.children_checked) {
      $.ajax({
        url: "/thesaurus_concepts/" + node.id,
        data: {
          "id": node.id,
          "namespace": node.namespace
        },
        dataType: 'json',
        success: function(result){
          node.children = result.children;
          node.save = result.children;
          node.children_checked = true;
          for (i=0; i<node.children.length; i++) {
            var child = node.children[i];
            d3Node(child, node);
          }
          displayTree(node.key);
        }
      });  
    } else {
      if (node.hasOwnProperty('children')) {
        node.children = [];
      } else {
        node.children = node.save;  
      }  
      displayTree(node.key);
    }
  }

  /**
   *  Function to draw the tree
   */
  function displayTree(nodeKey) {
    var height = 400 * (rootNode.children.length / 15);
    d3AdjustHeight(height);
    if (normal) {
      d3TreeNormal(d3Div, rootNode, click, dblClick);
    } else {
      d3TreeCircular(d3Div, rootNode, click, dblClick);
    }
    var gRef = d3FindNode(nodeKey);
    currentThis = gRef;
    currentNode = gRef.__data__;
    d3MarkNode(currentThis);
  }

  // D3 functions
  // ============

  /**
   *  Function to setup the root
   */
  function d3Root(node) {
    node.key = 1
    node.save = node.children;
    node.enabled = true;
    node.name = node.label;
    node.children_checked = true;
    return node;
  }  

  /**
   *  Function to setup the children (recursive).
   */
  function d3Node(node, parent) {
    var i;
    var child;
    node.key = nextKeyId;
    node.enabled = true;
    node.save = node.children;
    node.parent = parent;
    node.name = node.label;
    node.children_checked = false;
    nextKeyId += 1;
    if (node.hasOwnProperty('children')) {
      for (i=0; i<node.children.length; i++) {
        var child = node.children[i];
        d3Node(child, node);
      } 
    } 
  }
  
});