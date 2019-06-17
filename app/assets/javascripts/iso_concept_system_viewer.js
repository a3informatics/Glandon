$(document).ready(function() {
  
  var csvp = new ConceptSystemViewPanel(conceptSystemId, conceptSystemNamespace, 100);
  
  // Set window resize.
  window.addEventListener("resize", csvp.reDisplay);

});

function ConceptSystemViewPanel(id, namespace, step) { 
  this.id = id;
  this.namespace = namespace;
  this.heightStep = step;
  this.d3Editor = new D3Editor("d3", this.empty.bind(this), this.displayNode.bind(this), this.empty.bind(this), this.validate.bind(this));
  this.displayTree();

  var _this = this;

  $('#d3_minus').click(function () {
    _this.d3Editor.reSizeDisplay(_this.heightStep * -1);
  });

  $('#d3_plus').click(function () {
    _this.d3Editor.reSizeDisplay(_this.heightStep);
  });

  $('#add_tag').click(function () {
    addTag(_this.displayTree.bind(_this));
  });

  $('#update_tag').click(function () {
    updateTag(_this.displayTree.bind(_this));
  });

  $('#delete_tag').click(function () {
    deleteTag(_this.displayTree.bind(_this));
  });
}

ConceptSystemViewPanel.prototype.displayTree = function() {
  var _this = this;
  $.ajax({
    url: '/iso_concept_systems/' + _this.id + '?namespace=' + _this.namespace,
    type: 'GET',
    success: function(result) {
      _this.rootNode = _this.d3Editor.root(result.data.label, result.data.type, result.data)
      for (var i=0; i < result.data.children.length; i++) {
        _this.initNode(result.data.children[i], _this.rootNode);
      }
      _this.d3Editor.displayTree(_this.rootNode.key);
      showTagInfo(_this.rootNode.data);
    },
    error: function(xhr, status, error){
      handleAjaxError (xhr, status, error);
    }
  });
}

ConceptSystemViewPanel.prototype.initNode = function(sourceNode, d3ParentNode) {
  var newNode;
  var child;
  newNode = this.d3Editor.addNode(d3ParentNode, sourceNode.label, sourceNode.type, true, sourceNode, true);
this.d3Editor.displayTree(this.rootNode.key);
  if (sourceNode.hasOwnProperty('children')) {
    for (var i=0; i<sourceNode.children.length; i++) {
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
    showTagInfo(node.data);
  if (node.type ===  C_SYSTEM) {
    $('#update_tag').prop("disabled",true);
    $('#delete_tag').prop("disabled",true);
  } else if (node.type === C_TAG) {
    $('#update_tag').prop("disabled",false);
    $('#delete_tag').prop("disabled",false);
    imlRefresh(node.data.id, node.data.namespace);
  } 
}
