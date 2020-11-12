// Import Code List Panel
function ImportItemsPanel(callback, list_url, create_url) {
  this.callback = callback;
  this.uri = "";
  this.filename = "";
  this.list_url = list_url;
  this.create_url = create_url;
  this.itemsTable = null;
  this.first = true;
  this.fileType = file_type;
  $('#import_button').prop('disabled', true);
  $('#import_index_button').prop('disabled', true);
  $('#items_panel_div').hide();
  $('#items_table_spinner_div').hide();
  $('#items_table_div').hide();

  var _this = this;

  $('#import_button').click(function() {
    identifiers = [];
    data = _this.itemsTable.rows({selected: true}).data();
    for (i=0; i<data.length; i++) {
      identifiers.push(data[i].identifier);
    }
    if (identifiers.length === 0) {
      displayWarning("Please select at least one item.")
    } else {
      _this.itemsTable.rows({ selected: true }).deselect();
      _this.import(identifiers);
    }
  });

  $('#import_index_button').click(function() {
    window.location.href = "Rails.application.routes.url_helpers.imports_path";
  });

}

ImportItemsPanel.prototype.refresh = function(uri, filename) {
  $('#imports_filename').text(filename);
  this.uri = uri;
  this.filename = filename;
  var _this = this;
  if (this.first) {
    this.first = false;
    this.itemsTable = $('#items_table').DataTable( {
      "columns": [
        {"data" : "identifier"},
        {"data" : "label"}
      ],
      ajax: {
        url: this.list_url,
        data: function (d) {
          d.imports = {};
          d.imports.files = [ _this.filename ];
          d.imports.file_type = _this.fileType;
        },
        error: function (xhr, status, error) {
          _this.processing(false);
          displayError("An error has occurred loading the table.");
        }
      },
      select: { style: 'multi' },
      "deferLoading": 0, // defer the loading until reload
      "pageLength": pageLength, // Gloabl setting
      "lengthMenu": pageSettings // Gloabl setting
    });
    this.itemsTable.on('draw', function() {
      _this.processing(false);
      $('#import_button').prop('disabled', false);
    });
    $('#items_panel_div').show();
    this.processing(true);
  } else {
    this.processing(true);
    this.itemsTable.clear();
    this.itemsTable.ajax.reload();
  }
}

ImportItemsPanel.prototype.import = function(identifiers) {
  var autoLoad = $("#imports_auto_load").is(':checked');
  var _this = this;
  identifier = identifiers.pop();
  $.ajax({
    url: this.create_url,
    data: { imports: {"files":[ _this.filename ], "uri": this.uri, "identifier": identifier, "file_type": _this.fileType, "auto_load": autoLoad}},
    type: 'POST',
    dataType: 'json',
    success: function(result) {
      if (identifiers.length > 0) {
        _this.import(identifiers);
      } else {
        $('#import_index_button').prop('disabled', false);
      }
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
    }
  });
}

ImportItemsPanel.prototype.processing = function(state) {
  if (state) {
    $('#items_table_spinner_div').show();
    $('#items_table_div').hide();
  } else {
    $('#items_table_spinner_div').hide();
    $('#items_table_div').show();
  }
}
