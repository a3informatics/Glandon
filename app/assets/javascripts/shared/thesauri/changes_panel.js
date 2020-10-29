/*
* Changes Panel
*
* Requires:
* changes [Table] the changes table
*/

/**
 * Change Panel Constructor
 *
 * @return [void]
 */
function ChangesPanel(url, column_count) {
  this.url = url;
  this.column_count = column_count;
  this.cache = {};
  this.processing = false;

  var _this = this;
  var columns = [
    {"data" : "identifier", className: "fit"},
    {"data" : "label"},
    {"data" : "notation"}];
  for (i=0; i<column_count; i++) {
    columns.push({className: "text-center", "render" : function (data, type, row, meta) {
      index = meta.col - 3;
      if (type == 'display') {
        return _this.status(row["status"+index]);
      } else {
        return row["status"+index];
      }
    }});
  }
  columns.push({className: "text-center", "render" : function (data, type, row, meta) {
    return '<a href="' + row.changesPath + '" class="btn  btn-xs">Changes</a>';
  }});

  this.columns = columns;

  this.init();
  this.hideButtons();
  this.add();
}

/**
 * Initializes table
 *
 * @return [void]
 */
ChangesPanel.prototype.init = function () {
  this.changesTable = $('#changes').DataTable( {
    "columns": this.columns,
    "pageLength": pageLength, // Gloabl setting
    "lengthMenu": pageSettings, // Gloabl setting
    "autoWidth": false,
    "processing": true,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No changes.",
      "processing": generateSpinner("small")
    }
  });
}

/**
 * Add items to table
 *
 * @return [void]
 */
ChangesPanel.prototype.add = function () {
  if(this.url == null)
    return;

  var _this = this;
  _this.changesTable.processing(true);
  _this.processing = true;
  $.ajax({
    url: _this.url,
    type: 'GET',
    dataType: 'json',
    success: function(result) {
    	for (i=0; i<result.data.versions.length; i++) {
        $(_this.changesTable.column(3+i).header()).text(result.data.versions[i]);
      }
      $.each(result.data.items, function(key, item){
        var row = {identifier: item.identifier, key: item.key, changesPath: item.changes_path, label: item.label, notation: item.notation};
        for (j=0; j<item.status.length; j++) {
          row["status"+j] = item.status[j].status
        }
        for (j=item.status.length; j<_this.column_count; j++) {
          row["status"+j] = "not_present"
        }
        _this.changesTable.row.add(row);
      });
      _this.changesTable.draw();
      _this.saveCache(_this.url, _this.changesTable.rows().data());
      _this.showButtons();
      _this.changesTable.processing(false);
      _this.processing = false;
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      _this.changesTable.processing(false);
      _this.processing = false;
    }
  });
}

/**
 * Saves DataTable Rows.Data() to cache, if not existing
 *
 * @param id [String] url of the item that will be the key in the cache, is unique
 * @param data [DataTables Rows Data] datatables api instance of all rows
 * @return [void]
 */
ChangesPanel.prototype.saveCache = function(id, data) {
  if(this.cache[id] == null)
    this.cache[id] = data.toArray();
}

/**
 * Clears table and reloads data from cache
 *
 * @param id [String] url of the item that is the key in the cache, is unique
 * @return [void]
 */
ChangesPanel.prototype.loadFromCache = function(id) {
  this.changesTable.rows().remove();
  this.changesTable.processing(true);

  $.each(this.cache[id], function(i, data) {
    this.changesTable.row.add(data);
  }.bind(this));

  this.changesTable.draw();
  this.changesTable.processing(false);
}


/**
 * Resets datatable, reloads data
 *
 * @param newUrl [String] new data url
 * @return [void]
 */
ChangesPanel.prototype.reload = function (newUrl) {
  this.changesTable.clear();
  this.url = newUrl;

  if(this.cache[newUrl] != null)
    this.loadFromCache(newUrl);
  else
    this.add();
}

/**
 * Hide Buttons. Hide the button bar with the scroll buttons
 *
 * @return [void]
 */
ChangesPanel.prototype.hideButtons = function () {
  $("#forward_backward_div").hide();
}

/**
 * Show Buttons. Show the button bar with the scroll buttons
 *
 * @return [void]
 */
ChangesPanel.prototype.showButtons = function () {
  $("#forward_backward_div").show();
}

/**
 * Status. Turn the status value into HTML icon
 *
 * @return [String] the HTML
 */
ChangesPanel.prototype.status = function (status) {
  if (status == "created") {
    return '<span class="icon-plus-circle text-secondary-clr text-xnormal ttip"><span class="ttip-text ttip-left text-medium text-small shadow-small">Created</span></span>';
  } else if (status == "no_change") {
    return '<span class="icon-arrow-circle-r text-light text-xnormal ttip"><span class="ttip-text ttip-left text-medium text-small shadow-small">No change</span></span>';
  } else if (status == "updated") {
    return '<span class="icon-edit-circle text-link text-xnormal ttip"><span class="ttip-text ttip-left text-medium text-small shadow-small">Updated</span></span>';
  } else if (status == "deleted") {
    return '<span class="icon-times-circle text-accent-2 text-xnormal ttip"><span class="ttip-text ttip-left text-medium text-small shadow-small">Deleted</span></span>';
  } else if (status == "not_present") {
    return '&nbsp;';
  } else {
    return '<span class="font-light text-medium">' + status + '</span>';
  }
}
