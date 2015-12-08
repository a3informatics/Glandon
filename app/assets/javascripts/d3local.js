/*
 * D3 Initialise: Create a D3 tree. 
 *
 * d3Div:             The Div for the tree
 * jsonData:          The nodes for the tree
 * clickCallBack:     The click call back function
 * dblClickCallBack:  The click call back function
 */
function treeNormal(d3Div, jsonData, clickCallBack, dblClickCallBack) {

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
    .attr("fill", function(d) { return nodeColour(d); });

  node.append("text")
    .attr("dx", function(d) { return d.children ? -8 : 8; })
    .attr("dy", 3)
    .attr("text-anchor", function(d) { return d.children ? "end" : "start"; })
    .text(function(d) { if (d.name.length > 15) { return d.name.substring(0,12) + "..."} else { return d.name;} });
//    .text(function(d) { return d.name; });

  d3.select(self.frameElement).style("height", height + "px");
  
}

/**
 *  Function to draw circular tree.
 */
function treeCircular(d3Div,jsonData,clickCallBack, dblClickCallBack) {

  d3.select('svg').remove();

  var radius = (d3Div.clientWidth - 50)/2; 
  var height = d3Div.clientHeight - 50; 

  var cluster = d3.layout.cluster()
        .size([height, radius - 120]);

  var diagonal = d3.svg.diagonal.radial()
    .projection(function(d) { return [d.y, d.x / 180 * Math.PI]; });

  var svg = d3.select(d3Div).append("svg")
    .attr("width", radius * 2)
    .attr("height", radius * 2)
    .append("g")
    .attr("transform", "translate(" + radius + "," + radius + ")");

  var nodes = cluster.nodes(jsonData);
  links = cluster.links(nodes) 

  var link = svg.selectAll("path.link")
    .data(links)
    .enter().append("path")
    .attr("class", "link")
    .attr("d", diagonal);

  var node = svg.selectAll("g.node")
    .data(nodes)
    .enter().append("g")
    .attr("class", "node")
    .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")";  })
    .on("click", clickCallBack)
    .on("dblclick", dblClickCallBack);

  node.append("circle")
    .attr("r", 4.5)
    .attr("fill", function(d) { return nodeColour(d); });

  node.append("text")
    .attr("dy", ".31em")
    .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
    .attr("transform", function(d) { return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"; })
    .text(function(d) { return d.name; });

  d3.select(self.frameElement).style("height", radius * 2 + "px");

}

/*
 * Mark node
 */
function markNode (node, ref) {
  d3.select(ref).select('circle').style("fill", "steelblue");
}

/*
 * Clear node
 */ 
function clearNode (node, ref) {
  if (node.expand) {
    d3.select(ref).select('circle').style("fill", "skyblue");
  } else if ('enabled' in node) {
    if (node.enabled) {
      d3.select(ref).select('circle').style("fill", "mediumseagreen");
    } else {
      d3.select(ref).select('circle').style("fill", "orangered");
    }
  } else {
    d3.select(ref).select('circle').style("fill", "white");
  }
}

/*
 * Clear node
 */ 
function nodeColour (node) {
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