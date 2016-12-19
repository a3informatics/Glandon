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
  if (hasChildren(d3Node)) {
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

function notImplementedYet() {
  var html = alertWarning("Function not implemented yet.");
  displayAlerts(html);
}

/*
* Get Reference
*
* @param node [Object] The D3 node
* @return [Null]
*/
function getReference(d3Node) {
  if (d3Node.type == C_TC_REF) {
    getThesaurusConcept(d3Node, tcResult)
  } else if (d3Node.type == C_BC_QUESTION) {
    getBcProperty(d3Node, bcPropertyResult)
  } 
}

/*
* Thesaurus Ref AJAX Result Callback
*
* @param node [Object] The D3 node
* @param result [Object] Result received from server
* @return [Null]
*/
function tcResult(d3Node, result) {
  d3Node.data.subject_data = result;
  d3Node.name = result.label;
  d3eDisplayTree(1);
}

/*
* BC Property Ref AJAX Result Callback
*
* @param node [Object] The D3 node
* @param result [Object] Result received from server
* @return [Null]
*/
function bcPropertyResult(d3Node, result) {
  d3Node.data.property_ref.subject_data = result;
  d3eDisplayTree(1);
}


