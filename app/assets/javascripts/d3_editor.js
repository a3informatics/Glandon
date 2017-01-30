var d3eNextKeyId;
var d3eCurrentNode;
var d3eCurrentGRef;
var d3eRootNode;
var d3eClickCallBackPre;
var d3eClickCallBackPost;
var d3eDblClickCallBackPost;
var d3eValidateCallBack;
var d3eDiv;

/**
 * Initialize the editor. Set the call back functions
 *
 * @param clickCallBackPre [Function] the function to be called pre click processing
 * @param clickCallBackPost [Function] the function to be called post click processing
 * @param dblClickCallBackPost [Function] the function to be called post click processing
 * @return [Null] 
 */
function d3eInit(clickCallBackPre, clickCallBackPost, dblClickCallBackPost, validateCallBack) {
  d3eNextKeyId = 1;
  d3eCurrentGRef = null;
  d3eCurrentNode = null;
  d3eRootNode = null;
  d3eDiv = document.getElementById("d3");
  d3eClickCallBackPre = clickCallBackPre;
  d3eClickCallBackPost = clickCallBackPost;
  d3eDblClickCallBackPost = dblClickCallBackPost;
  d3eValidateCallBack = validateCallBack;
}

/**
 * Clear current. To be used for testing only
 * 
 * @return [Null]
 */
function d3eClearCurrent() {
  d3eCurrentGRef = null;
  d3eCurrentNode = null;
}

/**
 * Determines if current node set
 * 
 * @return [Boolean] true if set, otherwise false
 */
function d3eCurrentSet() {
  if (d3eCurrentGRef == null) {
    return false;
  } else {
    return true;
  }
}

/**
 * Get the current node
 * 
 * @return [Object] The current node
 */
function d3eGetCurrent() {
  if (d3eCurrentGRef == null) {
    return null;
  } else {
    return d3eCurrentNode;
  }
}

/**
 * Function to handle click on the D3 tree. Show the node info. Highlight the node.
 * Perform the pre and post callbacks.
 *
 * @param node [Object] the current node
 * @return [Null] 
 */
function d3eClick(node) {    
  var valid = true;
  if (d3eCurrentNode != null) {
    valid = d3eValidateCallBack(d3eCurrentNode);
    if (valid) {
      d3eClickCallBackPre(d3eCurrentNode);
      d3RestoreNode(d3eCurrentGRef);  
    }
  }
  if (valid) { 
    d3eCurrentGRef = this;
    d3eCurrentNode = node;
    d3MarkNode(this);
    d3eClickCallBackPost(d3eCurrentNode);
  }
}  

/**
 * Function to handle double click on the D3 tree. Expand or hide the children,
 * display the tree and make the callback.
 *
 * @param node [Object] the current node
 * @return [Null] 
 */
function d3eDblClick(node) {
  d3eExpandHide(node);
  d3eDisplayTree(node.key);
  d3eDblClickCallBackPost(node);
} 

/**
 * Expands or hide a node's children
 * 
 * @param node [Object] the node
 * @return [Null]
 */
function d3eExpandHide(node) {
  if (node.expand) {
    node.children = node.save;
    node.expand = false;
  } else if (node.hasOwnProperty('children')) {
    node.children = [];
    node.expand = (node.save.length > 0) ? true : false;
  }
} 

/**
 * Force hide a node's children
 * 
 * @param node [Object] the node
 * @return [Null]
 */
function d3eForceHide(node) {
  node.expand = false;
  d3eExpandHide(node);
} 

/**
 * Force expand a node's children
 * 
 * @param node [Object] the node
 * @return [Null]
 */
function d3eForceExpand(node) {
  node.expand = (node.save.length > 0) ? true : false;
  d3eExpandHide(node); 
} 


/**
 * Displays the tree
 * 
 * @param nodeKey [Integer] the node key of the node to be displayed
 * @return [Null]
 */
function d3eDisplayTree(nodeKey) {
  d3TreeNormal(d3eDiv, d3eRootNode, d3eClick, d3eDblClick);
  var gRef = d3FindGRef(nodeKey);
  if (gRef !== null) {
    d3eCurrentGRef = gRef;
    d3eCurrentNode = gRef.__data__;
    d3MarkNode(d3eCurrentGRef);
  }
}

/**
 * Redisplay tree
 * 
 * @return [Null]
 */
function d3eReDisplay() {
  if (d3eCurrentNode != null) {
    d3eDisplayTree(d3eCurrentNode .key);
  }
}

/**
 * Deletes a node.
 * 
 * @param node [Object] the node
 * @return [Null]
 */
function d3eDeleteNode(node) {
  var parentNode = node.parent
  var parentData = parentNode.data;
  //var sourceNode = node.data;
  var parentIndex = node.index
  parentNode.save.splice(parentIndex, 1);
  parentData.children.splice(parentIndex, 1);
  if (parentNode.save.length === 0) {
    delete parentNode.children;
    delete parentNode.save;
    parentData.children = [];
  }
  d3eSetParent(parentNode);
  d3eSetOrdinal(parentData);
  return parentNode;
}

/**
 * Moves the node up. Prevents moving up past first position.
 * 
 * @param node [Object] the node
 * @return [Null]
 */
