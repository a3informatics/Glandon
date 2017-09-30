var bceBcs;
var bcePanelIndexMap;
var bceCurrentIndex;
var bceFirstIndex;
var bceWarningTimeout;
var bceId;
var bceNamespace;
var bceMainTable;
var bceEditor;
var bceTempTable;
var bceEmptyProperty;
var bceBcData;
var bceBcRow;
var bceBcTable;

var C_PANEL_COUNT = 4;
var C_MAX_COUNT = 8;
var C_NULL = -1;

$(document).ready(function() {
  
  bceBcTable = $('#bc_table').DataTable( {
    "ajax": {
      "url": "/biomedical_concepts/editable",
      "dataSrc": "data",
      error: function (xhr, status, error) {
        displayError("An error has occurred loading the Add Biomedical Concepts table.");
      }
    },
    dataType: 'json',
    "bProcessing": true,
    "language": {
      "processing": "<img src='/assets/processing-9034d5d34015e4b05d2c1d1a8dc9f6ec9d59bd96d305eb9e24e24e65c591a645.gif'>"
    },
    "columns": [
      {"data" : "scoped_identifier.identifier", "width" : "50%"},
      {"data" : "label", "width" : "50%"}
    ]
  });

  bceInit();
  if (bceId !== "") {
    // Initial BC, locked
    bceAddBc(bceId, bceNamespace, false);
  } else {
    bceTempTableInit();
  }

  $('#close_button').click(function() {
    window.location.href = $('#close_path').val();
  });

  // Set up the form validation for the create BC function.
  validatorDefaults ();
  $('#main_form').validate({
    rules: {
      "biomedical_concept[identifier]": {required: true, identifier: true },
      "biomedical_concept[label]": {required: true, label: true }
    },
    submitHandler: function(form) {
      bceCreateRest();
      return false;
    },
    invalidHandler: function(event, validator) {
      displayWarning("The form is not valid. Please correct the errors.");
    }
  });

  $('.bc-panel-select').click(function (event) {
    var id = $(this).parent().attr("id");
    var panelId = id.replace("bc_panel_", "");
    var index = bcePanelIndexMap[panelId];
    bceSelectBc(index);
  });

  $('.bc-close').click(function (event) {
    var panelId = this.id.replace("bc_close_", "");
    var index = bcePanelIndexMap[panelId];
    bceCloseBc(index);
  });

  $('#bc_previous').click(function (event) {
    if (bceFirstIndex >= 1 && bceBcs.length > C_PANEL_COUNT) {
      bceFirstIndex -= 1;
      bceCheckCurrent();
      bcePanelMove();
      bceShowCurrentBc();
    }
    bceEnableDisablePreviousNext();
  });

  $('#bc_next').click(function (event) {
    if (bceFirstIndex < (bceBcs.length - C_PANEL_COUNT) && bceBcs.length > C_PANEL_COUNT)  {
      bceFirstIndex += 1;
      bceCheckCurrent();
      bcePanelMove();
      bceShowCurrentBc();
    }
    bceEnableDisablePreviousNext();
  });

  $('#bc_save').click(function (event) {
    for (var i=0; i<bceBcs.length; i++) {
      ttExtendLock(bceBcs[i].uiIndex);
    }
  });

  $('#bc_add').click(function() {
    var data;
    var text;
    if (bceBcRow !== null) {
      data = bceBcTable.row(bceBcRow).data();
      if (!bceLoaded(data)) {
        // Edit BC from within editor, needs locking
        bceAddBc(data.id, data.namespace, true);
      } else {
        displayWarning("You have already loaded this Biomedical Concept.");
      }
    } else {
      displayWarning("You need to select a notepad item.");
    }
  });

  $('#bc_table tbody').on('click', 'tr', function () {
    var row = bceBcTable.row(this).index();
    var data = bceBcTable.row(row).data();
    if (bceBcRow !== null) {
      $(bceBcRow).toggleClass('success');
    }
    $(this).toggleClass('success')
    bceBcData = data;
    bceBcRow = this
  });

});
  
