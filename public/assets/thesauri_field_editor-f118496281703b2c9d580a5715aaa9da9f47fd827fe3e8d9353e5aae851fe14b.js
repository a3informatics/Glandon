/*
* Thesauri Field Editor. 
* 
* Editor to allow a field that contains terminology to be edited with
* items added and deleted.
* 
* Requires:
* 
* tfe_panel_title [Heading] the panel heading 
* tfe_item_table [Table] Datatables table
* tfe_processing [Button] processing spinner
* tfe_add_item [Button] the add item button
* tfe_up [Button] the move up button
* tfe_down [Button] the move down button
* tfe_delete_item [Button] the delete item button
* tfe_delete_all_items [Button] the delete all items button
*/


var tfeChangeCallBack;
var tfeChangeCallBackRef;
var tfeMoveUpCallBack;
var tfeMoveDownCallBack;
var tfeCurrentRef;        // 
var tfeCurrentRow;        // 
var tfeItemTable;

$(document).ready( function() {
  $('#tfe_item_table tbody').on('click', 'tr', function () {
    if (tfeCurrentRef !== null) {
      $(tfeCurrentRef).toggleClass('success');
    }
    $(this).toggleClass('success');
    var row = tfeItemTable.row(this).index();
    var data = tfeItemTable.row(row).data();
    tfeCurrentRef = this;
    tfeCurrentRow = row;
    // Disable the up and down as appropriate
    $('#tfe_up').prop("disabled", false);
    $('#tfe_down').prop("disabled", false);
    if (data.tc_ref.ordinal === 1) {
      $('#tfe_up').prop("disabled", true);
    }
    if (data.tc_ref.ordinal === tfeItemTable.rows().data().length) {
      $('#tfe_down').prop("disabled", true);
    }
  });

  $('#tfe_add_item').on ('click', function() {
    uri = tsGet();
    if (uri !== null) {
      spAddSpinner("#tfe_processing");
      tfeAdd(getId(uri), getNamespace(uri));
    } else {
      displayWarning("You need to select an item.");
    }
  });

  $('#tfe_delete_item').on ('click', function() {
    if (tfeCurrentRow !== null) {
      tfeDeleteCurrentRow();
    } else {
      displayWarning("You need to select an item.");
    }
  });

  $('#tfe_delete_all_items').on ('click', function() {
    tfeDeleteAll();
  });

  $('#tfe_up').on ('click', function() {
    if (tfeCurrentRow !== null) {
      tfeMoveUp();
    } else {
      displayWarning("You need to select an item.");
    }
  });

  $('#tfe_down').on ('click', function() {
    if (tfeCurrentRow !== null) {
      tfeMoveDown();
    } else {
      displayWarning("You need to select an item.");
    }
  });

});

function tfeInit() {
  tfeDisable();
  $("#tfe_processing").prop("disabled", true);
  tfeChangeCallBack = null;
  tfeChangeCallBackRef = null;
  tfeCurrentRef = null;
  tfeCurrentRow = null;
  columns = [
    {"data" : "tc_ref.ordinal"},
    {"data" : "identifier"},
    {"data" : "notation"},
    {"data" : "preferredTerm"}
  ];
  tfeItemTable = $('#tfe_item_table').DataTable( {
    rowId: "tc_ref.ordinal",
    pageLength: pageLength,
    lengthMenu: pageSettings,
    columns: columns
  });
}

function tfeSetCallBacks(changeCallBack, moveUpCallBack, moveDownCallBack) {
  tfeChangeCallBack = changeCallBack;
  tfeMoveDownCallBack = moveDownCallBack;
  tfeMoveUpCallBack = moveUpCallBack;  
}

function tfeDeleteCurrentRow() {
  tfeItemTable.row(tfeCurrentRow).remove();
  tfeCurrentRow = null;
  tfeCurrentRef = null;
  tfeItemTable.draw();
  rowData = tfeItemTable.rows().data();
  tfeChangeCallBack(rowData.length, tfeChangeCallBackRef);
}

function tfeDeleteAll() {
  tfeClear();
  tfeChangeCallBack(0, tfeChangeCallBackRef);
}

function tfeAdd(id, namespace) {
  var node = { "data": { "subject_ref": { "id": id, "namespace": namespace }}};
  getThesaurusConcept(node, tfeAddCallback)
}