function d3eMoveNodeUp(node) {
  var parentNode = node.parent
  var parentIndex = node.index
  var parentData = parentNode.data;
  //var sourceNode = node.data;
  if (parentIndex != 0 && parentNode.save.length > 1) {
    var tempNode1 = parentNode.save[parentIndex - 1];
    var tempNode2 = parentNode.save[parentIndex];
    parentNode.save[parentIndex - 1] = tempNode2;
    parentNode.save[parentIndex] = tempNode1;
    tempNode1.index = parentIndex;
    tempNode2.index = parentIndex - 1;
    tempNode1 = parentData.children[parentIndex - 1];
    tempNode2 = parentData.children[parentIndex];
    parentData.children[parentIndex - 1] = tempNode2;
    parentData.children[parentIndex] = tempNode1;
    tempNode1.index = parentIndex;
    tempNode2.index = parentIndex - 1;
    d3eSetOrdinal(parentData);
  }
}

/**
 * Moves the node down. Prevents moving down past last position.
 * 
 * @param node [Object] the node
 * @return [Null]
 */
function d3eMoveNodeDown(node) {
  var parentNode = node.parent
  var parentIndex = node.index
  var parentData = parentNode.data;
  //var sourceNode = node.data;
  if (parentIndex != (parentNode.save.length - 1) && parentNode.save.length > 1) {
    var tempNode1 = parentNode.save[parentIndex + 1];
    var tempNode2 = parentNode.save[parentIndex];
    parentNode.save[parentIndex + 1] = tempNode2;
    parentNode.save[parentIndex] = tempNode1;
    tempNode1.index = parentIndex;
    tempNode2.index = parentIndex + 1;
    tempNode1 = parentData.children[parentIndex + 1];
    tempNode2 = parentData.children[parentIndex];
    parentData.children[parentIndex + 1] = tempNode2;
    parentData.children[parentIndex] = tempNode1;
    tempNode1.index = parentIndex;
    tempNode2.index = parentIndex + 1;
    d3eSetOrdinal(parentData);
  }
}

/**
 * Get the key of the last node created.
 * 
 * @return [Integer] the last used key
 */
function d3eLastKey() {
  return d3eNextKeyId - 1;
}

/**
 * Tests if node has children
 *
 * @param node [Object] the node
 * @return [Boolean] true if node has children, false otherwise.
 */
function d3eHasChildren(node) {
  var result = true;
  if (node.hasOwnProperty('save')) {
    if (node.save.length === 0) {
      result = false;
    }
  } else {
    result = false;
  }
  return result;
}

/**
 *
 * @param parentNode [Object] The parent node
 * @param data [Object] The data object associated with the node
 * @param addAtEnd [Object] At at end of existing nodes if true, at front if false
 */
function d3eAddData(parentNode, data, addAtEnd) {
  if (!parentNode.data.hasOwnProperty('children')) {
    parentNode.data.children = [];
  }
  if (addAtEnd) {
    parentNode.data.children.push(data);
  } else {
    parentNode.data.children.unshift(data);
  }
  d3eSetOrdinal(parentNode.data);
}

/**
 * Add a node to the parent. Can be placed at the start or at the end.
 * Will also add th edata into the corresponding position in the 
 * parallel data tree.
 *
 * @param parent [Object] The parent node
 * @param name [Object] The node name
 * @param type [Object] The node type
 * @param enabled [Object] The node enabled flag
 * @param data [Object] The data object associated with the node
 * @param addAtEnd [Object] At at end of existing nodes if true, at front if false
 * @return [Object] The new node.
 */
function d3eAddNode(parent, name, type, enabled, data, addAtEnd) {
  var node = d3eEmptyNode();
  //node = {};
  node.name = name;
  node.type = type;
  node.enabled = enabled;
  //node.is_common = data.hasOwnProperty('is_common') ? data.is_common : parent.data.is_common;
  if (data.hasOwnProperty('is_common')) {
    node.is_common = data.is_common;
  } else if (parent.data.hasOwnProperty('is_common')) {
    node.is_common = parent.data.is_common;
  }
  node.key = d3eNextKeyId;
  node.parent = parent;
  node.data = data;
  node.expand = false;
  node.children = [];
  node.save = [];
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
      parent.save[i].index = i;
    }
  }
  parent.children = parent.save;
  d3eNextKeyId += 1;
  return node;
}

/**
 * Creates the root node.
 *
 * @param name [Object] The node name
 * @param type [Object] The node type
 * @param data [Object] The data object associated with the node
 * @return [Object] The new node.
 */
function d3eRoot(name, type, data) {
  var node = {};
  node.name = name;
  node.type = type;
  node.enabled = true;
  node.is_common = false;
  node.key = 1;
  node.parent = null;
  node.data = data;
  node.expand = false;
  node.index = 0;
  node.children = [];
  node.save = node.children;
  d3eRootNode = node;
  d3eNextKeyId = 2;
  return node;
}

/**
 * Creates an empty node.
 *
 * @return [Object] The new node.
 */
function d3eEmptyNode() {
  var node = {  
    name: "",
    type: "",
    enabled: true,
    is_common: false,
    index: 0,
    key: 0,
    parent: null,
    data: null,
    expand: false,
    index: 0,
    children: [],
    save: []
  };
  return node;
}

/**
 * Sets the parents for the entire tree from the node specified. Recursive
 *
 * @param node [Object] the node
 * @return [Null]
 */
function d3eSetParent(node) {
  var i;
  var child;
  if (node.hasOwnProperty('save')) {
    for (i=0; i<node.save.length; i++) {
      child = node.save[i];
      child.parent = node;
      child.index = i;
      d3eSetParent(child);
    }
  }
}

/**
 * Set the ordinals for the children for a node
 *
 * @param node [Object] the node
 * @return [Null]
 */
function d3eSetOrdinal(node) {
  var child;
  if (node.hasOwnProperty('children')) {
    for (var i=0; i<node.children.length; i++) {
      node.children[i].ordinal = i+1;
    }
  }
}