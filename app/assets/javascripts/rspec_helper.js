var C_NULL = -1;

function rhClickClose() {
  simulateClick($('#close')[0]);
}

function rhClickSave() {
  simulateClick($('#save')[0]);
}

function simulateClick(elem /* Must be the element */) {
  var evt = document.createEvent("MouseEvents");
  evt.initMouseEvent(
      "click", /* type */
      true, /* canBubble */
      true, /* cancelable */
      window, /* view */
      0, /* detail */
      0, /* screenX */
      0, /* screenY */
      0, /* clientX */
      0, /* clientY */
      false, /* ctrlKey */
      false, /* altKey */
      false, /* shiftKey */
      false, /* metaKey */
      0, /* button */
      null); /* relatedTarget */
  elem.dispatchEvent(evt);
}

function simulateDblClick(elem /* Must be the element */) {
  var evt = document.createEvent("MouseEvents");
  evt.initMouseEvent(
      "dblclick", /* type */
      true, /* canBubble */
      true, /* cancelable */
      window, /* view */
      0, /* detail */
      0, /* screenX */
      0, /* screenY */
      0, /* clientX */
      0, /* clientY */
      false, /* ctrlKey */
      false, /* altKey */
      false, /* shiftKey */
      false, /* metaKey */
      0, /* button */
      null); /* relatedTarget */
  elem.dispatchEvent(evt);
}

function rhGetCurrent() {
  var node = d3eGetCurrent();
  if (node !== null) {
    return node.key;
  }
  return C_NULL;
}

function rhGetOrdinal(key) {
  var node = d3FindData(parseInt(key));
  if (node !== null) {
    return node.data.ordinal;
  }
  return C_NULL;
}

function rhGetCommon(key) {
  var node = d3FindData(parseInt(key));
  if (node !== null) {
    if (node.data.is_common) {
      return "common"
    } else {
      return "not common"
    }
  }
  return "";
}

function rhGetViaName(text) {
  var gRef = d3FindGRefByName(text);
  if (gRef !== null) {
    var node = d3GetData(gRef);
    return node.key;
  }
  return C_NULL;
}

function rhGetViaPath(path) {
  var rootNode = d3FindData(1);
  if (path[0] === rootNode.name && path.length > 1) {
    return getNextInPath(rootNode, path, 1);
  } else if (path[0] === rootNode.name && path.length === 1) {
    return rootNode.key;
  }
  return C_NULL;
}

function getNextInPath(node, path, index) {
  if (node.hasOwnProperty('save')) {
    for (var i=0; i<node.save.length; i++) {
      if (node.save[i].name === path[index]) {
        if (index === (path.length - 1)) {
          return node.save[i].key;
        } else if (index <= (path.length - 1)) {
          return getNextInPath(node.save[i], path, index + 1);
        } else {
          return C_NULL;
        }
      }
    }
  }
  return C_NULL;
}

function rhClickNodeByName(nodeName) {
  var node = d3FindGRefByName(nodeName);
  if (node !== null) {
    simulateClick(node);
  }
}

function rhClickNodeByKey(nodeKey) {
  var node = d3FindGRef(nodeKey);
  if (node !== null) {
    simulateClick(node);
  }
}

function rhDblClickNodeByKey(nodeKey) {
  var node = d3FindGRef(nodeKey);
  if (node !== null) {
    simulateDblClick(node);
  }
}

function contextMenuElement(tableId, columnNr, matchText, targetBtnText){
  var rows = $("#"+tableId).find("tr");
  var element;

  $.each(rows, function(i, e){ // Take each row in table
    var targetColumn = $(e).children()[columnNr-1]; // Find correct column nr
    if($(targetColumn).html() == matchText){ // Find column that matches the text
      var contextMenuIcon = $(e).children().eq(-1).find(".icon-context-menu"); // Find context menu icon (last col)
      $.each($(contextMenuIcon).find("a"), function (i, e){ // Go through each menu option
        if($(e).html().indexOf(targetBtnText) != -1){ // Find matching targetBtnText
          element = e;
        }
      });
    }
  });

  return element;
}
