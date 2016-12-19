var nextKeyId;
var currentNode;
var currentGRef;
var rootNode;
var clickCallBackPreFunction;
var clickCallBackPostFunction;
var d3Div;

function d3eInit(clickCallBackPre, clickCallBackPost) {
  nextKeyId = 1;
  currentGRef = null;
  currentNode = null;
  rootNode = null;
  d3Div = document.getElementById("d3");
  clickCallBackPreFunction = clickCallBackPre
  clickCallBackPostFunction = clickCallBackPost
}

function d3eCurrentSet() {
  if (currentGRef == null) {
    return false;
  } else {
    return true;
  }
}

function d3eGetCurrent() {
  if (currentGRef == null) {
    return null;
  } else {
    return currentNode;
  }
}

/**
 * Function to handle click on the D3 tree.
 * Show the node info. Highlight the node.
 */
function d3eClick(node) {    
  if (currentNode != null) {
    clickCallBackPreFunction(currentNode);
    d3ClearNode(currentNode, currentGRef);  
  }
  currentGRef = this;
  currentNode = node;
  d3MarkNode(this);
  clickCallBackPostFunction(currentNode);
}  

/**
 * Function to handle double click on the D3 tree.
 * Expand/delete the node clicked.
 */
function d3eDblClick(node) {
  if (node.expand) {
    node.children = node.save;
    node.expand = false;
    d3eDisplayTree(node.key);
  } else if (node.hasOwnProperty('children')) {
    node.children = [];
    node.expand = true;
    d3eDisplayTree(node.key); 
  }
} 

function d3eAddSourceNode(parent, node, end) {
  if (end) {
    parent.children.push(node);
  } else {
    parent.children.unshift(node);
  }
  //node.ordinal = parent.children.length;
  for (i=0; i<parent.children.length; i++) {
    temp = parent.children[i];
    temp.ordinal = i + 1;
  }
}

/**
 *  Function to draw the tree
 */
function d3eDisplayTree(nodeKey) {
  d3TreeNormal(d3Div, rootNode, d3eClick, d3eDblClick);
  var gRef = d3FindGRef(nodeKey);
  currentGRef = gRef;
  currentNode = gRef.__data__;
  d3MarkNode(currentGRef);    
}

function d3eAddNode(parent, name, type, enabled, data, addAtEnd) {
  var node = {};
  var temp;
  node.name = name;
  node.type = type;
  node.enabled = enabled;
  node.key = nextKeyId;
  node.parent = parent;
  node.data = data;
  node.expand = false;
  node.children = [];
  node.save = node.children;
  if (!parent.hasOwnProperty('save')) {
    parent.save = [];
    parent.children = [];
  }
  if (addAtEnd) {
    node.index = parent.save.length;
    parent.save.push(node);
  } else {
    parent.save.unshift(node);
    for (i=0; i<parent.save.length; i++) {
      temp = parent.save[i];
      temp.index = i;
    }
  }
  parent.children = parent.save;
  nextKeyId += 1;
  return node;
}

function d3eRoot(name, type, data) {
  var node = {};
  node.name = name;
  node.type = type;
  node.key = 1;
  node.parent = null;
  node.data = data;
  node.expand = false;
  node.index = 0;
  node.children = [];
  node.save = node.children;
  rootNode = node;
  nextKeyId = 2;
  return node;
}

function d3eHasChildren(node) {
  var result = true;
  if (node.hasOwnProperty('save')) {
    if (currentNode.save.length == 0) {
      result = false;
    }
  } else {
    result = false;
  }
  return result;
}

function d3eDeleteNode(node) {
  var parentNode = node.parent
  var sourceParentNode = parentNode.data;
  var sourceNode = node.data;
  var parentIndex = node.index
  parentNode.save.splice(parentIndex, 1);
  sourceParentNode.children.splice(parentIndex, 1);
  if (parentNode.save.length == 0) {
    delete parentNode.children;
    delete parentNode.save;
    sourceParentNode.children = [];
  }
  setParent(parentNode);
  setOrdinal(sourceParentNode);
  return parentNode;
}

function d3eMoveNodeUp(node) {
  var parentNode = node.parent
  var parentIndex = node.index
  var sourceParentNode = parentNode.data;
  var sourceNode = node.data;
  if (parentIndex != 0 && parentNode.save.length > 1) {
    var tempNode1 = parentNode.save[parentIndex - 1];
    var tempNode2 = parentNode.save[parentIndex];
    parentNode.save[parentIndex - 1] = tempNode2;
    parentNode.save[parentIndex] = tempNode1;
    tempNode1.index = parentIndex;
    tempNode2.index = parentIndex - 1;
    tempNode1 = sourceParentNode.children[parentIndex - 1];
    tempNode2 = sourceParentNode.children[parentIndex];
    sourceParentNode.children[parentIndex - 1] = tempNode2;
    sourceParentNode.children[parentIndex] = tempNode1;
    tempNode1.index = parentIndex;
    tempNode2.index = parentIndex - 1;
    setOrdinal(sourceParentNode);
  }
}

function d3eMoveNodeDown(node) {
  var parentNode = node.parent
  var parentIndex = node.index
  var sourceParentNode = parentNode.data;
  var sourceNode = node.data;
  if (parentIndex != (parentNode.save.length - 1) && parentNode.save.length > 1) {
    var tempNode1 = parentNode.save[parentIndex + 1];
    var tempNode2 = parentNode.save[parentIndex];
    parentNode.save[parentIndex + 1] = tempNode2;
    parentNode.save[parentIndex] = tempNode1;
    tempNode1.index = parentIndex;
    tempNode2.index = parentIndex + 1;
    tempNode1 = sourceParentNode.children[parentIndex + 1];
    tempNode2 = sourceParentNode.children[parentIndex];
    sourceParentNode.children[parentIndex + 1] = tempNode2;
    sourceParentNode.children[parentIndex] = tempNode1;
    tempNode1.index = parentIndex;
    tempNode2.index = parentIndex + 1;
    setOrdinal(sourceParentNode);
  }
}

function setParent(node) {
  var i;
  var child;
  if (node.hasOwnProperty('save')) {
    for (i=0; i<node.save.length; i++) {
      child = node.save[i];
      child.parent = node;
      child.index = i;
      setParent(child);
    }
  }
}

function setOrdinal(node) {
  var i;
  var child;
  if (node.hasOwnProperty('children')) {
    for (i=0; i<node.children.length; i++) {
      child = node.children[i];
      child.ordinal = i+1;
    }
  }
}
