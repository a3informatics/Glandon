function ConceptSystemViewPanel(id, namespace, step, callback) { 
  this.id = id;
  this.namespace = namespace;
  this.heightStep = step;
  this.callback = callback;
  this.d3Editor = new D3Editor("d3", this.empty.bind(this), this.displayNode.bind(this), this.empty.bind(this), this.validate.bind(this));
  this.displayTree();

  var _this = this;

  $('#d3_minus').click(function () {
    _this.d3Editor.reSizeDisplay(_this.heightStep * -1);
  });

  $('#d3_plus').click(function () {
    _this.d3Editor.reSizeDisplay(_this.heightStep);
  });

  $('#d3Search input')
    .unbind() // Unbind previous default bindings
    .bind("keyup", function(e) { // Bind our desired behavior
      if(this.value !== "" && e.keyCode == 13) {
        d3ClearSearch();
        d3Search(this.value);
      }
      return;
  });

  $('#clearSearch').click(function(){
    $('#d3Search input').val('');
    d3ClearSearch();
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
      _this.displayNode(_this.rootNode);
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
  var _this = this;
  _this.callback(node.data);
}