function bceCreateRest() {
  var identifier = $('#biomedical_concept_identifier').val();
  var label = $('#biomedical_concept_label').val();
  var uri = $('#biomedical_concept_uri').val();
  var data = { "biomedical_concept": { "identifier": identifier, "label": label, "uri": uri }};
  $.ajax({
    url: '/biomedical_concepts/',
    type: 'POST',
    data: JSON.stringify(data),
    dataType: 'json',
    contentType: 'application/json',
    success: function(result){
      displaySuccess("The Biomedical Concept was succesfully created.");
      // Edit a new BC created in editor, needs locking
      bceAddBc(result.data.id, result.data.namespace, true);
      $('#biomedical_concept_identifier').val("");
      $('#biomedical_concept_label').val("");
    },
    error: function(xhr,status,error){
      handleAjaxError (xhr, status, error);
    }
  }); 
}

function bceInit() {
  bceBcs = [];
  bceFirstIndex = 0;
  bcePanelIndexMap = {};
  bceCurrentIndex = C_NULL;
  bceWarningTimeout = $('#warning_timeout').val();
  bceId = $('#bc_id').val();
  bceNamespace = $('#bc_namespace').val();
  bceMainTable = null;
  bceEditor = null;
  bceTempTable = null;
  bceBcRow = null;
  bceHidePanels();
  bceHideTimers();
  bceHideTempTable();
  bceHideEditorTable();
  bceEnableDisablePreviousNext();
  bceEmptyProperty = 
  {
    "type": C_BC_PROP, 
    "id": "", 
    "namespace": "", 
    "label": "", 
    "question_text": "", 
    "prompt_text": "", 
    "enabled": "", 
    "collect": "",
    "format": "",
    "simple_datatype": ""      
  };
  tfeInit();
  tfeSetCallBacks(bceComplete, bceUpDown, bceUpDown);
}

function bceUpDown(row) {
  bceComplete(1, row);
}

function bceComplete(count, row) {
  var type;
  var data;
  var rowData = bceEditorTable.row(row).data();
  if (count === 0) {
    type = "DELETE";
    data = { "property": { "namespace": rowData.namespace }};
  } else {
    var refs = tfeToRefs();
    type = "POST";
    data = { "property": { "namespace": rowData.namespace, "tc_refs": refs }};    
  }      
  $.ajax({
    url: "/biomedical_concepts/properties/" + rowData.id + "/term",
    type: type,
    data: JSON.stringify(data),
    dataType: 'json',
    contentType: 'application/json',
    error: function (xhr, status, error) {
      displayError("An error has occurred updating the terminology for a Biomedical Concept.");
    },
    success: function(result) {
      bceEditorTable.row(row).data(result.data[0]);    
      bceEditorTable.draw();
      bceGetBc(bceCurrentIndex, false);
    }
  });
}

function bceLoaded(data) {
  var uri;
  var new_uri = toUri(data.namespace, data.id);
  for (var i=0; i<bceBcs.length; i++) {
    uri = toUri(bceBcs[i].namespace, bceBcs[i].id);
    if (new_uri === uri) {
      return true;
    }  
  }
  return false;
}

function bceCheckCurrent() {
  if (bceCurrentIndex < bceFirstIndex) {
    bceCurrentIndex = bceFirstIndex;
  }
  if (bceCurrentIndex >= (bceFirstIndex + C_PANEL_COUNT)) {
    bceCurrentIndex = bceFirstIndex + C_PANEL_COUNT - 1;
  }
}

function bceSelectBc(index) {
  bceCurrentIndex = index;
  bceShowCurrentBc();
}

