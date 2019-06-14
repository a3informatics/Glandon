$(document).ready(function() {
  



  var csvp = new ConceptSystemViewPanel(conceptSystemId, conceptSystemNamespace, 100);
  
  // Set window resize.
  window.addEventListener("resize", csvp.reDisplay);

});

function ConceptSystemViewPanel(id, namespace, step) { 
  this.html = $("#jsonData").html();
  this.json = $.parseJSON(this.html);
  // d3eInit("d3", empty, displayNode, empty, emptyValidation);
  this.id = id;
  this.namespace = namespace;
  this.heightStep = step;
  this.d3Editor = new D3Editor("d3", this.empty.bind(this), this.displayNode.bind(this), this.empty.bind(this), this.validate.bind(this));
  this.rootNode = this.d3Editor.root(this.json.label, "", this.json)
  for (i=0; i < this.json.children.length; i++) {
    child = this.json.children[i];
    this.initNode(child, this.rootNode);
  }
  this.d3Editor.displayTree(this.rootNode.key);

  var _this = this;

  $('#d3_minus').click(function () {
    _this.d3Editor.reSizeDisplay(_this.heightStep * -1);
  });

  $('#d3_plus').click(function () {
    _this.d3Editor.reSizeDisplay(_this.heightStep);
  });

  $('#update_tag').click(function () {
    updateTag();
  });

  $('#delete_tag').click(function () {
    deleteTag();
  });
}

ConceptSystemViewPanel.prototype.initNode = function(sourceNode, d3ParentNode) {
  var newNode;
  var i;
  var child;
  newNode = this.d3Editor.addNode(d3ParentNode, sourceNode.label, sourceNode.type, true, sourceNode, true);
  if (sourceNode.hasOwnProperty('children')) {
    for (i=0; i<sourceNode.children.length; i++) {
      child = sourceNode.children[i];
      this.initNode(child, newNode);
    }
  }
}

ConceptSystemViewPanel.prototype.empty = function(node) {
}

ConceptSystemViewPanel.prototype.reDisplay = function() {
  var _this = this;
  _this.d3Editor.reDisplay();
}

ConceptSystemViewPanel.prototype.validate = function(node) {
  return true;
}

ConceptSystemViewPanel.prototype.displayNode = function(node) {
  if (node.type ===  C_SYSTEM) {
    // Do nothing
  } else if (node.type === C_TAG) {
    imlRefresh(node.data.id, node.data.namespace);
    showTagInfo(node.data);
  } 
}