function tfeMoveUp(id, namespace) {
  //tfeItemTable.row(tfeCurrentRow).remove();
  //tfeCurrentRow = null;
  //tfeCurrentRef = null;
  tfeSwapRows(tfeCurrentRow, tfeCurrentRow - 1);
  tfeMoveUpCallBack(tfeChangeCallBackRef);
}

function tfeMoveDown(id, namespace) {
  //tfeItemTable.row(tfeCurrentRow).remove();
  //tfeCurrentRow = null;
  //tfeCurrentRef = null;
  tfeSwapRows(tfeCurrentRow, tfeCurrentRow + 1);
  tfeMoveDownCallBack(tfeChangeCallBackRef);
}

function tfeAddCallback(node, result) {
  if (result.children.length === 0) {
    tfeAddRow(result);
  } else {
    var ok = true;
    if (result.children.length > 10) {
      ok = confirm("Are you sure (adding " + result.children.length + "items)?");
    }
    if (ok) {
      for (var i=0; i<result.children.length; i++) {
        tfeAddRow(result.children[i]);
      }
    }
  }
  tfeItemTable.draw();
  if (tfeChangeCallBack !== null) {
    rowData = tfeItemTable.rows().data();
    tfeChangeCallBack(rowData.length, tfeChangeCallBackRef);
  }
  spRemoveSpinner("#tfe_processing");
}

function tfeAddRow(item) {
  item.tc_ref = { "subject_ref": { "id": item.id, "namespace": item.namespace }, "ordinal": (tfeItemTable.data().count() + 1) };
  tfeItemTable.row.add(item);
}

function tfeToRefs() {
  result = [];
  rowData = tfeItemTable.rows().data();
  for (i=0; i<rowData.length; i++) {
    item = rowData.row(i).data();
    result.push(item.tc_ref);
    //result.push({ "subject_ref": { "id": item.id, "namespace": item.namespace }, "ordinal": (i + 1)});
  }
  return result;
}

function tfeToData() {
  result = [];
  rowData = tfeItemTable.rows().data();
  for (i=0; i<rowData.length; i++) {
    item = rowData.row(i).data();
    item.tc_ref.subject_data = item;
    result.push(item.tc_ref);
    //result.push({ "subject_ref": { "id": item.id, "namespace": item.namespace }, "ordinal": (i + 1), "subject_data": item });
  }
  return result;
}

function tfeLoad(items) {
  tfeItemTable.clear();
  for (var i=0; i<items.length; i++) {
    tfeAddRow(items[i].subject_data);
    //tfeItemTable.row.add(items[i].subject_data);
  }
  tfeItemTable.draw();
}

function tfeClear() {
  tfeItemTable.clear().draw();
  tfeCurrentRef = null;
  tfeCurrentRow = null;
}

function tfeEnable(title, ref) {
  var status = false;
  tfeChangeCallBackRef = ref;
  $("#tfe_panel_title").text("Terminology: " + title);
  $('#tfe_add_item').prop("disabled", status);
  $('#tfe_up').prop("disabled", status);
  $('#tfe_down').prop("disabled", status);
  $('#tfe_delete_item').prop("disabled", status);
  $('#tfe_delete_all_items').prop("disabled", status);
}

function tfeDisable() {
  var status = true;
  $("#tfe_panel_title").text("Terminology: No Field Selected");
  $('#tfe_add_item').prop("disabled", status);
  $('#tfe_up').prop("disabled", status);
  $('#tfe_down').prop("disabled", status);
  $('#tfe_delete_item').prop("disabled", status);
  $('#tfe_delete_all_items').prop("disabled", status);
}

function tfeSwapRows(row1Index, row2Index) {
  $(tfeCurrentRef).toggleClass('success');
  var row1Data = tfeItemTable.row(row1Index).data();
  var row2Data = tfeItemTable.row(row2Index).data();
  var temp = row1Data.tc_ref.ordinal;
  row1Data.tc_ref.ordinal = row2Data.tc_ref.ordinal;
  row2Data.tc_ref.ordinal = temp;
  tfeItemTable.row(row1Index).data(row2Data);
  tfeItemTable.row(row2Index).data(row1Data).draw();
  tfeCurrentRef = tfeItemTable.row('#' + row1Data.tc_ref.ordinal).node();
  tfeCurrentRow = tfeItemTable.row(tfeCurrentRef).index();
  $(tfeCurrentRef).toggleClass('success');
}
;
