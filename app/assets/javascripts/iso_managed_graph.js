$(document).ready(function() {

  var C_FORM = "http://www.assero.co.uk/BusinessForm#Form";
  var C_USERDOMAIN = "http://www.assero.co.uk/BusinessDomain#UserDomain";
  var C_USERVARIABLE = "http://www.assero.co.uk/BusinessDomain#UserVariable";
  var C_IGDOMAIN = "http://www.assero.co.uk/BusinessDomain#IgDomain";
  var C_IGVARIABLE = "http://www.assero.co.uk/BusinessDomain#IgVariable";
  var C_CLASSDOMAIN = "http://www.assero.co.uk/BusinessDomain#ClassDomain";
  var C_CLASSVARIABLE = "http://www.assero.co.uk/BusinessDomain#ClassVariable";
  var C_MODELVARIABLE = "http://www.assero.co.uk/BusinessDomain#ModelVariable";
  var C_MODEL = "http://www.assero.co.uk/BusinessDomain#Model";
  var C_BC = "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance";
  var C_BCT = "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptTemplate";
  var C_TC = "http://www.assero.co.uk/ISO25964#ThesaurusConcept";
  var C_REFRESH_EVERY = 25;

  var colours = {};
  colours[C_FORM] = "gold";
  colours[C_USERDOMAIN] = "royalblue";
  colours[C_USERVARIABLE] = "royalblue";
  colours[C_IGDOMAIN] = "dodgerblue";
  colours[C_IGVARIABLE] = "dodgerblue";
  colours[C_CLASSDOMAIN] = "deepskyblue";
  colours[C_CLASSVARIABLE] = "deepskyblue";
  colours[C_MODELVARIABLE] = "powderblue";
  colours[C_MODEL] = "powderblue";
  colours[C_BC] = "crimson";
  colours[C_BCT] = "salmon";
  colours[C_TC] = "green";

  var html;
  var graph;
  var node;
  var queue;
  var map;
  var rootIndex;
  var refreshCount;
  var run;

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

  // Init D3
  d3gInit(colours);
  
  // Create the new node and add children to queue
  rootIndex = newNode(managedItem);
  addToQueue(managedItem, rootIndex);

  // Process the queue
  drawGraph();
  while (queue.length > 0) {
    processQueue();
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

  // Get the next block of data for the table
  function next(queueNode) {
    //var uri = toUri(queueNode.data.subject_ref.namespace, queueNode.data.subject_ref.id);
    //if (map.hasOwnProperty(uri)) {
    //  var targetIndex = map[uri];
    //  if (queueNode.index != -1) {
    //    addLink(queueNode.index, targetIndex);
    //  }
    //} else {
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
          
          //console.log("MAP=" + JSON.stringify(map));

        },
        error: function(xhr,status,error){
          handleAjaxError(xhr, status, error);
        }
      });
    //}
  }

  function newNode(sourceNode) {
    var index;
    var node;
    var uri;
    node = sourceNode;
    node.name = nodeName(node);
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
        //console.log("Map Match 2, uri=" + uri);
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
        //console.log("Map Match 3, uri=" + uri);
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
    if (source < 0 || target < 0) {
      console.log("Invalid link [" + source + " -> " + target + "]");
    }
    graph.links.push(link);
  }

  function drawGraph() {
    var json;
    json = JSON.parse(JSON.stringify(graph));
    if (refreshCount >= C_REFRESH_EVERY) {
      d3gDraw(json, emptyClick, emptyDblClick);
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

  function nodeName(node) {
    var result = node.label;
    if (node.type == C_FORM) {
      //
    } else if (node.type == C_USERDOMAIN) {
      //
    } else if (node.type == C_USERVARIABLE) {
      result = node.name;
    } else if (node.type == C_IGDOMAIN) {
      //
    } else if (node.type == C_IGVARIABLE) {
      //result = node.name;
    } else if (node.type == C_CLASSDOMAIN) {
      //
    } else if (node.type == C_CLASSVARIABLE) {
      //result = node.name;
    } else if (node.type == C_MODELVARIABLE) {
      //result = node.name;
    } else if (node.type == C_MODEL) {
      //
    } else if (node.type == C_BC) {
      //
    } else if (node.type == C_BCT) {
      //
    } else if (node.type == C_TC) {
      //result = node.notation;
    }
    return result;
  }

});