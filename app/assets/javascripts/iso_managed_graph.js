$(document).ready(function() {

  var C_REFRESH_EVERY = 10;
  var colours = {};
  colours[C_FORM] = "gold";
  colours[C_USERDOMAIN] = "royalblue";
  colours[C_IGDOMAIN] = "dodgerblue";
  colours[C_CLASSDOMAIN] = "deepskyblue";
  colours[C_MODEL] = "powderblue";
  colours[C_BC] = "crimson";
  colours[C_BCT] = "salmon";
  colours[C_THC] = "green";

  var html;
  var graph;
  var node;
  var queue;
  var map;
  var rootIndex;
  var refreshCount;
  var run;
  var CurrentNode;

  // Get initial / root item.
  html = $("#jsonData").html();
  json = $.parseJSON(html);
  var managedItem = json;

  // Create empty graph
  graph = {};
  graph.nodes = [];
  graph.links = [];
  queue = [];
  map = {};
  refreshCount = C_REFRESH_EVERY;
  run = true;
  currentNode = null;

  // Init D3
  d3gInit(colours, 50);
  
  // Create the new node and add children to queue
  rootIndex = newNode(managedItem);
  addToQueue(managedItem, rootIndex);

  // Process the queue
  drawGraph();
  while (queue.length > 0) {
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
    } 
  });

  $('#graph_focus').click(function() {
    if (currentNode != null) {
      linkTo("/iso_concept/graph", currentNode.namespace, currentNode.id) 
    } else {
      var html = alertWarning("You need to select a node.")
      displayAlerts(html);
    }
  });

  // Get the next block of data for the table
  function next(queueNode) {
    $.ajax({
      url: "/iso_managed/graph",
      data: { "id": queueNode.data.subject_ref.id, "namespace": queueNode.data.subject_ref.namespace },
      type: 'GET',
      dataType: 'json',
      success: function(result) {
        var node;
        var uri = toUri(result.namespace, result.id);
        var targetIndex;
        // Node exists?
        if (map.hasOwnProperty(uri)) {
          targetIndex = map[uri];
          //console.log("Map Match 1, uri=" + uri);
        } else {
          targetIndex = newNode(result);
        }
        // Add the parents and children to the processing queue
        addToQueue(result, targetIndex);
        // Update the links
        if (queueNode.index != -1) {
          addLink(queueNode.index, targetIndex);
        }
        // Process the queue.
        processQueue();
      },
      error: function(xhr,status,error){
        handleAjaxError(xhr, status, error);
      }
    });
  }

  function info(node) {
    $.ajax({
      url: "/iso_managed/" + node.id,
      data: { "namespace": node.namespace },
      type: 'GET',
      dataType: 'json',
      success: function(result) {
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

  function newNode(sourceNode) {
    var index;
    var node;
    var uri;
    node = sourceNode;
    node.name = "";
    graph.nodes.push(node);
    uri = toUri(sourceNode.namespace, sourceNode.id);
    index = graph.nodes.length - 1;
    map[uri] = index;
    node.index = index;
    return index;
  }

  function addToQueue(sourceNode, parentIndex) {
    for (i=0; i<sourceNode.children.length; i++) {
      var child = sourceNode.children[i];
      var queueNode = {};
      var uri = toUri(child.subject_ref.namespace, child.subject_ref.id);
      if (map.hasOwnProperty(uri)) {
        addLink(parentIndex, map[uri]);
      } else {
        queueNode.index = parentIndex;
        queueNode.data = child;
        queue.push(queueNode);
      }
    }
    for (i=0; i<sourceNode.parent.length; i++) {
      var parent = sourceNode.parent[i];
      var queueNode = {};
      var uri = toUri(child.subject_ref.namespace, child.subject_ref.id);
      if (map.hasOwnProperty(uri)) {
        addLink(map[uri], parentIndex);
      } else {
        queueNode.index = -1;
        queueNode.data = parent;
        queue.push(queueNode);
      }
    }
  }

  function addLink(source, target) {
    var link;
    link = {};
    link["source"] = source;
    link["target"] = target;
    /*if (source < 0 || target < 0) {
      console.log("Invalid link [" + source + " -> " + target + "]");
    }*/
    graph.links.push(link);
  }

  function drawGraph() {
    var json;
    json = JSON.parse(JSON.stringify(graph));
    if (refreshCount >= C_REFRESH_EVERY) {
      d3gDraw(json, nodeClick, emptyDblClick);
      refreshCount = 0;
    } else {
      refreshCount += 1;
    }
  }

  function processQueue () {
    if (queue.length > 0 && run) {
      next(queue[0]);
      queue.splice(0, 1);
      drawGraph();
    } else {
      refreshCount = C_REFRESH_EVERY;
      drawGraph();
    }
  }

});