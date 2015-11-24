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
  selectForm();

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

    /*if (!node.expand) {
      conceptIdElement.innerHTML = node.identifier;
      conceptNotationElement.innerHTML = node.notation;
      conceptDefinitionElement.innerHTML = node.definition;
      conceptPreferredTermElement.innerHTML = node.preferredTerm;
      conceptSynonymElement.innerHTML = node.synonym; 
    }*/
    if (currentNode.nodeType == "form") {
      selectForm();
    } else if (currentNode.nodeType == "group") {
      selectGroup();
      displayGroup(currentNode);
    } else {
      selectItem();
      displayItem(currentNode)
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
      node.children = node.expansion;  
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

  function selectForm() {
    $("#fromTable").removeClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#itemTable").addClass('hidden');
  }

  function selectGroup() {
    $("#formTable").addClass('hidden');
    $("#groupTable").removeClass('hidden');
    $("#itemTable").addClass('hidden');
  }
  
  function selectItem() {
    $("#formTable").addClass('hidden');
    $("#groupTable").addClass('hidden');
    $("#itemTable").removeClass('hidden');
  }
  
  function displayGroup(node) {
    group = $.parseJSON(node.group)
    document.getElementById("gName").innerHTML = group.name;
    document.getElementById("gOpt").innerHTML = group.optional;
    document.getElementById("gNote").innerHTML = group.item;
    document.getElementById("gOrd").innerHTML = group.ordinal;
    document.getElementById("gRpt").innerHTML = group.repeat;
  }

  function displayItem(node) {
    var item = $.parseJSON(node.item);
    var bc = item.bc;
    var id = item.bcPropertyId
    var property = bc.properties[id];
    var values = property.Values;
    document.getElementById("iName").innerHTML = item.name;
    document.getElementById("iOpt").innerHTML = item.optional;
    document.getElementById("iNote").innerHTML = item.item;
    document.getElementById("iOrd").innerHTML = item.ordinal;
    //document.getElementById("iProp").innerHTML = property.qText;
    var text = ""
    for (i=0;i<values.length;i++) {
      var value = values[i];
      var cCode = value.cCode;
      var cli;
      for (key in value.clis) {
        if (value.clis.hasOwnProperty(key)) {
          cli = value.clis[key];
        }
      } 
      text = text + cli.notation + " (" + cCode + ")";
      if (i < (values.length - 1)) {
        text = text + ", "
      }
    }
    document.getElementById("iProp").innerHTML = text;
  }
  
});