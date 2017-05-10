//var html = $("#jsonData").html();
//var graph = $.parseJSON(html);
var nodeColours;
var d3Div;
var linkDistance;
var toggle;
var linkedByIndex;
  
function d3gInit(colours, linkDist) {
  nodeColours = colours;
  d3Div = document.getElementById("d3");
  linkDistance = linkDist;
}

function d3gDraw(graph, click, dblclick) {
  d3.select('svg').remove();

  var width = d3Div.clientWidth; 
  //var height = d3Div.clientHeight; 
  var height = $(window).height() - 200; 
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
    //.on("dblclick", dblclick)
    .on("click", click)
    .style("fill", function(d) { return nodeColour(d); })
    .call(force.drag)
    .on('dblclick', connectedNodes); // New

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

  //Toggle stores whether the highlighting is on
  toggle = 0;
  linkedByIndex = {};
  for (i = 0; i < graph.nodes.length; i++) {
    linkedByIndex[i + "," + i] = 1;
  };
  graph.links.forEach(function (d) {
    linkedByIndex[d.source.index + "," + d.target.index] = 1;
  });

  //This function looks up whether a pair are neighbours  
  function neighboring(a, b) {
    return linkedByIndex[a.index + "," + b.index];
  }

  function connectedNodes() {
    if (toggle == 0) {
      //Reduce the opacity of all but the neighbouring nodes
      d = d3.select(this).node().__data__;
      node.style("opacity", function (o) {
          return neighboring(d, o) | neighboring(o, d) ? 1 : 0.1;
      });
      link.style("opacity", function (o) {
          return d.index==o.source.index | d.index==o.target.index ? 1 : 0.1;
      });
      toggle = 1;
    } else {
      node.style("opacity", 1);
      link.style("opacity", 1);
      toggle = 0;
    }
  }
}

function d3gMarkNode (ref) {
  d3.select(ref).style("fill", "gray");
}

/**
 * Find the node element reference by key
 *
 * @param key [String] the key for the node
 * @return [Object] the node element reference
 */
function d3gFindGRef(key) {
  var gRef = null;
  var nodes = d3.selectAll("circle");
  for (var i=0; i<nodes[0].length; i++) {
    var data = nodes[0][i].__data__;
    if (data.key === key) {
      gRef = nodes[0][i];
      break;
    }
  }
  return gRef;
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