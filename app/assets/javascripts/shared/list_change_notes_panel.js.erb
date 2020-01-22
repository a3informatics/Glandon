/*
* List Change Notes Panel (paginated)
*
* Requires:
* list-change-notes-table [Table] the changes notes table
*/

/**
 * List Change Notes Panel Constructor
 *
 * @param url [String] Url for data fetching
 * @param count [Int] Amount of items fetched in one call
 * @return [void]
 */
function ListChangeNotesPanel(url, count) {
  this.url = url;
  this.count = count;

  this.initTable();
  this.loadData(0);
}

/**
 * Load data from server to the table
 *
 * @return [void]
 */
ListChangeNotesPanel.prototype.initTable = function () {
  this.table = $("#list-change-notes-table").DataTable({
    "order": [[0, "desc"]],
    "columns": this.columns(),
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "processing": true,
    "paging": true,
    "language": {
      "infoFiltered": "",
      "emptyTable": "No Change notes were found.",
      "processing": generateSpinner("medium")
    }
  });
}


/**
 * Load data from server to the table
 *
 * @param offset [Integer] item count offset
 * @return [void]
 */
ListChangeNotesPanel.prototype.loadData = function (offset) {
  if (offset == 0)
    this.table.processing(true);

  $.ajax({
    url: this.url,
    data: {iso_managed: {offset: offset, count: this.count}},
    type: 'GET',
    dataType: 'json',
    context: this,
    success: function(result) {
    	for (i=0; i<result.data.length; i++) {
        var row = this.table.row.add(result.data[i]);
      }
      this.table.draw();
      this.table.columns.adjust();

      if (result.count >= this.count) {
        this.table.processing(false);
        this.loadData(result.offset + this.count)
      }
      else
        this.table.processing(false);
    },
    error: function(xhr,status,error){
      handleAjaxError(xhr, status, error);
      this.table.processing(false);
    }
  });
}


/**
 * Get columns for table
 *
 * @return [void]
 */
ListChangeNotesPanel.prototype.columns = function () {
  return [
    {"data" : "cl_identifier"},
    {"data" : "cl_notation"},
    {"data" : "cl_label"},
    {"data" : "timestamp", "class": "note-cell",
      "render": function (data, type, row, meta){
        var date = new Date(row.timestamp);
        if (type == "display")
          return dateTimeHTML(date);
        else return data;
      }},
    {"data" : "user_reference", "class": "note-cell"},
    {"data" : "reference", "class": "note-cell"},
    {"data" : "description", "class": "note-cell"}
  ]
}
