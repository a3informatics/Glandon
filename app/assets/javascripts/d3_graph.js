//var html = $("#jsonData").html();
//var graph = $.parseJSON(html);
var nodeColours;
var d3Div;
var linkDistance;

function d3gInit(colours, linkDist) {
  nodeColours = colours;
  d3Div = document.getElementById("d3");
  linkDistance = linkDist;
}

function d3gDraw(graph, click, dblclick) {
  d3.select('svg').remove();

  var width = d3Div.clientWidth; 
  var height = d3Div.clientHeight; 
  var radius = 7;

  var force = d3.layout.force()
    .gravity(.05)
    .charge(-100)
    .linkDistance(linkDistance)
    .size([width, height]);

  var svg = d3.select(d3Div).append("svg")
    .attr("width", width)
    .attr("height", height);

  var link = svg.selectAll("line")
      .data(graph.links)
    .enter().append("line")
      .attr("class", "link")
      .style("stroke-width", function(d) { return Math.sqrt(d.value); });

  var node = svg.selectAll("circle")
      .data(graph.nodes)
    .enter().append("circle")
      .attr("class", "node")
      .attr("r", radius - .75)
      .on("dblclick", dblclick)
      .on("click", click)
      .style("fill", function(d) { return nodeColour(d); })
      .call(force.drag);

  force
      .nodes(graph.nodes)
      .links(graph.links)
      .on("tick", tick)
      .start();

  function tick() {
    node.attr("cx", function(d) { return d.x = Math.max(radius, Math.min(width - radius, d.x)); })
        .attr("cy", function(d) { return d.y = Math.max(radius, Math.min(height - radius, d.y)); });

    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });
  }

}

function d3gMarkNode (ref) {
  d3.select(ref).style("fill", "gray");
}

function d3gClearNode (node, ref) {
  d3.select(ref).style("fill", nodeColour(node));
}

function nodeColour (node) {
  if (node.type in nodeColours) {
    return nodeColours[node.type]
  } else {
    return "black";
  }
}
