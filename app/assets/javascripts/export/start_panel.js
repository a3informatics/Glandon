// Export Start view
$(document).ready( function() {
  var sp = new StartPanel(url);
});

// Export Start Panel
function StartPanel(url) {
  this.url = url;
  this.itemTable = $('#item_table').DataTable( {
    "columns": [
      {"data" : "identifier"},
      {"data" : "label"},
      {"data" : "semantic_version"},
      {"render" : function (data, type, row, meta) {
        return '<a href="/exports/download?export[file_path]=' + row.file_path + '" class="btn btn-info btn-xs">Download File</a>';
      }}
    ],
    "pageLength": pageLength, // Global setting
    "lengthMenu": pageSettings // Global setting
  });
  this.display(true);
  this.list();
 }
 
StartPanel.prototype.list = function() {
  _this = this;
  $.ajax({
    url: _this.url,
    type: 'GET',
    dataType: 'json',
    success: function(result) {
      for (var i=0; i<result.data.length; i++) {
        _this.item(result.data[i]);
      }
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
    }
  });
}

StartPanel.prototype.item = function(item) {
  _this = this;
  $.ajax({
    url: item.url,
    type: 'GET',
    dataType: 'json',
    success: function(result) {
      _this.display(false);
      item.file_path = result.file_path;
      _this.itemTable.row.add(item);
      _this.itemTable.draw();
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
    }
  });
}

StartPanel.prototype.display = function(waiting) {
  if (waiting) {
    $('#spinner_div').show();
    $('#item_table_div').hide();
  } else {
    $('#spinner_div').hide();
    $('#item_table_div').show();
  }
}