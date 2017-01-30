$(document).ready(function() {
  
  initData();
  
  // Set window resize.
  window.addEventListener("resize", d3eReDisplay);

});

function initData () { 
  var html = $("#jsonData").html();
  var json = $.parseJSON(html);
  d3eInit(empty, displayNode, empty, emptyValidation);
  rootNode = d3eRoot(json.label, "", json)
  for (i=0; i<json.children.length; i++) {
    child = json.children[i];
    setD3(child, rootNode);
  }
  d3eDisplayTree(rootNode.key);
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

function emptyValidation(node) {
  return true;
}

function displayNode(node) {
  if (node.type ===  C_SYSTEM) {
    // Do nothing
  } else if (node.type === C_TAG) {
    imlRefresh(node.data.id, node.data.namespace)
  } 
}