function bceCloseBc(index) {
  var panelId = 1;
  var bcIndex = index;
  for (var i=0; i<bceBcs.length; i++) {
    ttRemoveToken(bceBcs[i].uiIndex);
    bceClearToken(i)
  }
  bceHidePanels();
  bceHideTimers();
  //bceCurrentIndex = C_NULL; 
  bceBcs.splice(bcIndex, 1);
  bcePanelIndexMap = {}
  if (bceBcs.length > 0) {
    if (bceFirstIndex === bcIndex) {
      bceFirstIndex -= 1;
      if (bceFirstIndex < 0) {
        bceFirstIndex = 0;
      }
    }
    if (bceCurrentIndex >= bcIndex) {
      bceCurrentIndex -= 1;
      if (bceCurrentIndex < 0) {
        bceCurrentIndex = 0;
      }
    }
    bceCheckCurrent();
    for (var i=0; i<bceBcs.length; i++) {
      bceBcs[i].uiIndex = i + 1;
      bceBcs[i].panelId = C_NULL;
      bceSetToken(i);
      ttAddToken(bceBcs[i].uiIndex);
    }
    for (var i=bceFirstIndex; i<bceBcs.length; i++) {
      if (panelId <= C_PANEL_COUNT) {
        bceBcs[i].panelId = panelId;
        panelId += 1;
        bceGetBc(i, false);
      } else {
        break;
      }
    }
    bceShowCurrentBc();
  } else {
    bceFirstIndex = 0;
    bceCurrentIndex = C_NULL;
  }
  bceShowBcCount();
  bceEnableDisablePreviousNext();
}

function bcePanelMove() {
  var panelId = 1;
  for (var i=0; i<bceBcs.length; i++) {
    bceBcs[i].panelId = C_NULL;
  }
  for (var i=bceFirstIndex; i<bceBcs.length; i++) {
    if (panelId <= C_PANEL_COUNT) {
      bceBcs[i].panelId = panelId;
      if (bceBcs[i].display) {
        bceShowPanel(i);
        bceBcTree(i);
      }
    } else {
      break;
    }
    panelId += 1;
  }
}

function bceShowCurrentBc() {
  var bc = bceBcs[bceCurrentIndex];
  var panelId = bceBcs[bceCurrentIndex].panelId;
  bceId = bc.id;
  bceNamespace = bc.namespace;
  if (bceEditor === null) {
    bceEditorTableInit();
  } else {
    bceEditorTable.ajax.url(bceBcUrl()).load();
  }
  $(".bc-panel").removeClass("panel-success"); 
  $("#bc_panel_" + panelId).addClass("panel-success");
  tfeDisable();
  tfeClear();  
}

function bceAddBc(id, namespace, lockReqd) {
  var bcIndex = bceBcs.length;
  var uiIndex = bcIndex + 1;
  var panelId = C_NULL;
  var ok = true;
  if (bcIndex === 0) {
    bceCurrentIndex = bcIndex;
    panelId = 1;
    bceCreateBcRecord(id, namespace, bcIndex, uiIndex, panelId);
  } else if (bceBcs.length < C_PANEL_COUNT) {
    bceCurrentIndex = bcIndex;
    panelId = bceBcs.length + 1;
    bceCreateBcRecord(id, namespace, bcIndex, uiIndex, panelId);
  } else if (bceBcs.length >= C_MAX_COUNT) {
    displayError("Maximum number of Biomedical Concepts are being edited already. Max number is " + C_MAX_COUNT);
    ok = false;
  } else {
    bceFirstIndex += 1;
    bceCurrentIndex = bcIndex;
    bceCreateBcRecord(id, namespace, bcIndex, uiIndex, C_NULL);
    bcePanelMove();
  }
  if (ok) {    
    bceGetBc(bcIndex, lockReqd);
    bceShowBcCount();
    bceShowCurrentBc();
    bceEnableDisablePreviousNext();
  }
}

