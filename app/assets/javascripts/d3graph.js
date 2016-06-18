$(document).ready(function() {

  var C_FORM = "Form";
  var C_BC = "Biomedical Concept";
  var C_CL = "Code List Item";
  var C_DOMAIN = "Domain";

  var html = $("#jsonData").html();
  var graph = $.parseJSON(html);
  var d3Div = document.getElementById("d3");
  
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
      .charge(-600)
      .linkDistance(100)
      .on("tick", tick);

  var drag = force.drag()
      .on("dragstart", dragstart);

  drawGraph = function(graph, click, dblclick) {
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
      .attr("r", 12)
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
            d3.select(this).append("tspan").attr("dy",15).attr("x",0).text(lines[i])
        }
      });
      //.text(function(d) { if (d.name.length > 15) { return d.name.substring(0,12) + "..." } else { return d.name; } } );

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
      var lines = []

      var line
      while ((line = regex.exec(text))!="") {
        lines.push(line);
      } 

      return lines
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
    
  selectNone();
  drawGraph(graph, click, dblclick);

  /*
   * Node colour function. 
   */ 
  function nodeColour (node) {
    if (node.type == C_FORM) {
      return "skyblue";
    } else if (node.type == C_BC) {
      return "salmon";
    } else if (node.type == C_CL) {
      return "mediumseagreen";
    } else if (node.type == C_DOMAIN) {
      return "dodgerblue";
    } else {
      return "black";
    }
  }

  function dblclick(d) {
    d3.select(this).classed("fixed", d.fixed = false);
  }

  function click(d) {
    displayNode(d);
  }

  function dragstart(d) {
    d3.select(this).classed("fixed", d.fixed = true);
  }

  function selectNone() {
    $("#formTable").addClass('hidden');
    $("#domainTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }

  function selectForm() {
    $("#formTable").removeClass('hidden');
    $("#domainTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }

  function selectDomain() {
    $("#formTable").addClass('hidden');
    $("#domainTable").removeClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#clTable").addClass('hidden');
  }

  function selectBc() {
    $("#formTable").addClass('hidden');
    $("#domainTable").addClass('hidden');
    $("#bcTable").removeClass('hidden');
    $("#clTable").addClass('hidden');
  }
  
  function selectCl() {
    $("#formTable").addClass('hidden');
    $("#domainTable").addClass('hidden');
    $("#bcTable").addClass('hidden');
    $("#clTable").removeClass('hidden');
  }

  function displayNode(node) {
    if (node.type == C_FORM) {
      selectForm();
      displayForm(node);
    } else if (node.type == C_DOMAIN) {
      selectDomain();
      displayDomain(node);
    } else if (node.type == C_BC) {
      selectBc();
      displayBc(node);
    } else if (node.type == C_CL) {
      selectCl();
      displayCl(node);
    }
  }

  function displayForm(node) {
    document.getElementById("formLabel").innerHTML = node.label;
    document.getElementById("formIdentifier").innerHTML = node.identifier;
  }

  function displayDomain(node) {
    document.getElementById("domainLabel").innerHTML = node.label;
    document.getElementById("domainIdentifier").innerHTML = node.identifier;
  }

  function displayBc(node) {
    document.getElementById("bcLabel").innerHTML = node.name;
    document.getElementById("bcIdentifier").innerHTML = node.identifier;
  }

  function displayCl(node) {
    document.getElementById("clParentIdentifier").innerHTML = node.parent_identifier;
    document.getElementById("clIdentifier").innerHTML = node.identifier;
    document.getElementById("clLabel").innerHTML = node.label;
    document.getElementById("clSubmission").innerHTML = node.old_notation;
  }

});