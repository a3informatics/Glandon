$(document).ready(function() {

  var C_REFRESH_START = 10;
  var C_REFRESH_UPPER = 75;
  
  var html;
  var json;
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
  var currentThis;
  var conceptGraph;
  var graphTypeInput;
  var urlRoot;
  var graphDistance;

  // Disable the focus button
  $("#graph_focus").prop("disabled", true);
  $("#graph_running").prop("disabled", true);
  $("#concept_label").prop("disabled", true);
  $("#concept_type").prop("disabled", true);

  // Get initial / root item.
  html = $("#jsonData").html();
  json = $.parseJSON(html);
  var concept = json;
  
  // Set the flags
  graphTypeInput = document.getElementById("graph_type");
  conceptGraph = (graphTypeInput.value === 'concept');
  urlRoot = "/iso_concept/"
  if (!conceptGraph) {
    urlRoot = "/iso_managed/"
  } 

  // Create empty graph
  graph = {};
  graph.nodes = [];
  graph.links = [];
  queue = [];
  nodeMap = {};
  linkMap = {};
  asked = {};
  if (conceptGraph) {
    refreshCount = C_REFRESH_START;
    refreshLimit = C_REFRESH_START;
    graphDistance = 25;
  } else {
    refreshCount = 1;
    refreshLimit = 1;  
    graphDistance = 75;  
  }
  run = true;
  currentNode = null;
  currentThis = null;
  
  // Init D3
  d3gInit(colours, graphDistance);
  
  // Set window resize.
  window.addEventListener("resize", drawGraph);

  // Create the new node and add children to queue
  rootIndex = addNode(concept);
  addToQueue(concept, rootIndex);

  // Process the queue
  drawGraphForce();
  if (queue.length > 0) {
    processQueue();
  }

  function nodeClick (node) {
    if (currentNode != null) {
      d3gClearNode(currentThis);
    }
    $('#node_details tbody').empty();
    info(node);
    d3gMarkNode(this);
    currentNode = node;
    currentThis = this;
  }

  function empty () {
  }

  $('#graph_stop').click(function() {
    $(this).find('span').toggleClass('glyphicon glyphicon-pause').toggleClass('glyphicon glyphicon-play');
    run = !run;
    if (run) {
      clearCurrent();
      processQueue();
      $("#graph_focus").prop("disabled", true);
      spAddSpinner("#graph_running");
    } else {
      drawGraphForce();
      $("#graph_focus").prop("disabled", false);
      spRemoveSpinner("#graph_running");
    }
  });

  $('#graph_focus').click(function() {
    if (currentNode != null) {
      clearQueue();
      addCurrentToQueue();
    } else {
      var html = alertWarning("You need to select a node.")
      displayAlerts(html);
    }
  });

  // Get the next block of data for the table
  function next(queueNode) {
    var uri = queueNode.data.uri
    //console.log("Request URI=<" + ns + "#" + id + ">");
    $.ajax({
      url: urlRoot + "graph_links",
      data: { "id": getId(uri), "namespace": getNamespace(uri) },
      type: 'GET',
      dataType: 'json',
      success: function(result) {
        var node;
        var uri = result.uri;
        var newIndex;
        var i;
        for (i=0; i<result.length; i++) {
          newIndex = addNode(result[i]);
          addLink(queueNode.index, newIndex);
          if (!asked.hasOwnProperty(result[i].uri)) {
            addToQueue(result[i], newIndex)
          }
        }
        processQueue();
        drawGraph();
      },
      error: function(xhr,status,error){
        handleAjaxError(xhr, status, error);
      }
    });
  }

  function info(node) {
    $.ajax({
      url: urlRoot + getId(node.uri),
      data: { "namespace": getNamespace(node.uri) },
      type: 'GET',
      dataType: 'json',
      success: function(result) {
        //$("#concept_type").show();
        //$("#concept_label").show();
        $("#concept_type").val(typeToString[result.type]);
        $("#concept_label").val(result.label);
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
    uri = sourceNode.uri;    
    if (nodeMap.hasOwnProperty(uri)) {
      index = nodeMap[uri];
    } else {
      node = sourceNode;
      node.name = "";
      node.type = sourceNode.rdf_type;
      graph.nodes.push(node);
      index = graph.nodes.length - 1;
      nodeMap[uri] = index;
      node.index = index;
      refreshCount += 1;
    }
    return index;
  }

  function addLink(source, target) {
    var link;
    var key;
    key1 = source + "." + target;
    key2 = target + "." + source;
    if (linkMap.hasOwnProperty(key1)) {
      return false;
    } else if (linkMap.hasOwnProperty(key2)) {
      return false;
    } else {
      link = {};
      link["source"] = source;
      link["target"] = target;
      graph.links.push(link);
      linkMap[key1] = true;  
      linkMap[key2] = true;  
      refreshCount += 1;
      return true;
    }  
  }

  function addToQueue(sourceNode, newIndex) {
    var queueNode;
    queueNode = {};
    queueNode.index = newIndex;
    queueNode.data = sourceNode;
    queue.push(queueNode);
    asked[sourceNode.uri] = true;
  }

  function drawGraph() {
    var json;
    json = JSON.parse(JSON.stringify(graph));
    if (refreshCount >= refreshLimit) {
      d3gDraw(json, nodeClick, empty);
      refreshCount = 0;
      refreshLimit = refreshLimit * 2;
      if (refreshLimit > C_REFRESH_UPPER) {
        refreshLimit = C_REFRESH_UPPER;
      }
    }
  }

  function drawGraphForce() {
    refreshCount = refreshLimit;
    drawGraph();
  }

  function processQueue () {
    if (queue.length > 0 && run) {
      var item;
      item = queue[0];
      queue.splice(0, 1);
      next(item);
    } else {
      drawGraphForce();
      spRemoveSpinner("#graph_running");
    }
  }

  function clearQueue() {
    queue = [];
    asked = {};
    spRemoveSpinner("#graph_running");
  }

  function addCurrentToQueue() {
    var queueNode = {};
    queueNode.index = currentNode.index;
    queueNode.data = {};
    queueNode.data.uri = currentNode.uri;
    queue.push(queueNode);
  }

  function clearCurrent() {
    currentNode = null;
    currentThis = null;
    refreshLimit = C_REFRESH_START; 
  }

});