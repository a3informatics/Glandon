$(document).ready(function() {
  
  var html;
  var json;
  var rootNode;
  var mi;

  html = $("#jsonData").html();
  json = $.parseJSON(html);
  mi = json.managed_item;
  d3eInit(empty, displayNode, dblClick);
  rootNode = d3eRoot(mi.label, "", mi)
  rootNode.children_checked = true;
  if (mi.hasOwnProperty('children')) {
    for (i=0; i<mi.children.length; i++) {
      child = mi.children[i];
      setD3(child, rootNode);
    }
  }
  d3eDisplayTree(rootNode.key);
  
  /*
  * Double Click Callback
  *
  * @param d3Node [Object] The D3 node double clicked on
  * @return [Null]
  */
  function dblClick(d3Node) {
    if (!d3Node.children_checked) {
      $.ajax({
        url: "/thesaurus_concepts/" + d3Node.data.id,
        data: {
          "id": d3Node.data.id,
          "namespace": d3Node.data.namespace
        },
        dataType: 'json',
        success: function(result){
          for (i=0; i<result.children.length; i++) {
            var child = result.children[i];
            setD3(child, d3Node);
          }
          d3Node.children_checked = true;
          d3eDisplayTree(d3Node.key);
        }
      });  
    }
  }

  /*
  * Empty Callback Function
  *
  * @param node [Object] The D3 node
  * @return [Null]
  */
  function empty(node) {
  }

  /*
  * Set the D3 Structures
  *
  * @param sourceNode [Object] The data node
  * @param d3ParentNode [Object] The parent D3 node
  * @return [Null]
  */
  function setD3(sourceNode, d3ParentNode) {
    var use;
    var newNode;
    var i;
    var child;
    newNode = d3eAddNode(d3ParentNode, sourceNode.label, sourceNode.type, true, sourceNode, true);
    newNode.children_checked = false;
    if (sourceNode.hasOwnProperty('children')) {
      for (i=0; i<sourceNode.children.length; i++) {
        child = sourceNode.children[i];
        setD3(child, newNode);
      }
    }
  }

  /*
  * Display The Current Node
  *
  * @return [Null]
  */
  function displayNode() {
    var node = d3eGetCurrent();
    $('#conceptLabel').html(node.data.label); 
    $('#conceptId').html(node.data.identifier);
    $('#conceptNotation').html(node.data.notation);
    $('#conceptDefinition').html(node.data.definition);
    $('#conceptPreferredTerm').html(node.data.preferredTerm);
    $('#conceptSynonym').html(node.data.synonym); 
  }

});