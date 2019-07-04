function getFill(gRef) {
	return d3.select(gRef).select('rect')[0][0].style.fill; // Syntax a bit evil, not sure why the [0][0]  
}

function selectedNodeTest(fill) {
	return (fill === "#4682b4" || fill === "rgb(66, 139, 202)");
}

function hiddenNodeTest(fill) {
	return (fill === "#87ceeb" || fill === "skyblue");
}

function enabledNodeTest(fill) {
	return (fill === "white" || fill === "rgb(217, 83, 79)");
}

function disabledNodeTest(fill) {
	return (fill === "white" || fill === "rgb(217, 83, 79)");
}

function clickedNodeTest(fill) {
	return (fill === '#808080' || fill === "gray");
}

function undefinedNodeTest(fill) {
	return (fill === '#ffffff' || fill === "black");
}