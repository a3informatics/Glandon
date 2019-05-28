/**
 * D3 Editor Object
*/

/**
 * Initialize the editor. Set the call back functions
 *
 * @param [Function] clickCallBackPre the function to be called pre click processing
 * @param [Function] clickCallBackPost the function to be called post click processing
 * @param [Function] dblClickCallBackPost the function to be called post click processing
 * @return [Null] 
 */
function D3Editor(d3DivId, clickCallBackPre, clickCallBackPost, dblClickCallBackPost, validateCallBack) {
  this.nextKeyId = 1;
  this.currentGRef = null;
  this.currentNode = null;
  this.rootNode = null;
  this.d3Div = document.getElementById(d3DivId);
  this.clickCallBackPre = clickCallBackPre;
  this.clickCallBackPost = clickCallBackPost;
  this.dblClickCallBackPost = dblClickCallBackPost;
  this.validateCallBack = validateCallBack;
}

/**
 * Clear current. To be used for testing only
 * 
 * @return [Null]
 */
D3Editor.prototype.clearCurrent = function () {
  this.currentGRef = null;
  this.currentNode = null;
}

/**
 * Determines if current node set
 * 
 * @return [Boolean] true if set, otherwise false
 */
D3Editor.prototype.currentSet = function () {
  if (this.currentGRef == null) {
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
D3Editor.prototype.getCurrent = function () {
  if (this.currentGRef == null) {
    return null;
  } else {
    return this.currentNode;
  }
}

/**
 * Function to handle click on the D3 tree. Show the node info. Highlight the node.
 * Perform the pre and post callbacks.
 *
 * @param  [Object] node the current node
 * @return [Null] 
 */
D3Editor.prototype.click = function (node) { 
  var valid = true;
  if (this.currentNode != null) {
    valid = this.validateCallBack(this.currentNode);
    if (valid) {
      this.clickCallBackPre(this.currentNode);
      d3RestoreNode(this.currentGRef);  
    }
  }
  if (valid) { 
    this.currentGRef = d3FindGRef(node.key);
    this.currentNode = node;
    d3MarkNode(this.currentGRef);
    this.clickCallBackPost(this.currentNode);
  }
}  

/**
 * Function to handle double click on the D3 tree. Expand or hide the children,
 * display the tree and make the callback.
 *
 * @param  [Object] node the current node
 * @return [Null] 
 */
D3Editor.prototype.dblClick = function (node) {
  this.expandHide(node);
  this.displayTree(node.key);
  this.dblClickCallBackPost(node);
} 

/**
 * Expands or hide a node's children
 * 
 * @param  [Object] node the node
 * @return [Null]
 */
D3Editor.prototype.expandHide = function (node) {
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
 * @param  [Object] node the node
 * @return [Null]
 */
D3Editor.prototype.forceHide = function (node) {
  node.expand = false;
  this.expandHide(node);
} 

/**
 * Force expand a node's children
 * 
 * @param  [Object] node the node
 * @return [Null]
 */
D3Editor.prototype.forceExpand = function (node) {
  node.expand = (node.save.length > 0) ? true : false;
  this.expandHide(node); 
} 


/**
 * Displays the tree
 * 
 * @param  [Integer] nodeKey the node key of the node to be displayed
 * @return [Null]
 */
D3Editor.prototype.displayTree = function (nodeKey) {
  d3TreeNormal(this.d3Div, this.rootNode, this.click.bind(this), this.dblClick.bind(this));
  var gRef = d3FindGRef(nodeKey);
  if (gRef !== null) {
    this.currentGRef = gRef;
    this.currentNode = gRef.__data__;
    d3MarkNode(this.currentGRef);
  }
}

/**
 * Redisplay tree
 * 
 * @return [Null]
 */
D3Editor.prototype.reDisplay = function () {
  if (this.currentNode != null) {
    this.displayTree(this.currentNode.key);
  }
}

/**
 * Resize Display of the tree
 * 
 * @return [void]
 */
D3Editor.prototype.reSizeDisplay = function (step) {
  var height = d3GetHeight();
  d3AdjustHeight(height + step);
  this.reDisplay();
}

/**
 * Deletes a node.
 * 
 * @param  [Object] node the node
 * @return [Null]
 */
D3Editor.prototype.deleteNode = function (node) {
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
  this.setParent(parentNode);
  this.setOrdinal(parentData);
  return parentNode;
}

D3Editor.prototype.deleteChildren = function (node) {
  delete node.children;
  delete node.data.children;
  delete node.save;
  node.children = [];
  node.data.children = [];
}

/**
 * Moves the node up. Prevents moving up past first position.
 * 
 * @param  [Object] node the node
 * @return [Null]
 */
D3Editor.prototype.moveNodeUp = function (node) {
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
    this.setOrdinal(parentData);
  }
}

/**
 * Moves the node down. Prevents moving down past last position.
 * 
 * @param  [Object] node the node
 * @return [Null]
 */
D3Editor.prototype.moveNodeDown = function (node) {
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
    this.setOrdinal(parentData);
  }
}

/**
 * Get the key of the last node created.
 * 
 * @return [Integer] the last used key
 */
D3Editor.prototype.lastKey = function () {
  return this.nextKeyId - 1;
}

/**
 * Tests if node has children
 *
 * @param  [Object] node the node
 * @return [Boolean] true if node has children, false otherwise.
 */
D3Editor.prototype.hasChildren = function (node) {
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
 * @param [Object] parentNode The parent node
 * @param [Object] data The data object associated with the node
 * @param [Object] addAtEnd At at end of existing nodes if true, at front if false
 */
D3Editor.prototype.addData = function (parentNode, data, addAtEnd) {
  if (!parentNode.data.hasOwnProperty('children')) {
    parentNode.data.children = [];
  }
  if (addAtEnd) {
    parentNode.data.children.push(data);
  } else {
    parentNode.data.children.unshift(data);
  }
  this.setOrdinal(parentNode.data);
}

/**
 * Add a node to the parent. Can be placed at the start or at the end.
 * Will also add th edata into the corresponding position in the 
 * parallel data tree.
 *
 * @param [Object] parent The parent node
 * @param [Object] name The node name
 * @param type [Object] The node type
 * @param enabled [Object] The node enabled flag
 * @param data [Object] The data object associated with the node
 * @param addAtEnd [Object] At at end of existing nodes if true, at front if false
 * @return [Object] The new node.
 */
D3Editor.prototype.addNode = function (parent, name, type, enabled, data, addAtEnd) {
  var node = this.emptyNode();
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
  node.key = this.nextKeyId;
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
  this.nextKeyId += 1;
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
D3Editor.prototype.root = function (name, type, data) {
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
  this.rootNode = node;
  this.nextKeyId = 2;
  return node;
}

/**
 * Creates an empty node.
 *
 * @return [Object] The new node.
 */
D3Editor.prototype.emptyNode = function () {
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
D3Editor.prototype.setParent = function (node) {
  var i;
  var child;
  if (node.hasOwnProperty('save')) {
    for (i=0; i<node.save.length; i++) {
      child = node.save[i];
      child.parent = node;
      child.index = i;
      this.setParent(child);
    }
  }
}

/**
 * Set the ordinals for the children for a node
 *
 * @param node [Object] the node
 * @return [Null]
 */
D3Editor.prototype.setOrdinal = function (node) {
  var child;
  if (node.hasOwnProperty('children')) {
    for (var i=0; i<node.children.length; i++) {
      node.children[i].ordinal = i+1;
    }
  }
}