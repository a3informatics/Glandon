/*
* Children Panel
*
* Requires:
* children_table [Table] the managed item table
*/

/**
 * Children Panel Constructor
 *
 * @return [void]
 */
function ChildrenPanel(url, count, columns) {
  this.url = url;
  this.count = count;
  this.childrenTable = this.initTable(columns);

  this.add(0);
}

/**
 * Load data to table (paginated)
 *
 * @param offset [Integer] current batch offset
 * @return [void]
 */
ChildrenPanel.prototype.add = function (offset) {
  this.childrenTable.processing(true);

  $.ajax({
    url: this.url,
    data: {"count": this.count, "offset": offset},
    type: 'GET',
    dataType: 'json',
    context: this,
    success: function(result) {
      $.each(result.data, function(i, item) {
        this.childrenTable.row.add(item);
      }.bind(this));

      this.childrenTable.draw();
      this.childrenTable.columns.adjust();

      if (result.count >= this.count)
        this.add(result.offset + this.count);
      else
        this.childrenTable.processing(false);
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      this.childrenTable.processing(false);
    }
  });

}

/**
 * Adds column rendering Show button, initializes DataTable
 *
 * @param columns [Array] column definitions
 * @return [DataTable Instance] initialized managed children table
 */
ChildrenPanel.prototype.initTable = function(columns) {
  columns.push({
    "render" : function (data, type, row, meta) {
      return this.linkButton(row.show_path, "Show");
    }.bind(this)});

  return $('#children_table').DataTable({
    "order": [[ 0, "desc" ]],
    "columns": columns,
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "processing": true,
    "autoWidth": false,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No child items.",
      "processing": generateSpinner("small")
    }
  });
}

/**
 * Clear data and refresh table
 *
 * @return [void]
 */
ChildrenPanel.prototype.refresh = function() {
  this.childrenTable.clear();
  this.add(0);
}

/**
 * HTML Helper for Show button
 *
 * @param path [String] Show path URL
 * @param text [String] Button text
 * @return [String] formatted button (link) HTML
 */
ChildrenPanel.prototype.linkButton = function (path, text) {
  if (path === "") {
    return ""
  } else {
    return '<a href="' + path + '" class="btn btn-xs">' + text + '</a>';
  }
}
