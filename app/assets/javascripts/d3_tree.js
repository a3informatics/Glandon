/**
* A small interface to the D3 library for the creation of trees in a 
* standardised method.
*
*/

var d3HeightOverride = false;
var d3HeightOverrideValue = $(window).height() - 200; 
var rectW = 120;
var rectH = 30;

/**
 * D3 Initialise: Create a D3 tree. 
 *
 * @param d3Div [Object] the Div for the tree
 * @param jsonData [Object] the nodes for the tree
 * @param clickCallBack [Function] the click call back function
 * @param dblClickCallBack [Function] the click call back function
 * @return [Null]
 */
function d3TreeNormal(d3Div, jsonData, clickCallBack, dblClickCallBack) {
  d3.select(d3Div).select('svg').remove();
  var width = d3Div.clientWidth - 50; 
  var height;
  if (d3HeightOverride) {
    height = d3HeightOverrideValue;
  } else {
    //height = $(window).height() - 200; 
    height = d3Div.clientHeight;
  }
  var tree = d3.layout.tree().nodeSize([70, 40])
    .size([height, width - 160]);
  // var diagonal = d3.svg.diagonal()
  //   .projection(function(d) { return [d.y + rectW / 2 - 60, d.x + rectH / 2]; });
  var diagonal = function link(d) {
    return "M" + rectW + "," + (d.source.x + rectH / 2)
        + "C" + (d.source.y + d.target.y) / 2 + "," + (d.source.x + rectH / 2)
        + " " + (d.source.y + d.target.y) / 2 + "," + (d.target.x + rectH / 2)
        + " " + d.target.y + "," + (d.target.x + rectH / 2);
  }; 
  var svg = d3.select(d3Div).append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(40,0)");
  svg.append("svg:defs").selectAll("marker")
      .data(["end"])      // Different link/path types can be defined here
    .enter().append("svg:marker")    // This section adds in the arrows
      .attr("id", String)
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 10)
      .attr("refY", 0)
      .attr("fill", "#ccc")
      .attr("markerWidth", 8)
      .attr("markerHeight", 8)
      .attr("orient", "auto")
    .append("svg:path")
      .attr("d", "M0,-5L10,0L0,5");
  var nodes = tree.nodes(jsonData),
  links = tree.links(nodes);
  var link = svg.selectAll("path.link")
    .data(links)
    .enter().append("path")
    .attr("class", "link")
    .attr("x", rectW / 2 )
    .attr("y", rectH)
    .attr("d", diagonal)
    .attr("stroke-width", 3)
    .style("margin-left", "60px")
    .attr("marker-end", "url(#end)");
  var node = svg.selectAll("g.node")
    .data(nodes)
    .enter().append("g")
    .attr("class", "node")
    .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
    .on("click", clickCallBack)
    .on("dblclick", dblClickCallBack);
  node.append("rect")
    .attr("width", rectW)
    .attr("height", rectH)
    .attr("rx", 4)
    .attr("ry", 4)
    .attr("stroke", "#5cb85c")
    .attr("stroke-width", 1)
    .style("fill", "#fff")
    //.attr("r", 5)
    //.attr("fill", function(d) { return d3NodeColour(d); });
    //.style("fill", function(d) { return d3NodeColour(d); });
  node.append("text")
    .attr("x", rectW / 2)
    .attr("y", rectH / 2)
    .attr("dy", ".35em")
    .attr("text-anchor", "middle")
    //.attr("dx", function(d) { return d.children ? -8 : 8; })
    //.attr("dy", 3)
    //.attr("fill", function(d) { return d3TextColour(d); })
    //.style("fill", function(d) { return d3TextColour(d); })
    //.attr("text-anchor", function(d) { return d.children ? "end" : "start"; })
    .text(function(d) { if (d.name.length > 15) { return d.name.substring(0,12) + "..."} else { return d.name;} });
  d3.select(self.frameElement).style("height", height + "px");
}

/**
 * Marks a node by element reference
 *
 * @param ref [Object] the element reference for the node
 * @return [Null]
 */
function d3MarkNode(gRef) {
  //d3.select(gRef).select("circle").style("fill", "steelblue");
  d3.select(gRef).select("rect").style("fill", "#337ab7");
  d3.select(gRef).select("rect").attr("stroke", "#337ab7");
}

/**
 * Find the node element reference by key
 *
 * @param key [String] the key for the node
 * @return [Object] the node element reference
 */
function d3FindGRef(key) {
  var gRef = null;
  var nodes = d3.selectAll("g.node");
  for (var i=0; i<nodes[0].length; i++) {
    var data = nodes[0][i].__data__;
    if (data.key === key) {
      gRef = nodes[0][i];
      break;
    }
  }
  return gRef;
}

/**
 * Find the node element reference by name
 *
 * @param name [String] the key for the node
 * @return [Object] the node element reference
 */
function d3FindGRefByName(name) {
  var gRef = null;
  var nodes = d3.selectAll("g.node");
  for (var i=0; i<nodes[0].length; i++) {
    var data = nodes[0][i].__data__;
    if (data.name === name) {
      gRef = nodes[0][i];
      break;
    }
  }
  return gRef;
}

/**
 * Find the node data using the element reference
 *
 * @param gRef [Object] the element refeence for the node
 * @return [Object] the node data
 */
function d3GetData(gRef) {
  return gRef.__data__;
}

/**
 * Find the node data by key
 *
 * @param key [String] the key for the node
 * @return [Object] the node data
 */
function d3FindData(key) {
  var result = null;
  var nodes = d3.selectAll("g.node");
  for (var i=0; i<nodes[0].length; i++) {
    var data = nodes[0][i].__data__;
    if (data.key === key) {
      return data
    }
  }
  return result;
}

/**
 * Restore the node colour by element reference
 *
 * @param gRef [Object] the element refeence for the node
 * @return [Object] the node data
 */
function d3RestoreNode(gRef) {
  //d3.select(gRef).select('circle').style("fill", d3NodeColour(gRef.__data__));
  d3.select(gRef).select('rect').style("fill", d3NodeColour(gRef.__data__));
  d3.select(gRef).select('rect').attr("stroke", "none");
  if (d3NodeColour(gRef.__data__) === "white") {
    d3.select(gRef).select('rect').attr("stroke", "#5cb85c");
  }
}

/**
 * Sets the node fill colour
 *
 * @param node [Object] the current node
 * @return [String] the fill colour
 */
function d3NodeColour (node) {
  if (node.expand) {
    return "skyblue";
  }
  if ('enabled' in node) {
    if (node.enabled) {
      if ('is_common' in node) {
        if(node.is_common) {
          return "silver";
        } else {
          return "white";
        }
      } else {
        return "white";
      }
    } else {
      return "orangered";
    }
  } else {
    return "white";
  }
}

/**
 * Sets the node text colour
 *
 * @param node [Object] the current node
 * @return [String] the text colour
 */
function d3TextColour (node) {
  if ('is_common' in node) {
    if(node.is_common) {
      return "silver";
    }
  }
  return "black";
}

function d3AdjustHeight(height) {
  var originalHeight = $(window).height() - 400;
  if (height < originalHeight) {
    height = originalHeight;
  }
  d3HeightOverride = true;
  d3HeightOverrideValue = height;  
  $('#d3').css("height",height + "px");  
}

/*
 * Get Current Height
 *
 * @return [Integer] the exisitng height of the D3 div
 */
function d3GetHeight() {
  var height = $('#d3').css("height");
  return parseInt(height.replace("px", ""));
} 