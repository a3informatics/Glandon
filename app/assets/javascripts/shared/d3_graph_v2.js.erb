/*
* D3 Graph V2 with rdf_type icons
*
*/

/**
 * D3 Graph V2 Constructor
 *
 *
 * @return [void]
 */
function D3GraphV2(height) {
  this.d3Div = document.getElementById("d3");
  this.width = this.d3Div.clientWidth;
  this.height = height || 500;
  this.linkDist = 200;
  this.emptyTextDiv = $("#d3_empty_text");
  this.radius = 20;

}

/**
 * Draws graph
 *
 * @param graph [Object] the json object containing the nodes and links
 * @return [void]
 */
D3GraphV2.prototype.draw = function(graph) {
  var _this = this;
  this.clear();
  this.emptyTextDiv.hide();

  // Make Force Layout
  this.force = d3.layout.force()
    .gravity(0.1)
    .charge(-1000)
    .linkDistance(this.linkDist)
    .linkStrength(0.05)
    .size([this.width, this.height]);
  // Make main SVG
  this.svg = d3.select(this.d3Div).append("svg")
    .attr("preserveAspectRatio", "xMinYMin meet")
    .attr("viewBox", "0 0 " + this.width + " " + this.height)
    .attr("width", this.width)
    .attr("height", this.height)
    .call(d3.behavior.zoom()
            .translate([0, 0])
            .scale(1)
            .scaleExtent([0.3, 2])
            .on("zoom", function () {
              this.svg.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")");
              }.bind(this)))
    .append("g");

  // Make graph links
  this.links = this.svg.selectAll("line")
    .data(graph.links)
    .enter().append("line")
    .attr("class", "link");

  // Make graph nodes
  this.nodes = this.svg.selectAll("node")
    .data(graph.nodes)
    .enter()
    .append('g')
    .classed('node', true)
    .on('mouseover', function(d){_this.onMouseOver.bind(_this)(d);})
    .on('mouseout', this.onMouseOut);

  // Node background + icons
  this.nodes.append("circle")
    .attr("class", "node")
    .attr("r", function(d) { return _this.nodeRadius(d); })
    .style("fill", function(d) { return _this.nodeColour(d); });

  this.nodes.append('text')
    .attr('class', 'icon-')
    .attr('font-size', "16pt")
    .attr('fill', 'white')
    .attr('x', -10)
    .attr('y', 8)
    .text(function(d) { return typeIconCharMap(d.rdf_type) });

  // Start force simulation
  this.force
    .nodes(graph.nodes)
    .links(graph.links)
    .on("tick", this.onTick.bind(this))
    .start();

  d3.select(window).on("resize", this.onRescale.bind(this));
}

/**
 * Called on simulation tick, calculates positions of nodes and links
 *
 * @return [void]
 */
D3GraphV2.prototype.onTick = function() {
  var _this = this;

  // Calculate nodes positions
  this.nodes.attr("transform", function(d) {
    return 'translate(' + d.x + ", " + d.y + ')';
  });

  // Calculate links positions
  this.links
    .attr("x1", function(d) { return d.source.x; })
    .attr("y1", function(d) { return d.source.y; })
    .attr("x2", function(d) { return d.target.x; })
    .attr("y2", function(d) { return d.target.y; });
}

/**
 * Called on window resize, recalculates size of graph
 *
 * @return [void]
 */
D3GraphV2.prototype.onRescale = function() {
  if(this.svg == null)
    return;
  this.width = this.d3Div.clientWidth;
  this.svg.attr("viewBox", "0 0 " + this.width + " " + this.height)
  this.force.size([this.width, this.height]).resume();
}

/**
 * Called on mouse out over node, hides tooltip with text
 *
 * @return [void]
 */
D3GraphV2.prototype.onMouseOut = function() {
  d3.select("#d3_tooltip").classed("hidden", true);
}

/**
 * Called on mouse over node, shows tooltip with text
 *
 * @return [void]
 */
D3GraphV2.prototype.onMouseOver = function(d) {
  var tooltipHTML = "<div class='font-regular text-small'>" + typeToString[d.rdf_type] + "</div>" +
                    "<div class='font-light text-small'>" + d.label + " ("+d.identifier+")</div>";

  var t = d3.transform(this.svg.attr("transform"));

  d3.select("#d3_tooltip")
    .style("transform", "translate(" + (t.translate[0] + (d.x*t.scale[0]) + 50 ) + "px, " + (t.translate[1] + (d.y*t.scale[1]) - 80) + "px)")
    .html(tooltipHTML);

  d3.select("#d3_tooltip").classed("hidden", false);
}

/**
 * Clears graph
 *
 * @return [void]
 */
D3GraphV2.prototype.clear = function() {
  d3.select('svg').remove();
}

/**
 * Node Radius
 *
 * @param [Object] node the node object
 * @return [Integer] node radius calculated depending on the amount of links to the node
 */
D3GraphV2.prototype.nodeRadius = function (node) {
  if (node.impactLinks == null)
    return this.radius + 4;
  else{
    return (node.impactLinks.length > 4 ? 4 : node.impactLinks.length) * 4 + this.radius;
  }
}

/**
 * Node Colour
 *
 * @param [Object] node the node object
 * @return [String] Node color based on its rdf_type and / or owner
 */
D3GraphV2.prototype.nodeColour = function (node) {
  var color = typeToBgColor(node.rdf_type, {owner: node.owner});
  if (typeof color == "undefined")
    return "black";
  else
    return color;
}
