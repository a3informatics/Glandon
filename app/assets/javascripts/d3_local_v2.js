/*
 * D3 Initialise: Create a D3 tree. 
 *
 * d3Div:             The Div for the tree
 * jsonData:          The nodes for the tree
 * clickCallBack:     The click call back function
 * dblClickCallBack:  The click call back function
 */
function d3TreeNormal(d3Div, jsonData, clickCallBack, dblClickCallBack) {
  d3.select('svg').remove();
  var width = d3Div.clientWidth - 50; 
  var height = d3Div.clientHeight - 50; 
  var tree = d3.layout.tree()
    .size([height, width - 160]);
  var diagonal = d3.svg.diagonal()
    .projection(function(d) { return [d.y, d.x]; });
  var svg = d3.select(d3Div).append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(40,0)");
  var nodes = tree.nodes(jsonData),
  links = tree.links(nodes);
  var link = svg.selectAll("path.link")
    .data(links)
    .enter().append("path")
    .attr("class", "link")
    .attr("d", diagonal);
  var node = svg.selectAll("g.node")
    .data(nodes)
    .enter().append("g")
    .attr("class", "node")
    .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
    .on("click", clickCallBack)
    .on("dblclick", dblClickCallBack);
  node.append("circle")
    .attr("r", 4.5)
    .attr("fill", function(d) { return d3NodeColour(d); });
  node.append("text")
    .attr("dx", function(d) { return d.children ? -8 : 8; })
    .attr("dy", 3)
    .attr("text-anchor", function(d) { return d.children ? "end" : "start"; })
    .text(function(d) { if (d.name.length > 15) { return d.name.substring(0,12) + "..."} else { return d.name;} });
  d3.select(self.frameElement).style("height", height + "px");
}

/*
 * Mark node
 */
function d3MarkNode (ref) {
  d3.select(ref).select('circle').style("fill", "steelblue");
}

/*
 * Find the d3 node (not the data)
 */
function d3FindGRef(key) {
  var gRef = null;
  var nodes = d3.selectAll("g.node");
  for (var i=0; i<nodes[0].length; i++) {
    var data = nodes[0][i].__data__;
    if (data.key == key) {
      gRef = nodes[0][i];
      break;
    }
  }
  return gRef;
}

/*
 * Find d3 node (not the data) based on name
 */
function d3FindGRefByName(name) {
  var gRef = null;
  var nodes = d3.selectAll("g.node");
  for (var i=0; i<nodes[0].length; i++) {
    var data = nodes[0][i].__data__;
    if (data.name == name) {
      gRef = nodes[0][i];
      break;
    }
  }
  return gRef;
}

/*
 * Get the node from a gRef
 */
function d3GetData(gRef) {
  return gRef.__data__;
}

/*
 * Clear node
 */ 
function d3ClearNode (node, ref) {
  var colour = d3NodeColour(node)
  d3.select(ref).select('circle').style("fill", colour);
}

/*
 * Node colour function. 
 */ 
function d3NodeColour (node) {
  if (node.expand) {
    return "skyblue";
  } else if ('enabled' in node) {
    if (node.enabled) {
      return "mediumseagreen";
    } else {
      return "orangered";
    }
  } else {
    return "white";
  }
}

function d3AdjustHeight (height) {
  if (height < 800) {
    height = 800;
  }  
  $('#d3').css("height",height + "px");  
}  