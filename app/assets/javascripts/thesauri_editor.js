$(document).ready(function() {
  
  var sourceJson ;
  var d3Div = document.getElementById("d3");
  var html  = $("#jsonData").html();
  var conceptLabelElement = document.getElementById("conceptLabel");
  var conceptIdElement = document.getElementById("conceptId");
  var conceptNotationElement = document.getElementById("conceptNotation");
  var conceptDefinitionElement = document.getElementById("conceptDefinition");
  var conceptPreferredTermElement = document.getElementById("conceptPreferredTerm");
  var conceptSynonymElement = document.getElementById("conceptSynonym");

  var normal;
  var currentNode;
  var currentThis;
  var newIndex;
  var path = [];

  // Get the JSON structure. Set the namespace of the thesauri.
  sourceJson = $.parseJSON(html);
  initData();

  // Draw the initial tree;
  redraw();

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
      conceptLabelElement.value = node.label;
      conceptIdElement.value = node.identifier;
      conceptNotationElement.value = node.notation;
      conceptDefinitionElement.value = node.definition;
      conceptPreferredTermElement.value = node.preferredTerm;
      conceptSynonymElement.value = node.synonym; 
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
      redraw();
    } else if (node.expand) {
      node.children = [];
      node.children = node.expansion;
      redraw();
    } else if (node.hasOwnProperty('save')) {
      node.children = [];
      node.children = node.save;
      redraw();
    } else {
      $.ajax({
        url: "../../thesaurus_concepts/showD3",
        data: {
          "id": node.id,
          "namespace": namespace
        },
        dataType: 'json',
        success: function(result){
          saveGet(node,result);
          redraw();
        }
      });  
    }  

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
  
  /* 
  * Function to handle the add button click.
  */
  $('#addButton').click(function() {

    var index;
        
    if (currentNode == null) {
      alert ("Select a node.");
    } else if (currentNode.expand) {
      alert ("Cannot add to this node");
    } else {
      label = conceptLabelElement.value
      identifier = conceptIdElement.value
      notation = conceptNotationElement.value;
      definition = conceptDefinitionElement.value;
      preferredTerm= conceptPreferredTermElement.value;
      synonym = conceptSynonymElement.value;
      if (currentNode.hasOwnProperty('children')) {
        index = currentNode.children.length;
      } else {
        currentNode.children = [];
        currentNode.save = [];
        index = 0;
      }     
      newIndex += 1;
      currentNode.children[index] = {};
      currentNode.children[index].id = "NEW_" + newIndex;
      currentNode.children[index].add = true;
      currentNode.children[index].name = label + " [" + notation + "]";
      currentNode.children[index].label = label;
      currentNode.children[index].identifier = identifier;
      currentNode.children[index].definition = definition;
      currentNode.children[index].notation = notation;
      currentNode.children[index].preferredTerm = preferredTerm;
      currentNode.children[index].synonym = synonym;
      currentNode.children[index].parent = currentNode;
      currentNode.save = currentNode.children;
      save(currentNode.children[index]);
    }
  });

  /* 
  * Function to handle the delete button click.
  */
  $('#deleteButton').click(function() {
    var index;
    if (currentNode == null) {
      alert ("Select a node.");
    } else if (currentNode.expand) {
      alert ("Cannot delete this node");
    } else {
      // Send to the server
      $.ajax({
        url: "../../thesaurus_concepts/showD3",
        data: {
          "id": currentNode.id,
          "namespace": namespace
        },
        dataType: 'json',
        success: function(result){
          saveGet(currentNode,result);
          
          if (currentNode.children.length == 0) {
            parent = currentNode.parent
            if (parent != null) {
              currentNode.deletee = true;
              save(currentNode);
            } 
          } else {
            redraw();
            var html = alertWarning("The concept has children. Delete these first.");
            displayAlerts(html);
          }    
        }
      }); 
    }
  });
  
  /* 
  * Function to handle the update button click.
  */
  $('#updateButton').click(function() {
    if (currentNode == null) {
      alert ("Select a node.");
    } else if (currentNode.expand) {
      alert ("Cannot update this node");
    } else {
      label = conceptLabelElement.value
      identifier = conceptIdElement.value
      notation = conceptNotationElement.value;
      definition = conceptDefinitionElement.value;
      preferredTerm= conceptPreferredTermElement.value;
      synonym = conceptSynonymElement.value;
      currentNode.name = label + " [" + notation + "]";
      currentNode.label = label;
      currentNode.identifier = identifier;
      currentNode.definition = definition;
      currentNode.notation = notation;
      currentNode.preferredTerm = preferredTerm;
      currentNode.synonym = synonym;
      currentNode.update = true;
      save(currentNode);
    }
  });

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
 
  function setParent(node) {
    if (node.hasOwnProperty('children')) {
      for (i=0; i<node.children.length; i++) {
        child = node.children[i];
        child.parent = node;
        setParent(child);
      }
    }
  }

  function buildPath(node) {
    
    var parent;

    path.push(node.id);
    if (node.parent != null) {
      parent = node.parent
      buildPath(parent);
    } else {
      path.pop();
    }
  }

  function findChild(nodeId, treeNode) {

    var i;
    
    if (treeNode.hasOwnProperty('children')) {
      for (i=0; i<treeNode.children.length; i++) {
        if (treeNode.children[i].id == nodeId) {
          return treeNode.children[i];
        }
      }  
    }
    return null;
  }

  function expandPath(nodeId, treeNode) {
    
    var childNode;
    var newNodeId;

    childNode = treeNode;
    while (path.length > 0) {
      newNodeId = path.pop();         
      if (childNode != null) {
        childNode = findChild(nodeId, childNode);
        if (childNode != null) {
          dblClick(childNode);
        }
      }
    }      
 }
 
  function initData () {
    namespace = sourceJson.namespace;
    thesauriId = sourceJson.id;
    currentNode = null;
    currentThis = null;
    normal = true;
    newIndex = 0;
    //path = [];
  }

  function saveGet (node, result) {
    node.children = [];
    node.children = result.children;
    setParent(node);
    node.save = [];
    node.save = node.children;
  }

  function save (node) {

    var item;
    var saveData = {};

    // Set the initial data structures    
    saveData.deleteItem = {};
    saveData.updateItem = {};
    saveData.addItem = {};

    // Determine the action, set the data
    if (node.add) {
      saveData.addItem = {
        id: node.id, 
        parent: node.parent.id ,
        label: node.label , 
        identifier: node.identifier , 
        notation: node.notation, 
        definition: node.definition, 
        preferredTerm: node.preferredTerm, 
        synonym: node.synonym };
        buildPath(node);
    } else if (node.deletee) {
      saveData.deleteItem = {
        id: node.id,
        parent: node.parent.id };
        buildPath(node.parent);
    } else if (node.update) {
      saveData.updateItem = {
        id: node.id, 
        parent: node.parent.id ,
        label: node.label , 
        identifier: node.identifier , 
        notation: node.notation, 
        definition: node.definition, 
        preferredTerm: node.preferredTerm, 
        synonym: node.synonym };
        buildPath(node);
    } else {
        // Somethign here
    } 

    //buildPath(node);
    //alert("Data=" + JSON.stringify(saveData));

    // Send to the server
    $.ajax({
      url: "/thesauri/" + thesauriId,
      type: 'POST',
      data: { "_method": "put",
              "namespace": namespace,
              "data": saveData
            },
      success: function(result){
        var html = alertSuccess("The concept has been saved.");
        displayAlerts(html);
        var intJson = JSON.stringify(result);
        sourceJson = $.parseJSON(intJson);
        initData();
        expandPath(path.pop(), sourceJson, null);
        redraw();
      },
      error: function(xhr,status,error){
        var errors;
        var html;
        errors = $.parseJSON(xhr.responseText).errors;
        var html = ""
        for (var i=0; i<errors.length; i++) {
          html = html + alertError(errors[i]);
        }
        displayAlerts(html);
      }
    }); 

  }
  
});