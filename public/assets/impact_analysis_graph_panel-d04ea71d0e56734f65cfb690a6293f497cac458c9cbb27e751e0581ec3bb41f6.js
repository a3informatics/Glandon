/*
* Impact Panel
* 
* Requires:
* d3 [Div] the d3 div
*/

/**
 * Impact Graph Panel Constructor
 *
 * @param [Function] clickCallBack the callback function.
 * @return [void]
 */

function ImpactAnalysisGraphPanel(clickCallBack) {
  // Create empty graph
  this.graph = {};
  this.graph.nodes = [];
  this.graph.links = [];
  this.currentNode = null;
  this.currentGRef = null;
  this.clickCallBack = clickCallBack;
  this.nextKey = 1;
  this.map = {};
  // Init D3
  d3gInit(colours, 25);
  // Set window resize.
  window.addEventListener("resize", this.draw.bind(this));
}

/**
 * Node Click
 *
 * @param [Object] node the node clicked on
 * @return [void]
 */
ImpactAnalysisGraphPanel.prototype.nodeClick = function (node) {
  if (this.currentGRef !== null) {
    d3gClearNode(this.currentGRef);
  }
  this.currentGRef = d3gFindGRef(node.key);
  if (this.currentGRef !== null) {
	  this.currentNode = node;
  	d3gMarkNode(this.currentGRef);
  	this.clickCallBack(node);
  }
}

/**
 * Empty Function
 *
 * @return [Null]
 */
ImpactAnalysisGraphPanel.prototype.empty = function () {
}

/**
 * Add Node to the graph
 *
 * @param [Object] sourceNode the source data beign added.
 * @return [Object] the node added to the graph. Source node plus additonal properties.
 */
ImpactAnalysisGraphPanel.prototype.addNode = function (sourceNode) {
	var uri = toUri(sourceNode.namespace, sourceNode.id);
  if (this.map.hasOwnProperty(uri)) {
  	return this.graph.nodes[this.map[uri]];
  } else {
	  var node = sourceNode;
	  node.uri = uri;
	  node.name = "";
	  node.key = this.nextKey;
	  node.type = sourceNode.rdf_type;
	  this.nextKey++;
	  this.graph.nodes.push(node);
	  var index = this.graph.nodes.length - 1;
	  node.index = index;
	  this.map[uri] = index;
	  return node;
	}
}

/**
 * Link Nodes
 *
 * @param [Integer] source index of the source node
 * @param [Integer] target index of the target node
 * @return [Boolean] always returns true
 */
ImpactAnalysisGraphPanel.prototype.addLink = function (source, target) {
  var link = {};
  link["source"] = source;
  link["target"] = target;
  this.graph.links.push(link);
  return true;
}

/**
 * Draw the graph
 *
 * @return [void]
 */
ImpactAnalysisGraphPanel.prototype.draw = function () {
  var json = JSON.parse(JSON.stringify(this.graph));
  d3gDraw(json, this.nodeClick.bind(this), this.empty.bind(this));
}
;
