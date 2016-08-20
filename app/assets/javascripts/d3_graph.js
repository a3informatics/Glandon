//var html = $("#jsonData").html();
//var graph = $.parseJSON(html);
var nodeColours;
var d3Div;

function d3gInit(colours) {
  nodeColours = colours;
  d3Div = document.getElementById("d3");
}

function d3gDraw(graph, click, dblclick) {
  d3.select('svg').remove();

  var width = d3Div.clientWidth - 50; 
  var height = d3Div.clientHeight - 50; 

  var svg = d3.select(d3Div).append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(40,0)");

  var force = d3.layout.force()
      .size([width, height])
      .charge(-400)
      .linkDistance(100)
      .on("tick", tick);

  var drag = force.drag()
      .on("dragstart", dragstart);

  force
    .nodes(graph.nodes)
    .links(graph.links)
    .start();

  var link = svg.selectAll(".link")
    .data(graph.links)
    .enter().append("line")
    .attr("class", "link")
    .style("stroke-width", function(d) { return Math.sqrt(d.value); });

  var gnodes = svg.selectAll('g.gnode')
    .data(graph.nodes)
    .enter()
    .append('g')
    .classed('gnode', true);
    
  var node = gnodes.append("circle")
    .attr("class", "node")
    .attr("r", 7)
    .on("dblclick", dblclick)
    .on("click", click)
    .style("fill", function(d) { return nodeColour(d); })
    .call(force.drag);

  var labels = gnodes.append("text")
    .attr("dx", 0)
    .attr("dy", 36)
    .attr("text-anchor", "middle")
    .each(function (d) {
      var lines = wordwrap(d.name, 20)

      for (var i = 0; i < lines.length; i++) {
          //d3.select(this).append("tspan").attr("dy",15).attr("x",0).text(lines[i])
      }
    });

  force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });
    gnodes.attr("transform", function(d) { 
        return 'translate(' + [d.x, d.y] + ')'; 
    });
  });

  function wordwrap(text, max) {
    var regex = new RegExp(".{0,"+max+"}(?:\\s|$)","g");
    var lines = [];
    var line;
    while ((line = regex.exec(text))!="") {
      lines.push(line);
    } 
    return lines;
  } 
}

function tick() {
  link.attr("x1", function(d) { return d.source.x; })
    .attr("y1", function(d) { return d.source.y; })
    .attr("x2", function(d) { return d.target.x; })
    .attr("y2", function(d) { return d.target.y; });
  node.attr("cx", function(d) { return d.x; })
    .attr("cy", function(d) { return d.y; });
}

function dragstart(d) {
  d3.select(this).classed("fixed", d.fixed = true);
}

function nodeColour (node) {
  if (node.type in nodeColours) {
    return nodeColours[node.type]
  } else {
    return "black";
  }
}
