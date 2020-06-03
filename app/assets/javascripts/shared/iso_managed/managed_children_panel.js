/*
* Managed Item Panel
*
* Requires:
* managed_item_table [Table] the managed item table
*/

/**
 * ISO Managed List Panel Constructor
 *
 * @return [void]
 */
function ManagedChildrenPanel(url, count, columns, strongParam) {
  this.url = url;
  this.count = count;
  this.strongParam = strongParam;
  this.childrenTable = this.initTable(columns);

  this.add(0);
}

/**
 * Load data to table (paginated)
 *
 * @param offset [Integer] current batch offset
 * @return [void]
 */
ManagedChildrenPanel.prototype.add = function (offset) {
  this.childrenTable.processing(true);

  $.ajax({
    url: this.url,
    data: this.getData(offset),
    type: 'GET',
    dataType: 'json',
    context: this,
    success: function(result) {
      $.each(result.data, function(i, item) {
        this.childrenTable.row.add(item);
      }.bind(this));

      this.childrenTable.draw();

      if (result.count >= this.count)
        this.add(result.offset + this.count)
      else
        this.childrenTable.processing(false);
    },
    error: function(xhr,status,error) {
      handleAjaxError(xhr, status, error);
      this.childrenTable.processing(false);
    }
  });
}

/**
 * Data helper
 *
 * @param offset [Integer] current offset
 * @return [Object] count, offset data object with strong param set
 */
ManagedChildrenPanel.prototype.getData = function (offset) {
  var data = {}

  data[this.strongParam] = {
    count: this.count,
    offset: offset
  }

  return data;
}

/**
 * Adds column rendering Show button, initializes DataTable
 *
 * @param columns [Array] column definitions
 * @return [DataTable Instance] initialized managed children table
 */
ManagedChildrenPanel.prototype.initTable = function (columns) {
  columns.push({
    "render" : function (data, type, row, meta) {
      return this.linkButton(row.show_path, "Show");
    }.bind(this)});

  return $('#children_table').DataTable({
    "order": [[ 0, "desc" ]],
    "columns": columns,
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "autoWidth": false,
    "processing": true,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No child items.",
      "processing": generateSpinner("small")
    }
  });
}

/**
 * HTML Helper for Show button
 *
 * @param path [String] Show path URL
 * @param text [String] Button text
 * @return [String] formatted button (link) HTML
 */
ManagedChildrenPanel.prototype.linkButton = function (path, text) {
  if (path === "") {
    return ""
  } else {
    return '<a href="' + path + '" class="btn btn-xs">' + text + '</a>';
  }
}
