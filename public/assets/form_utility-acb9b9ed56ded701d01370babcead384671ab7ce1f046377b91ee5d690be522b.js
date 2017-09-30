function isBcGroup(d3Node) {
  if (d3Node.type === C_NORMAL_GROUP) {
    if (d3Node.data.hasOwnProperty('bc_ref')) {
      if (d3Node.data.bc_ref.hasOwnProperty('subject_ref')) {
        return true;
      }
    }
  }
  return false;
}

function hasCommonGroup(d3Node) {
  if (hasChildren(d3Node)) {
    if (d3Node.save[0].type === C_COMMON_GROUP) {
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
    if (node.save.length === 0) {
      result = false;
    }
  } else {
    result = false;
  }
  return result;
}
;