function bceCreateBcRecord(id, namespace, bcIndex, uiIndex, panelId) {
  bceBcs[bcIndex] = { "id": id, "namespace": namespace, "label": "", "identifier": "", "panelId": panelId, "uiIndex": uiIndex, "display": false};
  bceBcs[bcIndex].d3Editor = null;
}

function bceGetBc(index, lockReqd) {
  var url;
  if (lockReqd) {
    url = "/biomedical_concepts/" + bceBcs[index].id + "/edit_lock";    
  } else {
    url = "/biomedical_concepts/" + bceBcs[index].id + "/show_full";
  }
  $.ajax({
    url: url,
    type: "GET",
    data: { "biomedical_concept": { "namespace": bceBcs[index].namespace }},
    dataType: 'json',
    error: function (xhr, status, error) {
      displayError("An error has occurred loading a Biomedical Concept.");
    },
    success: function(result) {
      if (lockReqd) {
        bc = result.bc;
        bceBcs[index].token = result.token;
      } else {
        bc = result;
        bceBcs[index].token = bceGetToken(index); // No lock reqd, so assume it is set
      }
      bceBcs[index].display = true;
      bceBcs[index].json = bc;
      bceBcs[index].label = bc.label;
      bceBcs[index].identifier = bc.identifier;
      bceSetToken(index);
      ttAddToken(bceBcs[index].uiIndex);
      bceShowPanel(index) 
      bceBcTree(index);
    }
  });
}

function bceEditorTableInit() {
  bceEditor = new $.fn.dataTable.Editor( {
    ajax: {
      edit: {
          type: 'PUT',
          url:  '/biomedical_concepts/properties/_id_'
      },
    },
    table: "#editor_table",
    idSrc: "id",
    fields: 
    [
      {
          label: "Question Text",
          name: "question_text"
      },
      {
          label: "Prompt Text",
          name: "prompt_text"
      },
      {
          label: "Enabled",
          name: "enabled"
      },
      {
          label: "Collect",
          name: "collect"
      },
      {
          label: "Format",
          name: "format"
      }
    ]
  });
 
  bceEditorTable = $('#editor_table').DataTable({
    pageLength: 15,
    lengthMenu: [[5, 10, 15, 20, 25, 50, -1], [5, 10, 15, 20, 25, 50, "All"]],
    ajax: {
      url: bceBcUrl(),
      "dataSrc": "children",
      error: function (xhr, status, error) {
        displayError("An error has occurred loading the Biomedical Concept edit table.");
      }
    },
    rowId: 'id',
    columns: [
      { data: "alias" },
      { data: "question_text" },
      { data: "prompt_text" },
      { data: "enabled", render: function(data, type, full, meta) { 
        if (data) {
          return "<span class=\"glyphicon glyphicon-ok text-success\"/>";
        } else {
          return "<span class=\"glyphicon glyphicon-remove text-danger\"/>";
        }
      }},
      { data: "collect", render: function(data, type, full, meta) { 
        if (data) {
          return "<td class=\"text-center\"><span class=\"glyphicon glyphicon-ok text-success\"/></td>";
        } else {
          return "<td class=\"text-center\"><span class=\"glyphicon glyphicon-remove text-danger\"/></td>";
        }
      }},
      { data: "simple_datatype", render: function(data, type, full, meta) { 
        if (full.coded) {
          return data + " [coded]";
        } else {
          return data;
        }
      }},
      { data: "format" },
      { data: "children", "render": function(data, type, full, meta) { 
        if (full.enabled && full.coded) {
          return bceFormatTerminology(full.children);
        } else {
          return ""
        }
      }},
      { data: null, "render": function(data, type, full, meta) { 
        if (full.enabled && full.coded) {
          return '<button class="btn btn-primary btn-xs">T</button>';
        } else {
          return ""
        }
      }}
    ],
    keys: {
        columns: [ 1, 2, 6 ],
        keys: [ 9, 38, 40 ]
    }
  });

  // Click on the table.
  $('#editor_table').on('click', 'tbody td:not(:first-child)', function (e) {
    var idx = bceEditorTable.cell(this).index();
    var row = idx.row;
    var col = idx.column;
    var cellData = bceEditorTable.cell(this).data();
    var rowData = bceEditorTable.row(row).data();
    tfeDisable();
    tfeClear();
    if (col === 3) {
      cellData = !cellData;
      bceEditor.edit(row, false).set('enabled', cellData).submit();
    } else if (col === 4) {
      cellData = !cellData;
      bceEditor.edit(row, false).set('collect', cellData).submit();
    } else if (col === 8) {
      if (rowData.enabled && rowData.coded) {
        tfeEnable(rowData.alias, row);
        tfeLoad(rowData.children);  
      }
    } else if (col === 5 || col === 7) {
    } else {
      bceEditor.inline(bceEditorTable.cell(this).index(), { submitOnBlur: true, submit: 'all' });
    }
  });

  // Inline editing on tab focus
  bceEditorTable.on( 'key-focus', function ( e, datatable, cell ) {
    bceEditor.inline( cell.index(), { submitOnBlur: true, submit: 'all' } );
  } );

  // Presubmit event. Format the data.
  bceEditor.on('preSubmit', function ( e, d, type ) {
    if ( type === 'edit' ) {
      d.property = bceCloneProperty();
      d.property.namespace = bceNamespace;
      var columnObject = firstObject(d.data);
      $.each(columnObject, function(key, value) {
        d.property[key] = value;
      });
      delete d.data;
    }
    return true;
  });

  // Postsubmit event. Extend the timeout
  bceEditor.on('postSubmit', function ( e, json, data, type ) {
    ttExtendLock(bceBcs[bceCurrentIndex].uiIndex);
    bceGetBc(bceCurrentIndex, false);
  });

  // Submit error event. Route to the specified link.
  bceEditor.on('submitError', function (e, xhr, err, thrown, data) {
    window.location.href = xhr.responseJSON.link;
  });

  // Have a real table now, hide the temp empty one.
  bceHideTempTable();
  bceShowEditorTable();
}

