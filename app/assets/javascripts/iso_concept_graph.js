$(document).ready(function() {

  var C_REFRESH_START = 10;
  var C_REFRESH_UPPER = 75;
  
  var colours = {};
  colours[C_SI] = "sandybrown";
  colours[C_RS] = "sandybrown";
  
  // Form
  colours[C_FORM] = "gold";
  colours[C_NORMAL_GROUP] = "gold";
  colours[C_COMMON_GROUP] = "gold";
  colours[C_PLACEHOLDER] = "gold";
  colours[C_BC_QUESTION] = "gold";
  colours[C_QUESTION] = "gold";

  // BCs  
  colours[C_BC] = "crimson";
  colours[C_BC_DATATYPE] = "crimson";
  colours[C_BC_ITEM] = "crimson";
  colours[C_BC_PROP] = "crimson";
  colours[C_BC_PROP_VALUE] = "crimson";
  colours[C_BCT] = "salmon";

  // SDTM
  colours[C_USERDOMAIN] = "royalblue";
  colours[C_USERVARIABLE] = "royalblue";
  colours[C_SDTM_IG] = "dodgerblue";
  colours[C_IGDOMAIN] = "dodgerblue";
  colours[C_IGVARIABLE] = "dodgerblue";
  colours[C_CLASSDOMAIN] = "deepskyblue";
  colours[C_CLASSVARIABLE] = "deepskyblue";
  colours[C_MODELVARIABLE] = "powderblue";
  colours[C_MODEL] = "powderblue";
  colours[C_SDTM_CLASSIFICATION] = "orchid";
  colours[C_SDTM_TYPE] = "blueviolet";
  colours[C_SDTM_COMPLIANCE] = "fuchsia";

  // Thesaurus
  colours[C_TH] = "green";
  colours[C_THC] = "green";

  // Refs
  colours[C_TC_REF] = "whitesmoke";
  colours[C_V_REF] = "whitesmoke";
  colours[C_P_REF] = "whitesmoke";
  colours[C_BC_REF] = "whitesmoke";
  colours[C_T_REF] = "whitesmoke";
  colours[C_C_REF] = "whitesmoke";

  var html;
  var graph;
  var node;
  var queue;
  var nodeMap;
  var linkMap;
  var asked;
  var rootIndex;
  var refreshCount;
  var refreshLimit;
  var run;
  var currentNode;

  // Get initial / root item.
  html = $("#jsonData").html();
  json = $.parseJSON(html);
  var managedItem = json;
  //console.log("ManagedItem=" + JSON.stringify(managedItem));
        
  // Create empty graph
  graph = {};
  graph.nodes = [];
  graph.links = [];
  queue = [];
  nodeMap = {};
  linkMap = {};
  asked = {};
  refreshCount = C_REFRESH_START;
  refreshLimit = C_REFRESH_START;
  run = true;
  currentNode = null;

  // Init D3
  d3gInit(colours, 35);
  
  // Create the new node and add children to queue
  rootIndex = addNode(managedItem);
  processLinkedNodes(managedItem, rootIndex);

  // Process the queue
  drawGraphForce();
  if (queue.length > 0) {
    processQueue();
  }

  function nodeClick (node) {
    $('#node_details tbody').empty();
    info(node);
    currentNode = node;
  }

  function emptyClick () {
  }

  function emptyDblClick () {
  }

  $('#graph_stop').click(function() {
    $(this).find('span').toggleClass('glyphicon glyphicon-pause').toggleClass('glyphicon glyphicon-play');
    run = !run;
    if (run) {
      next(queue[0]);
      queue.splice(0, 1);
    } else {
      refreshCount = refreshLimit;
      processQueue();
    }
  });

  $('#graph_focus').click(function() {
    if (currentNode != null) {
      queue = [];
      asked = {};
      refreshLimit = C_REFRESH_START;
      var queueNode = {};
      queueNode.index = currentNode.index;
      queueNode.data = {};
      queueNode.data.id = currentNode.id;
      queueNode.data.namespace = currentNode.namespace;
      queue.push(queueNode);
    } else {
      var html = alertWarning("You need to select a node.")
      displayAlerts(html);
    }
  });

  // Get the next block of data for the table
  function next(queueNode) {
    var id = queueNode.data.id;
    var ns = queueNode.data.namespace;
    //console.log("Request URI=<" + ns + "#" + id + ">");
    $.ajax({
      url: "/iso_concept/graph",
      data: { "id": id, "namespace": ns },
      type: 'GET',
      dataType: 'json',
      success: function(result) {
        var node;
        var uri = toUri(result.namespace, result.id);
        var newIndex;
        // Add node and link
        newIndex = addNode(result);
        addLink(queueNode.index, newIndex);
        // Add the parents and children to the processing queue
        processLinkedNodes(result, newIndex, queueNode.index);
        // Process the queue.
        processQueue();
        // Draw any changes
        drawGraph();
      },
      error: function(xhr,status,error){
        handleAjaxError(xhr, status, error);
      }
    });
  }

  function info(node) {
    $.ajax({
      url: "/iso_concept/" + node.id,
      data: { "namespace": node.namespace },
      type: 'GET',
      dataType: 'json',
      success: function(result) {
        $('#node_details tbody').empty();
        $('#node_details tbody').append(
          '<tr><td><strong>Id:</strong></td><td>' + result.id + '</td></tr>' +
          '<tr><td><strong>Type:</strong></td><td>' + getId(result.type) + '</td></tr>' +
          '<tr><td><strong>Label:</strong></td><td>' + result.label + '</td></tr>'
        );
      },
      error: function(xhr,status,error){
        handleAjaxError(xhr, status, error);
      }
    });
  }

  function addNode(sourceNode) {
    var index;
    var node;
    var uri;
    uri = toUri(sourceNode.namespace, sourceNode.id);    
    if (nodeMap.hasOwnProperty(uri)) {
      index = nodeMap[uri];
    } else {
      node = sourceNode;
      node.name = "";
      graph.nodes.push(node);
      index = graph.nodes.length - 1;
      nodeMap[uri] = index;
      node.index = index;
      //console.log("Result=" + JSON.stringify(sourceNode));
    }
    return index;
  }

  function addLink(source, target) {
    var link;
    var key;
    key = source + "." + target;
    if (linkMap.hasOwnProperty(key)) {
      return false;
    } else if (source == -1 || target == -1) {
      return false;
    } else {
      link = {};
      link["source"] = source;
      link["target"] = target;
      //console.log("Add link [" + source + " -> " + target + "]");
      graph.links.push(link);
      linkMap[key] = true;  
      return true;
    }  
  }

  function processLinkedNodes(sourceNode, newIndex, parentIndex) {
    for (i=0; i<sourceNode.children.length; i++) {
      var child = sourceNode.children[i];
      var queueNode = {};
      var uri = toUri(child.namespace, child.id);
      if (nodeMap.hasOwnProperty(uri)) {
        addLink(newIndex, nodeMap[uri]);
      } else {
        if (asked.hasOwnProperty(uri)) {
          // We have already queued a request. Do nothing
          //console.log("Already asked URI=<" + uri + ">");
        } else {
          queueNode.index = newIndex;
          queueNode.data = child;
          queue.push(queueNode);
          asked[uri] = true;
        }
      }
    }
    for (i=0; i<sourceNode.parent.length; i++) {
      var parent = sourceNode.parent[i];
      var queueNode = {};
      var uri = toUri(parent.namespace, parent.id);
      if (nodeMap.hasOwnProperty(uri)) {
        addLink(nodeMap[uri], newIndex);          
      } else {
        if (asked.hasOwnProperty(uri)) {
          // We have already queued a request. Do nothing
          //console.log("Already asked URI=<" + uri + ">");
        } else {
          queueNode.index = -1;
          queueNode.data = parent;
          queue.push(queueNode);
          asked[uri] = true;
        }
      }
    }
  }

  function drawGraph() {
    var json;
    json = JSON.parse(JSON.stringify(graph));
    if (refreshCount >= refreshLimit) {
      d3gDraw(json, nodeClick, emptyDblClick);
      refreshCount = 0;
      refreshLimit = refreshLimit * 2;
      if (refreshLimit > C_REFRESH_UPPER) {
        refreshLimit = C_REFRESH_UPPER;
      }
    } else {
      refreshCount += 1;
    }
  }

  function drawGraphForce() {
    refreshCount = refreshLimit;
    drawGraph();
  }

  function processQueue () {
    if (queue.length > 0 && run) {
      next(queue[0]);
      queue.splice(0, 1);
    } else {
      drawGraphForce();
    }
  }

});