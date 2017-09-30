/**
 * Impact Analysis
 *
 * @param [String] url the start operaiton url
 * @param [String] id the fragment of the uri of the initial start point
 * @param [String] namepace the namespace of the uri of the initial start point
 * @param [Integer] maxlevel the maximum number of hops in the analysis
 * @param [Function] finishedCallback the function to be called on competion
 * @return [void] 
 */

function ImpactAnalysis(url, id, namespace, maxLevel, finishedCallback) {
  this.url = url;
  this.id = id;
  this.namespace = namespace;
  this.finishedCallback = finishedCallback;
  this.ajaxCount = 0;
  this.maxLevel = maxLevel;
  this.graph = new ImpactAnalysisGraphPanel(this.callBack.bind(this));
  this.miTable = new IsoManagedListPanel();
  this.tcTable = new ThesaurusConceptListPanel();
}

ImpactAnalysis.PARENT_NODE = -1;

/**
 * callBack
 *
 * @param [Object] node the D3 node
 * @return [void] 
 */
ImpactAnalysis.prototype.callBack = function (node) {
	if(node.type === C_THC) {
		this.tcTable.highlight(node.key);
		this.miTable.clear();		
	} else {
		this.miTable.highlight(node.key);
		this.tcTable.clear();		
	}
}

ImpactAnalysis.prototype.start = function () {
	var _this = this;
  _this.ajaxCount = 0;
	$.ajax({
    url: _this.url,
    data: { id: _this.id, namespace: _this.namespace },
    type: 'GET',
    dataType: 'json',
    success: function(results) {
    	for (var i=0; i<results.length; i++) {
    		_this.child(results[i], ImpactAnalysis.PARENT_NODE, 1);
  		}
  		_this.graph.draw();
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      _this.finishedCallback();
    }
  });
}

ImpactAnalysis.prototype.child = function (child, index, level) {
	var _this = this;
	if (level <= _this.maxLevel) {
		_this.ajaxCount++;
	  $.ajax({
	    url: "/iso_concept/impact_next",
	    data: { id: getId(child), namespace: getNamespace(child) },
	    type: 'GET',
	    dataType: 'json',
	    success: function(results) {
	    	results.item.rdf_type = results.item.type;
	    	var node = _this.graph.addNode(results.item);
	    	if (index !== ImpactAnalysis.PARENT_NODE) {
	    		_this.graph.addLink(index, node.index);
	    	}
	    	if(node.type === C_THC) {
    			_this.tcTable.add(node.uri, node.key); // Add to table
	    	} else {
    			_this.miTable.add(node.uri, node.key); // Add to table
    		}
		  	for (var i=0; i<results.children.length; i++) {
		  		_this.child(results.children[i].uri, node.index, (level + 1));
	  		}
	  		_this.graph.draw();
				_this.ajaxCount--;
	      if (_this.ajaxCount === 0) {
	      	_this.finishedCallback();
	      }
	    },
	    error: function(xhr,status,error){
	      handleAjaxError(xhr, status, error);
	      _this.finishedCallback();
	    }
	  });
	}
}
;
