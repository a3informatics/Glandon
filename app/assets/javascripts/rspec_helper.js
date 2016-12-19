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

function getOrdinal(nodeName) {
  var gRef = d3FindGRefByName(nodeName);
  if (gRef !== null) {
    var node = d3GetData(gRef);
    return node.data.ordinal;
  }
  return -1;
}
