$(document).ready(function() {
  
  var C_SYSTEM = "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem";
  var C_TAG = "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode";
  var html;
  var json;
  var id = document.getElementById("id");
  var namespace = document.getElementById("namespace");
  
  // Init any data. Draw the tree
  initData();
  
  function initData () { 
    // Get the JSON structure.
    html = $("#jsonData").html();
    json = $.parseJSON(html);
    // Init D3 Editor
    d3eInit(empty, displayNode, empty);
    // Add D3 nodes and display
    rootNode = d3eRoot(json.label, "", json)
    for (i=0; i<json.children.length; i++) {
      child = json.children[i];
      setD3(child, rootNode);
    }
    d3eDisplayTree(1);
    imtlInit(id.value, namespace.value);
    imtlRefresh();
  }

  function setD3(sourceNode, d3ParentNode) {
    var newNode;
    var i;
    var child;
    newNode = d3eAddNode(d3ParentNode, sourceNode.label, sourceNode.type, true, sourceNode, true);
    if (sourceNode.hasOwnProperty('children')) {
      for (i=0; i<sourceNode.children.length; i++) {
        child = sourceNode.children[i];
        setD3(child, newNode);
      }
    }
  }

  function empty(node) {
  }

  function displayNode(node) {
    if (node.type ==  C_SYSTEM) {
      //alert("System node");
    } else if (node.type == C_TAG) {
      //imlRefresh(node.data.id, node.data.namespace)
    } 
  }

});