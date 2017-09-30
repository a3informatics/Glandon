function getFill(gRef) {
	return d3.select(gRef).select('circle')[0][0].style.fill; // Syntax a bit evil, not sure why the [0][0]  
}

function selectedNodeTest(fill) {
	return (fill === "#4682b4" || fill === "steelblue");
}

function hiddenNodeTest(fill) {
	return (fill === "#87ceeb" || fill === "skyblue");
}

function enabledNodeTest(fill) {
	return (fill === '#3cb371' || fill === "mediumseagreen");
}

function disabledNodeTest(fill) {
	return (fill === '#ff4500' || fill === "orangered");
}

function clickedNodeTest(fill) {
	return (fill === '#808080' || fill === "gray");
}

function undefinedNodeTest(fill) {
	return (fill === '#ffffff' || fill === "black");
}
;
