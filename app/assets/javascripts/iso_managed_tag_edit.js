$(document).ready(function() {
  
  initData();
  
});

function initData () { 
  var html = $("#jsonData").html();
  var json = $.parseJSON(html);
  d3eInit("d3", empty, displayNode, empty, emptyValidation);
  rootNode = d3eRoot(json.label, "", json);
  for (i=0; i<json.children.length; i++) {
    child = json.children[i];
    setD3(child, rootNode);
  }
  d3eDisplayTree(rootNode.key);
  var id = document.getElementById("id");
  var namespace = document.getElementById("namespace");
  imtlInit(id.value, namespace.value);
  imtlRefresh();
  displayAttributes(id.value, namespace.value, true);
  }

function setD3(sourceNode, d3ParentNode) {
  var newNode = d3eAddNode(d3ParentNode, sourceNode.label, sourceNode.type, true, sourceNode, true);
  if (sourceNode.hasOwnProperty('children')) {
    for (var i=0; i<sourceNode.children.length; i++) {
      var child = sourceNode.children[i];
      setD3(child, newNode);
    }
  }
}

function empty(node) {
}

function emptyValidation(node) {
  return true;
}

function displayNode(node) {
  if (node.type ==  C_SYSTEM) {
    //alert("System node");
  } else if (node.type == C_TAG) {
    imlRefresh(node.data.id, node.data.namespace)
  } 
}