function bceFormatTerminology(items) {
  text = "";
  for (var i=0; i<items.length; i++) {
    var item = items[i];
    text = text + item.subject_data.notation + ' [' + item.subject_data.identifier + ']<br/>';
  }
  return text;
}

function bceTempTableInit() {
  bceTempTable = $('#temp_table').DataTable({
    pageLength: 15,
    lengthMenu: [[5, 10, 15, 20, 25, 50, -1], [5, 10, 15, 20, 25, 50, "All"]]
  });
  bceShowTempTable();
  bceHideEditorTable();
}

function bceHideTempTable() {
  $('#temp_table_div').hide();
}

function bceShowTempTable() {
  $('#temp_table_div').show();
}

function bceHideEditorTable() {
  $('#editor_table_div').hide();
}

function bceShowEditorTable() {
  $('#editor_table_div').show();
}

function bceBcUrl() {
  return "/biomedical_concepts/" + bceId + '?biomedical_concept[namespace]=' + bceNamespace;
}

function firstObject(object) {
  var first;
  for (var i in object) {
    if (object.hasOwnProperty(i) && typeof(i) !== 'function') {
      first = object[i];
      break;
    }
  }
  return first;
}

function bceCloneProperty() {
  return JSON.parse(JSON.stringify(bceEmptyProperty));
}

function bceSetToken(index) {
  $('#token_' + bceBcs[index].uiIndex).val(bceBcs[index].token);
}

function bceClearToken(index) {
  $('#token_' + bceBcs[index].uiIndex).val("");
}

function bceGetToken(index) {
  return $('#token_' + bceBcs[index].uiIndex).val();
}

function bceShowBcCount() {
  $('#bc_timer_count').html(bceBcs.length);  
}

// Null function for page unload. Nothing to do
function pageUnloadAction() {
}

