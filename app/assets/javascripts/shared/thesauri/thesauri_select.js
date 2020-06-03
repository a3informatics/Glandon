/*
* Modal Panel
*/

/**
* Modal Panel Constructor
* @param id [String] The id of the Code List
* @param callback [Function] The callback function
*
* @return [void]
*/
//function ThesauriSelect(id, reference_ct_id, callback) {
function ThesauriSelect(id, callback) {
  this.callback = callback;
  this.id = id;
  //this.reference_ct_id = reference_ct_id;
  this.tsModalTable = null;
  this.columns = [
    {"data" : "owner"},
    {"data" : "identifier"},
    {"data" : "label"}
  ];
  this.initTable();
  var _this = this;

  $('#th-select-modal').on('shown.bs.modal', function () {
   //helps the columns take their widths in modal
   _this.tsModalTable.columns.adjust();
    var count = _this.tsModalTable.rows( { selected: true } ).count();
    if (count > 0) {
      $('#select_th').removeClass('disabled').removeAttr("disabled","disabled");
    }
    if (count === 0) {
      $('#select_th').addClass('disabled').attr("disabled","disabled");
    }
  });

  // Enable th select button
  _this.tsModalTable.on( 'select', function ( e, dt, type, indexes ) {
    if ( type === 'row' ) {
      var count = _this.tsModalTable.rows( { selected: true } ).count();
      if (count > 0) {
        $('#select_th').removeClass('disabled').removeAttr("disabled","disabled");
      }
    }
  });

  // Disable th select button
  _this.tsModalTable.on( 'deselect', function ( e, dt, type, indexes ) {
    if ( type === 'row' ) {
      var count = _this.tsModalTable.rows( { selected: true } ).count();
      if (count === 0) {
        $('#select_th').addClass('disabled').attr("disabled","disabled");
      }
    }
  });

  // Get selected th callback
  $('#select_th').click(function() {
    $('#th-select-modal').modal('hide');
    var rowdata = _this.tsModalTable.rows( { selected: true } ).data();
    //_this.callback({"reference_ct_id": _this.reference_ct_id ,"scope_id": rowdata[0].scope_id, "identifier": rowdata[0].identifier, "concept_id": _this.id});
    _this.callback({"scope_id": rowdata[0].scope_id, "identifier": rowdata[0].identifier, "concept_id": _this.id});
  });

  // Skip Th select callback
  $('#skip_th_select').click(function() {
    $('#th-select-modal').modal('hide');
    _this.callback(null);
  });

}

/**
 * Initialise the table/datatable
 * @return [void]
 */
ThesauriSelect.prototype.initTable = function() {
  var _this = this;

  this.tsModalTable = $('#thTable').DataTable( {
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "processing": true,
    "ajax": {
      "url": "/thesauri/index_owned",
      "dataSrc": "data",
      "error": function (xhr, error, code) {
        handleAjaxError(xhr, status, error);
      }
    },
    "rowId": "id",
    "deferLoading": 0,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No Terminologies found.",
      "processing": generateSpinner("medium")
    },
    "columns": this.columns,
    "orderCellsTop": true,
    "select": {
        style: 'single'
    },
  });
};

/**
 * Sets a callback
 * @param [function] callback
 * @return [void]
 */
ThesauriSelect.prototype.setCallback = function(callback){
  var _this = this;
  _this.callback = callback;
}

/**
 * Resets the UI of the Thesaurus select modal
 * @return [void]
 */
ThesauriSelect.prototype.resetUi = function(){
  var _this = this;
  _this.tsModalTable.rows( { selected: true } ).deselect();
}
