$(document).ready(function() {
  
  var sourceJson ;
  var d3Div = document.getElementById("d3");
  var html  = $("#jsonData").html();
  var normal = true;
  var currentNode = null;
  var currentThis = null;
  var conceptIdElement = document.getElementById("conceptId");
  var conceptNotationElement = document.getElementById("conceptNotation");
  var conceptDefinitionElement = document.getElementById("conceptDefinition");
  var conceptPreferredTermElement = document.getElementById("conceptPreferredTerm");
  var conceptSynonymElement = document.getElementById("conceptSynonym");
  var namespace;

  // Get the JSON structure. Set the namespace of the thesauri.
  sourceJson = $.parseJSON(html);
  namespace = sourceJson.namespace;

  // Draw the initial tree;
  redraw();

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

    if (!node.expand) {
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
    
    var index;

    if (node.hasOwnProperty('children')) {
      node.children = [];
    } else {
      if (node.expand) {
        node.children = [];
        index = 0;
        node.children = node.expansion;
      } else {
        //alert ("AjaxReq")
        $.ajax({
          url: "../thesaurus_concepts/showD3",
          data: {
            "id": node.id,
            "namespace": namespace
          },
          dataType: 'json',
          success: function(result){
            node.children = [];
            node.children = result.children;
            redraw();
          }
        });  
      }  
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
  
});