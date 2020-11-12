/*
* Comments Panel for Managed Items
*
* Requires:
* comments_table [Table] the managed item commentstable
*/

/**
 * Comments Panel Constructor
 *
 * @return [void]
 */
function CommentsPanel(url) {
  var _this = this;
  this.url = url;

  var loading_html = generateSpinner("small");

  this.commentsTable = $('#comments_table').DataTable({
    ajax: {
      url: _this.url,
      dataSrc: "data",
      error: function (xhr, status, error) {
        displayError("An error has occurred loading the comments.");
      }
    },
    processsing: true,
    autoWidth: false,
    language: {
      "infoFiltered": "",
      "emptyTable": "No child items.",
      "processing": loading_html
    },
    pageLength: pageLength,
    lengthMenu: pageSettings,
    dataType: 'json',
    order: [[ 0, "desc" ]],
    columns: [
      {"render" : function (data, type, row, meta) {
        if (type == 'display') {
          return row.semantic_version;
        } else {
          return row.version;
        }}
      },
      {"data" : "creation_date"},
      {"data" : "last_change_date"},
      {"data" : "explanatory_comment"},
      {"data" : "change_description"},
      {"data" : "origin"},
      {"render" : function (data, type, row, meta) {
        return '<a href="' + row.edit_path + '" class="btn  btn-xs">Edit</a>';
      }}
    ]
  });
}
