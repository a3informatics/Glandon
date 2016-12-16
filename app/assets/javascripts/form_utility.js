function isBcGroup(d3Node) {
  var bc_ref;
  if (d3Node.type === C_NORMAL_GROUP) {
    if (d3Node.data.hasOwnProperty('bc_ref')) {
      bc_ref = d3Node.data.bc_ref;
      if (bc_ref.hasOwnProperty('subject_ref')) {
        return true;
      }
    }
  }
  return false;
}

function hasCommonGroup(d3Node) {
  if (hasChildren(node)) {
    child = d3Node.save[0];
    if (child.type === C_COMMON_GROUP) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }  
}

function isCommonGroup(d3Node) {
  return d3Node.type === C_COMMON_GROUP;
}

function isCommonItem(d3Node) {
  return d3Node.type === C_COMMON_ITEM;
}

function hasChildren(node) {
  var result = true;
  if (node.hasOwnProperty('save')) {
    if (currentNode.save.length === 0) {
      result = false;
    }
  } else {
    result = false;
  }
  return result;
}