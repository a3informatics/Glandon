$(document).ready(function() {
  
  var html;
  var json;
  var rootNode;
  var mi;
  var mainTabe;
  var ordinal;

  // Initialise main table
  mainTable = $('#main').DataTable({
    rowId: 'id',
    pageLength: pageLength,
    lengthMenu: pageSettings,
    columns: [
      {"data" : "ordinal", "width" : "5%"},
      {"data" : "label", "width" : "10%"},
      {"data" : "question_text", "width" : "10%"},
      {"data" : "datatype", "width" : "5%"},
      {"data" : "format", "width" : "5%"},
      {"data" : "mapping", "width" : "5%"},
      {"data" : "terminology", "width" : "15%"},
      {"data" : "completion", "width" : "30%"},
      {"data" : "note", "width" : "20%"}
    ]
  });

  // Init any data. Draw the tree
  initData();
  
  /*
  * Init function
  */
  function initData () { 
    html = $("#jsonData").html();
    json = $.parseJSON(html);
    mi = json.managed_item;
    rootNode = mi;
    ordinal = 1;
    if (mi.hasOwnProperty('children')) {
      for (i=0; i<mi.children.length; i++) {
        child = mi.children[i];
        processNode(child, mi);
      }
    }
  }

  /*
  * Set the D3 Structures
  *
  * @param sNode [Object] The data node
  * @param d3ParentNode [Object] The parent D3 node
  * @return [Null]
  */
  function processNode(sNode, parentSNode, ordinal) {
    var use;
    var i;
    var child;
    sNode.parent = parentSNode
    //use = sNode.hasOwnProperty('is_common') ? !sNode.is_common : true;
    //if (use) {
      buildRow(sNode, ordinal);
      if (sNode.hasOwnProperty('children')) {
        for (i=0; i<sNode.children.length; i++) {
          child = sNode.children[i];
          processNode(child, sNode, ordinal);
        }
      }
    //}
  }

  /*
  * Build a table row
  */
  function buildRow(sNode, ordianl) {
    var d3Node = {};
    var optional = false 
    if (sNode.hasOwnProperty('note')) {
      getMarkdown(sNode, sNode.note, noteCallback);
    } else {
      sNode.note = "";
    }
    if (sNode.hasOwnProperty('completion')) {
      getMarkdown(sNode, sNode.completion, completionCallback);
    } else {
      sNode.completion = "";
    }
    if (sNode.hasOwnProperty('optional')) {
      sNode.DT_RowClass = sNode.optional ? "warning" : "";
    }
    sNode.question_text = sNode.hasOwnProperty('question_text') ? sNode.question_text : "";
    sNode.datatype = sNode.hasOwnProperty('datatype') ? sNode.datatype : "";
    sNode.format = sNode.hasOwnProperty('format') ? sNode.format : "";
    sNode.mapping = sNode.hasOwnProperty('mapping') ? sNode.mapping : "";
    sNode.terminology = "";
    d3Node.data = sNode;
    d3Node.type = sNode.type; // Need to copy this up
    if (isCommonItem(d3Node)) {
      if (d3Node.data.item_refs.length > 0) {
        getBcPropertyCommon(d3Node, bcPropertyResult)
      }
      sNode.ordinal = ordinal;
      mainTable.row.add(sNode).draw();
      ordinal += 1;
    } else if (sNode.type == C_TC_REF) {
      getThesaurusConcept(d3Node, tcResult)
    } else if (sNode.type == C_BC_QUESTION) {
      getBcProperty(d3Node, bcPropertyResult);
      sNode.ordinal = ordinal;
      mainTable.row.add(sNode).draw();
      ordinal += 1;
    } else {
      sNode.ordinal = ordinal;
      mainTable.row.add(sNode).draw();
      ordinal += 1;
    }
  }

  /*
  * markdown callbacks
  */
  function noteCallback(sNode, text) {
    var index = mainTable.row('#' + sNode.id);
    if(index.length > 0) {
      sNode.note = text;
      mainTable.row(index[0]).data(sNode)
    }
  }

  function completionCallback(sNode, text) {
    var index = mainTable.row('#' + sNode.id);
    if(index.length > 0) {
      sNode.completion = text
      mainTable.row(index[0]).data(sNode)
    }
  }

  /*
  * Thesaurus Ref AJAX Result Callback
  *
  * @param node [Object] The D3 node
  * @param result [Object] Result received from server
  * @return [Null]
  */
  function tcResult(d3Node, result) {
    d3Node.data.subject_data = result;
    var sNode = d3Node.data;
    var parentSNode = sNode.parent;
    var index = mainTable.row('#' + parentSNode.id);
    if(index.length > 0) {
      parentSNode.terminology = parentSNode.terminology + result.notation + " [" + result.identifier + "]" + "<br/>" 
      mainTable.row(index[0]).data(parentSNode)
    }
  }

  /*
  * BC Property Ref AJAX Result Callback
  *
  * @param node [Object] The D3 node
  * @param result [Object] Result received from server
  * @return [Null]
  */
  function bcPropertyResult(d3Node, result) {
    d3Node.data.subject_data = result;
    var sNode = d3Node.data;
    var index = mainTable.row('#' + sNode.id);
    if(index.length > 0) {
      sNode.question_text = result.question_text;
      sNode.datatype = result.simple_datatype;
      sNode.format = result.format;
      sNode.optional = result.optional;
      mainTable.row(index[0]).data(sNode);
    }
  }
  
});