function bceShowPanel(index) {
  panelId = bceBcs[index].panelId;
  bcePanelIndexMap[panelId] = index;
  $("#bc_panel_" + panelId).show();
  $("#bc_panel_title_" + panelId).text("[" + (index + 1) + "] " + bceBcs[index].label);
}

function bceHidePanels() {
  $('.bc-panel').hide();
}

function bceHideTimers() {
  $('.bc-timer').hide();
}

function bceBcTree(index) {
  panelId = bceBcs[index].panelId;
  var div = "d3_" + panelId;
  bceBcs[index].d3Editor = new D3Editor(div, bceEmpty, bceEmpty, bceEmpty, bceEmpty);
  var rootNode = bceBcs[index].d3Editor.root("", C_BC, bceBcs[index].json)
  for (var i=0; i<bceBcs[index].json.children.length; i++) {
    bceSetD3(index, bceBcs[index].json.children[i], rootNode);
  }
  bceBcs[index].d3Editor.displayTree(rootNode.key)
  bceBcs[index].d3RootNode = rootNode;
}

function bceSetD3(index, sourceNode, d3ParentNode) {
  var newNode;
  if (bceAddNode(sourceNode)) {
    newNode = bceBcs[index].d3Editor.addNode(d3ParentNode, "", sourceNode.type, true, sourceNode, true);
    newNode.bceIndex = index;
    if (sourceNode.type === C_BC_ITEM) {
      bceSetD3(index, sourceNode.datatype, newNode);
    } else if (sourceNode.type === C_BC_DATATYPE) {
      for (var i=0; i<sourceNode.children.length; i++) {
        bceSetD3(index, sourceNode.children[i], newNode);
      }
    } else if (sourceNode.type === C_BC_PROP) {
      if (sourceNode.hasOwnProperty('complex_datatype')) {
        bceSetD3(index, sourceNode.complex_datatype, newNode);
      } else {
        if (sourceNode.children.length === 0) {
          newNode.name = "" //sourceNode.alias;
        } else {
          for (var i=0; i<sourceNode.children.length; i++) {
            bceSetD3(index, sourceNode.children[i], newNode);
          }
        }
      }
    } else if (sourceNode.type === C_TC_REF) {
      getThesaurusConcept(newNode, bceTcCallBack);
    } 
  }
}

function bceAddNode(node) {
  var result = false;
  if (node.type === C_BC_ITEM) {
    result = bceAddNode(node.datatype);
  } else if (node.type === C_BC_DATATYPE) {
    for (var i=0; i<node.children.length; i++) {
      result = result || bceAddNode(node.children[i]);
    }
  } else if (node.type === C_BC_PROP) {
    if (node.hasOwnProperty('complex_datatype')) {
      result = bceAddNode(node.complex_datatype);
    } else {
      if (node.enabled) {
        if (node.children.length === 0) {
          result = true;
        } else {
          for (var i=0; i<node.children.length; i++) {
            result = result || bceAddNode(node.children[i]);
          }
        }
      }
    }
  } else if (node.type === C_TC_REF) {
    result = true;
  } else {
    result = false;
  }
  return result;
}

function bceTcCallBack(node, result) {
  node.data.subject_data = result;
  node.name = node.data.subject_data.notation;
  var rootNode = bceBcs[node.bceIndex].d3Editor.rootNode;
  bceBcs[node.bceIndex].d3Editor.displayTree(rootNode.key)
}

function bceEmpty() {
}

function bceEnableDisablePreviousNext() {
  $("#bc_previous").prop("disabled", false);
  $("#bc_next").prop("disabled", false);
  if (bceFirstIndex === 0) {
    $("#bc_previous").prop("disabled", true);
  }
  if ((bceBcs.length - bceFirstIndex) <= C_PANEL_COUNT) {
    $("#bc_next").prop("disabled", true);
  }
}
;
