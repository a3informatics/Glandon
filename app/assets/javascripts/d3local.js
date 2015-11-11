/*
 * D3 Initialise: Create a D3 tree. 
 *
 * d3Div:           The Div for the tree
 * jsonData:        The nodes for the tree
 * clickCallBack:   The click call back function
 */
function d3Initialise(d3Div,jsonData,clickCallBack) { 
          
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

  var nodes = tree.nodes(bcObject),
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
    .on("click", clickCallBack);

  node.append("circle")
    .attr("r", 8.0);

  node.append("text")
    .attr("dx", function(d) { return d.children ? -8 : 8; })
    .attr("dy", 3)
    .attr("text-anchor", function(d) { return d.children ? "end" : "start"; })
    .text(function(d) { return d.name; });

  d3.select(self.frameElement).style("height", height + "px");

}