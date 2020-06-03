/*
* Study Version Editor: SOA Forms
*
* Requires:
*
* ims_list_table_div [Div] the table Div
* ims_list_table [Table] the table
* ims_all_table_div [Div] the table Div
* ims_all_table [Table] the table
* ims_add_button [Button] the add item
* ims_list_all_button [Button] toggle between list (released) and all items
* ims_history_button [Button] history of item
* ims_list_path [Hidden Field] list url
* ims_all_path [Hidden Field] all url
*/

function IsoManagedSelect(callBackRef) {
  this.callBackRef = callBackRef;
  this.listTable = null;
  this.listTableReload = false;
  this.listCurrent = null;
  this.allTable = null;
  this.allTableReload = false;
  this.allCurrent = null;
  this.buttonDisable();
  this.getList();
  this.getAll();
  this.mode = IsoManagedSelect.ALL;
  this.toggle(false);

  var _this = this;

  $('#ims_list_table tbody').on('click', 'tr', function () {
    _this.listTableClick(this);
  });

  $('#ims_all_table tbody').on('click', 'tr', function () {
    _this.allTableClick(this);
  });

  $('#ims_list_all_button').click(function() {
    _this.useReleasedForms = !_this.useReleasedForms;
    _this.toggle(true);
  });

  $('#ims_add_button').click(function() {
    _this.add();
  });

}

IsoManagedSelect.LIST = 1;
IsoManagedSelect.ALL = 2;

IsoManagedSelect.prototype.getList = function () {
  if (!this.listTableReload) {
    this.listTable = $('#ims_list_table').DataTable( {
      "ajax": {
        "type": 'GET',
        "url": $("#ims_list_path").val(),
        "dataSrc": "data"
      },
      "dataType": 'json',
      "bProcessing": true,
      "language": {
        "processing": generateSpinner("small")
      },
      error: function(xhr,status,error){
        handleAjaxError(xhr, status, error);
      },
      "columns": [
        {"data" : "scoped_identifier.identifier"},
        {"data" : "label"},
        {"data" : "scoped_identifier.semantic_version"}
      ]
    });
    this.listTableReload = true;
  } else {
    listTable.ajax.reload();
  }
}

IsoManagedSelect.prototype.getAll = function () {
  if (!this.allTableReload) {
    this.allTable = $('#ims_all_table').DataTable( {
      "ajax": {
        "type": 'GET',
        "url": $("#ims_all_path").val(),
        "dataSrc": "data"
      },
      "dataType": 'json',
      "bProcessing": true,
      "language": {
        "processing": generateSpinner("small")
      },
      error: function(xhr,status,error){
        handleAjaxError(xhr, status, error);
      },
      "columns": [
        {"data" : "scoped_identifier.identifier"},
        {"data" : "label"},
        {"data" : "scoped_identifier.semantic_version"}
      ]
    });
    this.allTableReload = true;
  } else {
    allTable.ajax.reload();
  }
}

IsoManagedSelect.prototype.buttonEnable = function () {
  this.buttonState(false);
}

IsoManagedSelect.prototype.buttonDisable = function () {
  this.buttonState(true);
}

IsoManagedSelect.prototype.buttonState = function (state) {
  $("#ims_add_button").prop("disabled", state);
  $("#ims_list_all_button").prop("disabled", state);
  $("#ims_history_button").prop("disabled", state);
}

IsoManagedSelect.prototype.toggle = function (alert) {
  var html;
  if (this.mode === IsoManagedSelect.ALL) {
    $("#ims_list_table_div").show();
    $("#ims_all_table_div").hide();
    $("#ims_history_table_div").hide();
    $("#ims_list_all_button").removeClass("btn-warning").addClass("btn-success");
    $("#ims_history_button").removeClass("btn-success").addClass("btn-warning");
    this.mode = IsoManagedSelect.LIST
    html = alertSuccess ("You are now using released forms.");
  } else if (this.mode === IsoManagedSelect.LIST) {
    $("#ims_list_table_div").hide();
    $("#ims_all_table_div").show();
    $("#ims_history_table_div").hide();
    $("#ims_list_all_button").removeClass("btn-success").addClass("btn-warning");
    $("#ims_history_button").removeClass("btn-success").addClass("btn-warning");
    this.mode = IsoManagedSelect.ALL
    html = alertWarning ("You are now using unreleased forms.");
  }
  if (this.listCurrent != null) {
    $(this.listCurrent).toggleClass('success');
  }
  if (this.allCurrent != null) {
    $(this.allCurrent).toggleClass('success');
  }
  this.listCurrent = null;
  this.allCurrent = null;
  if (alert) {
    displayAlerts(html);
  }
}

IsoManagedSelect.prototype.add = function () {
  var row;
  var data;
  if (this.listCurrent !== null) {
    row = this.listTable.row(this.listCurrent).index();
    data = this.listTable.row(row).data();
  } else if (this.allCurrent !== null) {
    row = this.allTable.row(this.allCurrent).index();
    data = this.allTable.row(row).data();
  } else {
    displayWarning ("You need to select an item.");
    return;
  }
  this.callBackRef(data);
}

IsoManagedSelect.prototype.listTableClick = function (_this) {
  if (this.listCurrent != null) {
    $(this.listCurrent).toggleClass('success');
  }
  $(_this).toggleClass('success');
  this.listCurrent = _this;
}

IsoManagedSelect.prototype.allTableClick = function (_this) {
  if (this.allCurrent != null) {
    $(this.allCurrent).toggleClass('success');
  }
  $(_this).toggleClass('success');
  this.allCurrent = _this;
}
