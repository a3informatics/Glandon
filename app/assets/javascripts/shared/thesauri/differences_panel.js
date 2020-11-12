/*
* Differences Panel
*
* Requires:
* differences_table [Table] the differences table
*/

/**
 * Differences Panel Constructor
 *
 * @return [void]
 */
function DifferencesPanel(url) {
  this.url = url;
  this.cache = {};
  this.processing = false;
  var _this = this;
  var columns = [
    {"data" : "date"},
    {"render" : function (data, type, row, meta) {
      return _this.status(row.differences.identifier);
    }},
    {"render" : function (data, type, row, meta) {
      return _this.status(row.differences.notation);
    }},
    {"render" : function (data, type, row, meta) {
      return _this.status(row.differences.preferred_term);
    }},
    {"render" : function (data, type, row, meta) {
      // var html = "";
      // jQuery.each(row.differences.synonym, function(i, val) {
      //   html = html + _this.merge(val.label);
      // });
      // return html;
      return _this.status(row.differences.synonym);
    }},
    {"render" : function (data, type, row, meta) {
      return _this.status(row.differences.definition);
    }}];

  this.columns = columns;

  this.init();
  this.add();
}

/**
 * Initializes table
 *
 * @return [void]
 */
DifferencesPanel.prototype.init = function () {
  var _this = this;

  this.differencesTable = $('#differences_table').DataTable( {
    "columns": this.columns,
    "pageLength": pageLength, // Gloabl setting
    "lengthMenu": pageSettings, // Gloabl setting
    "processing": true,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No differences.",
      "processing": generateSpinner("small")
    }
  });
}

/**
 * Add items to table
 *
 * @return [void]
 */
DifferencesPanel.prototype.add = function () {
  if(this.url == null)
    return;

  var _this = this;
  this.processing = true;
  this.differencesTable.processing(true);

  $.ajax({
    url: this.url,
    type: 'GET',
    dataType: 'json',
    success: function(result) {
      $.each(result.data, function(key, item){
        _this.differencesTable.row.add(item);
      });
      _this.differencesTable.draw();
      _this.saveCache(_this.url, _this.differencesTable.rows().data());
      _this.differencesTable.processing(false);
      _this.processing = false;
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      _this.differencesTable.processing(false);
      _this.processing = false;
    }
  });
}


/**
 * Resets table
 *
 * @param newUrl [String] new data url
 * @return [void]
 */
DifferencesPanel.prototype.reload = function (newUrl) {
  this.differencesTable.clear();
  this.url = newUrl;

  if(this.cache[newUrl] != null)
    this.loadFromCache(newUrl);
  else
    this.add();
}

/**
 * Saves DataTable Rows.Data() to cache, if not existing
 *
 * @param id [String] url of the item that will be the key in the cache, is unique
 * @param data [DataTables Rows Data] datatables api instance of all rows
 * @return [void]
 */
DifferencesPanel.prototype.saveCache = function(id, data) {
  if(this.cache[id] == null)
    this.cache[id] = data.toArray();
}

/**
 * Clears table and reloads data from cache
 *
 * @param id [String] url of the item that is the key in the cache, is unique
 * @return [void]
 */
DifferencesPanel.prototype.loadFromCache = function(id) {
  this.differencesTable.rows().remove();
  this.differencesTable.processing(true);

  $.each(this.cache[id], function(i, data) {
    this.differencesTable.row.add(data);
  }.bind(this));

  this.differencesTable.draw();
  this.differencesTable.processing(false);
}

DifferencesPanel.prototype.status = function (data) {
  if (data.status === "deleted") {
    return '<div class="text-centered"><span class="icon-times-circle text-accent-2 text-xnormal ttip"><span class="ttip-text ttip-center text-medium text-small shadow-small">Deleted</span></span></div>';
  } else if (data.status === "no_change") {
    return '<div class="text-centered"><span class="icon-arrow-circle-d text-light text-xnormal ttip"><span class="ttip-text ttip-left text-medium text-small shadow-small">No change</span></span></div>';
  } else if (data.status === "created") {
    return '<div class="diff">' + data.current + '</div>';
  } else if(data.status === "updated") {
    return '' + data.difference + '';
  } else {
    return '&nbsp;';
  }
}

DifferencesPanel.prototype.merge = function (data) {
  if (data.status === "deleted") {
    return data.difference + '</br>'
  } else if (data.status === "no_change") {
    return data.current + '</br>';
  } else if (data.status === "created") {
    return '<div class="diff">' + data.current + '</div></br>';
  } else if(data.status === "updated") {
    return data.difference + '</br>';
  } else {
    return '';
  }
}
